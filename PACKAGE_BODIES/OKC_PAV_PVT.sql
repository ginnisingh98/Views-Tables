--------------------------------------------------------
--  DDL for Package Body OKC_PAV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PAV_PVT" AS
/* $Header: OKCSPAVB.pls 120.0.12010000.2 2010/06/22 09:45:54 nvvaidya ship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

  FUNCTION get_rec (
    p_pav_rec                      IN   OKC_PAV_PVT.pav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OKC_PAV_PVT.pav_rec_type IS
    l_pav_rec                      OKC_PAV_PVT.pav_rec_type;
     BEGIN
--SUbstitute name
   l_pav_rec:= OKC_SPLIT1_PAV_PVT.get_rec(p_pav_rec,x_no_data_found );
---
   RETURN(l_pav_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pav_rec                      IN OKC_PAV_PVT.pav_rec_type
  ) RETURN OKC_PAV_PVT.pav_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pav_rec, l_row_notfound));
  END get_rec;


 ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_PRICE_ATT_VALUES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pavv_rec                     IN pavv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pavv_rec_type IS
      l_pavv_rec                     pavv_rec_type;
     BEGIN
-------------------------------------------
l_pavv_rec :=OKC_SPLIT1_PAV_PVT.get_rec(p_pavv_rec  , x_no_data_found);
--------------------------------------------
    RETURN(l_pavv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pavv_rec                     IN pavv_rec_type
  ) RETURN pavv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pavv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_PRICE_ATT_VALUES_V --
  ------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_pavv_rec	IN pavv_rec_type
  ) RETURN pavv_rec_type IS
    l_pavv_rec	pavv_rec_type := p_pavv_rec;
  BEGIN
--------------
l_pavv_rec :=OKC_SPLIT1_PAV_PVT.null_out_defaults( p_pavv_rec );

-------------

    RETURN(l_pavv_rec);
  END null_out_defaults;


 ---------------------------------------------------------------------------------------
  --Attribute Level Validattion Procedures Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id(
    p_pavv_rec          IN pavv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_pavv_rec.id = OKC_API.G_MISS_NUM OR
       p_pavv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKC_PRICE_ATT_VALUES_V --
  ----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_pavv_rec IN  pavv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
     ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------
    OKC_UTIL.ADD_VIEW('OKC_PRICE_ATT_VALUES_V', l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_id(p_pavv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

RETURN(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      return(x_return_status);
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return(x_return_status);
  ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Ends(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Record for:OKC_PRICE_ATT_VALUES_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_pavv_rec IN pavv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_pavv_rec IN pavv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_chrv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              'x'
        FROM Okc_K_Headers_B
       WHERE okc_k_headers_b.id   = p_id;
      l_okc_chrv_pk                  okc_chrv_pk_csr%ROWTYPE;
      CURSOR okc_clev_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              'x'
        FROM Okc_K_Lines_B
       WHERE okc_k_lines_b.id     = p_id;
      l_okc_clev_pk                  okc_clev_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_pavv_rec.CHR_ID IS NOT NULL)
      THEN
        OPEN okc_chrv_pk_csr(p_pavv_rec.CHR_ID);
        FETCH okc_chrv_pk_csr INTO l_okc_chrv_pk;
        l_row_notfound := okc_chrv_pk_csr%NOTFOUND;
        CLOSE okc_chrv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_pavv_rec.CLE_ID IS NOT NULL)
      THEN
        OPEN okc_clev_pk_csr(p_pavv_rec.CLE_ID);
        FETCH okc_clev_pk_csr INTO l_okc_clev_pk;
        l_row_notfound := okc_clev_pk_csr%NOTFOUND;
        CLOSE okc_clev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_pavv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN pavv_rec_type,
    p_to	IN OUT NOCOPY pav_rec_type
  ) IS
  BEGIN
 ---------------

 OKC_SPLIT2_PAV_PVT.migrate(p_from , p_to);
------------
  END migrate;



  PROCEDURE migrate (
    p_from	IN pav_rec_type,
    p_to	IN OUT NOCOPY pavv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.flex_title := p_from.flex_title;
    p_to.pricing_context := p_from.pricing_context;
    p_to.pricing_attribute1 := p_from.pricing_attribute1;
    p_to.chr_id := p_from.chr_id;
    p_to.pricing_attribute2 := p_from.pricing_attribute2;
    p_to.cle_id := p_from.cle_id;
    p_to.pricing_attribute3 := p_from.pricing_attribute3;
    p_to.pricing_attribute4 := p_from.pricing_attribute4;
    p_to.pricing_attribute5 := p_from.pricing_attribute5;
    p_to.pricing_attribute6 := p_from.pricing_attribute6;
    p_to.pricing_attribute7 := p_from.pricing_attribute7;
    p_to.pricing_attribute8 := p_from.pricing_attribute8;
    p_to.pricing_attribute9 := p_from.pricing_attribute9;
    p_to.pricing_attribute10 := p_from.pricing_attribute10;
    p_to.pricing_attribute11 := p_from.pricing_attribute11;
    p_to.pricing_attribute12 := p_from.pricing_attribute12;
    p_to.pricing_attribute13 := p_from.pricing_attribute13;
    p_to.pricing_attribute14 := p_from.pricing_attribute14;
    p_to.pricing_attribute15 := p_from.pricing_attribute15;
    p_to.pricing_attribute16 := p_from.pricing_attribute16;
    p_to.pricing_attribute17 := p_from.pricing_attribute17;
    p_to.pricing_attribute18 := p_from.pricing_attribute18;
    p_to.pricing_attribute19 := p_from.pricing_attribute19;
    p_to.pricing_attribute20 := p_from.pricing_attribute20;
    p_to.pricing_attribute21 := p_from.pricing_attribute21;
    p_to.pricing_attribute22 := p_from.pricing_attribute22;
    p_to.pricing_attribute23 := p_from.pricing_attribute23;
    p_to.pricing_attribute24 := p_from.pricing_attribute24;
    p_to.pricing_attribute25 := p_from.pricing_attribute25;
    p_to.pricing_attribute26 := p_from.pricing_attribute26;
    p_to.pricing_attribute27 := p_from.pricing_attribute27;
    p_to.pricing_attribute28 := p_from.pricing_attribute28;
    p_to.pricing_attribute29 := p_from.pricing_attribute29;
    p_to.pricing_attribute30 := p_from.pricing_attribute30;
    p_to.pricing_attribute31 := p_from.pricing_attribute31;
    p_to.pricing_attribute32 := p_from.pricing_attribute32;
    p_to.pricing_attribute33 := p_from.pricing_attribute33;
    p_to.pricing_attribute34 := p_from.pricing_attribute34;
    p_to.pricing_attribute35 := p_from.pricing_attribute35;
    p_to.pricing_attribute36 := p_from.pricing_attribute36;
    p_to.pricing_attribute37 := p_from.pricing_attribute37;
    p_to.pricing_attribute38 := p_from.pricing_attribute38;
    p_to.pricing_attribute39 := p_from.pricing_attribute39;
    p_to.pricing_attribute40 := p_from.pricing_attribute40;
    p_to.pricing_attribute41 := p_from.pricing_attribute41;
    p_to.pricing_attribute42 := p_from.pricing_attribute42;
    p_to.pricing_attribute43 := p_from.pricing_attribute43;
    p_to.pricing_attribute44 := p_from.pricing_attribute44;
    p_to.pricing_attribute45 := p_from.pricing_attribute45;
    p_to.pricing_attribute46 := p_from.pricing_attribute46;
    p_to.pricing_attribute47 := p_from.pricing_attribute47;
    p_to.pricing_attribute48 := p_from.pricing_attribute48;
    p_to.pricing_attribute49 := p_from.pricing_attribute49;
    p_to.pricing_attribute50 := p_from.pricing_attribute50;
    p_to.pricing_attribute51 := p_from.pricing_attribute51;
    p_to.pricing_attribute52 := p_from.pricing_attribute52;
    p_to.pricing_attribute53 := p_from.pricing_attribute53;
    p_to.pricing_attribute54 := p_from.pricing_attribute54;
    p_to.pricing_attribute55 := p_from.pricing_attribute55;
    p_to.pricing_attribute56 := p_from.pricing_attribute56;
    p_to.pricing_attribute57 := p_from.pricing_attribute57;
    p_to.pricing_attribute58 := p_from.pricing_attribute58;
    p_to.pricing_attribute59 := p_from.pricing_attribute59;
    p_to.pricing_attribute60 := p_from.pricing_attribute60;
    p_to.pricing_attribute61 := p_from.pricing_attribute61;
    p_to.pricing_attribute62 := p_from.pricing_attribute62;
    p_to.pricing_attribute63 := p_from.pricing_attribute63;
    p_to.pricing_attribute64 := p_from.pricing_attribute64;
    p_to.pricing_attribute65 := p_from.pricing_attribute65;
    p_to.pricing_attribute66 := p_from.pricing_attribute66;
    p_to.pricing_attribute67 := p_from.pricing_attribute67;
    p_to.pricing_attribute68 := p_from.pricing_attribute68;
    p_to.pricing_attribute69 := p_from.pricing_attribute69;
    p_to.pricing_attribute70 := p_from.pricing_attribute70;
    p_to.pricing_attribute71 := p_from.pricing_attribute71;
    p_to.pricing_attribute72 := p_from.pricing_attribute72;
    p_to.pricing_attribute73 := p_from.pricing_attribute73;
    p_to.pricing_attribute74 := p_from.pricing_attribute74;
    p_to.pricing_attribute75 := p_from.pricing_attribute75;
    p_to.pricing_attribute76 := p_from.pricing_attribute76;
    p_to.pricing_attribute77 := p_from.pricing_attribute77;
    p_to.pricing_attribute78 := p_from.pricing_attribute78;
    p_to.pricing_attribute79 := p_from.pricing_attribute79;
    p_to.pricing_attribute80 := p_from.pricing_attribute80;
    p_to.pricing_attribute81 := p_from.pricing_attribute81;
    p_to.pricing_attribute82 := p_from.pricing_attribute82;
    p_to.pricing_attribute83 := p_from.pricing_attribute83;
    p_to.pricing_attribute84 := p_from.pricing_attribute84;
    p_to.pricing_attribute85 := p_from.pricing_attribute85;
    p_to.pricing_attribute86 := p_from.pricing_attribute86;
    p_to.pricing_attribute87 := p_from.pricing_attribute87;
    p_to.pricing_attribute88 := p_from.pricing_attribute88;
    p_to.pricing_attribute89 := p_from.pricing_attribute89;
    p_to.pricing_attribute90 := p_from.pricing_attribute90;
    p_to.pricing_attribute91 := p_from.pricing_attribute91;
    p_to.pricing_attribute92 := p_from.pricing_attribute92;
    p_to.pricing_attribute93 := p_from.pricing_attribute93;
    p_to.pricing_attribute94 := p_from.pricing_attribute94;
    p_to.pricing_attribute95 := p_from.pricing_attribute95;
    p_to.pricing_attribute96 := p_from.pricing_attribute96;
    p_to.pricing_attribute97 := p_from.pricing_attribute97;
    p_to.pricing_attribute98 := p_from.pricing_attribute98;
    p_to.pricing_attribute99 := p_from.pricing_attribute99;
    p_to.pricing_attribute100 := p_from.pricing_attribute100;
    p_to.qualifier_context := p_from.qualifier_context;
    p_to.qualifier_attribute1 := p_from.qualifier_attribute1;
    p_to.qualifier_attribute2 := p_from.qualifier_attribute2;
    p_to.created_by := p_from.created_by;
    p_to.qualifier_attribute3 := p_from.qualifier_attribute3;
    p_to.creation_date := p_from.creation_date;
    p_to.qualifier_attribute4 := p_from.qualifier_attribute4;
    p_to.qualifier_attribute5 := p_from.qualifier_attribute5;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.qualifier_attribute6 := p_from.qualifier_attribute6;
    p_to.last_update_date := p_from.last_update_date;
    p_to.qualifier_attribute7 := p_from.qualifier_attribute7;
    p_to.qualifier_attribute8 := p_from.qualifier_attribute8;
    p_to.qualifier_attribute9 := p_from.qualifier_attribute9;
    p_to.qualifier_attribute10 := p_from.qualifier_attribute10;
    p_to.qualifier_attribute11 := p_from.qualifier_attribute11;
    p_to.qualifier_attribute12 := p_from.qualifier_attribute12;
    p_to.qualifier_attribute13 := p_from.qualifier_attribute13;
    p_to.qualifier_attribute14 := p_from.qualifier_attribute14;
    p_to.qualifier_attribute15 := p_from.qualifier_attribute15;
    p_to.qualifier_attribute16 := p_from.qualifier_attribute16;
    p_to.qualifier_attribute17 := p_from.qualifier_attribute17;
    p_to.qualifier_attribute18 := p_from.qualifier_attribute18;
    p_to.qualifier_attribute19 := p_from.qualifier_attribute19;
    p_to.qualifier_attribute20 := p_from.qualifier_attribute20;
    p_to.qualifier_attribute21 := p_from.qualifier_attribute21;
    p_to.qualifier_attribute22 := p_from.qualifier_attribute22;
    p_to.qualifier_attribute23 := p_from.qualifier_attribute23;
    p_to.qualifier_attribute24 := p_from.qualifier_attribute24;
    p_to.qualifier_attribute25 := p_from.qualifier_attribute25;
    p_to.qualifier_attribute26 := p_from.qualifier_attribute26;
    p_to.qualifier_attribute27 := p_from.qualifier_attribute27;
    p_to.qualifier_attribute28 := p_from.qualifier_attribute28;
    p_to.qualifier_attribute29 := p_from.qualifier_attribute29;
    p_to.qualifier_attribute30 := p_from.qualifier_attribute30;
    p_to.qualifier_attribute31 := p_from.qualifier_attribute31;
    p_to.qualifier_attribute32 := p_from.qualifier_attribute32;
    p_to.qualifier_attribute33 := p_from.qualifier_attribute33;
    p_to.qualifier_attribute34 := p_from.qualifier_attribute34;
    p_to.qualifier_attribute35 := p_from.qualifier_attribute35;
    p_to.qualifier_attribute36 := p_from.qualifier_attribute36;
    p_to.qualifier_attribute37 := p_from.qualifier_attribute37;
    p_to.qualifier_attribute38 := p_from.qualifier_attribute38;
    p_to.qualifier_attribute39 := p_from.qualifier_attribute39;
    p_to.qualifier_attribute40 := p_from.qualifier_attribute40;
    p_to.qualifier_attribute41 := p_from.qualifier_attribute41;
    p_to.qualifier_attribute42 := p_from.qualifier_attribute42;
    p_to.qualifier_attribute43 := p_from.qualifier_attribute43;
    p_to.qualifier_attribute44 := p_from.qualifier_attribute44;
    p_to.qualifier_attribute45 := p_from.qualifier_attribute45;
    p_to.qualifier_attribute46 := p_from.qualifier_attribute46;
    p_to.qualifier_attribute47 := p_from.qualifier_attribute47;
    p_to.qualifier_attribute48 := p_from.qualifier_attribute48;
    p_to.qualifier_attribute49 := p_from.qualifier_attribute49;
    p_to.qualifier_attribute50 := p_from.qualifier_attribute50;
    p_to.qualifier_attribute51 := p_from.qualifier_attribute51;
    p_to.qualifier_attribute52 := p_from.qualifier_attribute52;
    p_to.qualifier_attribute53 := p_from.qualifier_attribute53;
    p_to.qualifier_attribute54 := p_from.qualifier_attribute54;
    p_to.qualifier_attribute55 := p_from.qualifier_attribute55;
    p_to.qualifier_attribute56 := p_from.qualifier_attribute56;
    p_to.qualifier_attribute57 := p_from.qualifier_attribute57;
    p_to.qualifier_attribute58 := p_from.qualifier_attribute58;
    p_to.qualifier_attribute59 := p_from.qualifier_attribute59;
    p_to.qualifier_attribute60 := p_from.qualifier_attribute60;
    p_to.qualifier_attribute61 := p_from.qualifier_attribute61;
    p_to.qualifier_attribute62 := p_from.qualifier_attribute62;
    p_to.qualifier_attribute63 := p_from.qualifier_attribute63;
    p_to.qualifier_attribute64 := p_from.qualifier_attribute64;
    p_to.qualifier_attribute65 := p_from.qualifier_attribute65;
    p_to.qualifier_attribute66 := p_from.qualifier_attribute66;
    p_to.qualifier_attribute67 := p_from.qualifier_attribute67;
    p_to.qualifier_attribute68 := p_from.qualifier_attribute68;
    p_to.qualifier_attribute69 := p_from.qualifier_attribute69;
    p_to.qualifier_attribute70 := p_from.qualifier_attribute70;
    p_to.qualifier_attribute71 := p_from.qualifier_attribute71;
    p_to.qualifier_attribute72 := p_from.qualifier_attribute72;
    p_to.qualifier_attribute73 := p_from.qualifier_attribute73;
    p_to.qualifier_attribute74 := p_from.qualifier_attribute74;
    p_to.qualifier_attribute75 := p_from.qualifier_attribute75;
    p_to.qualifier_attribute76 := p_from.qualifier_attribute76;
    p_to.qualifier_attribute77 := p_from.qualifier_attribute77;
    p_to.qualifier_attribute78 := p_from.qualifier_attribute78;
    p_to.qualifier_attribute79 := p_from.qualifier_attribute79;
    p_to.qualifier_attribute80 := p_from.qualifier_attribute80;
    p_to.qualifier_attribute81 := p_from.qualifier_attribute81;
    p_to.qualifier_attribute82 := p_from.qualifier_attribute82;
    p_to.qualifier_attribute83 := p_from.qualifier_attribute83;
    p_to.qualifier_attribute84 := p_from.qualifier_attribute84;
    p_to.qualifier_attribute85 := p_from.qualifier_attribute85;
    p_to.qualifier_attribute86 := p_from.qualifier_attribute86;
    p_to.qualifier_attribute87 := p_from.qualifier_attribute87;
    p_to.qualifier_attribute88 := p_from.qualifier_attribute88;
    p_to.qualifier_attribute89 := p_from.qualifier_attribute89;
    p_to.qualifier_attribute90 := p_from.qualifier_attribute90;
    p_to.qualifier_attribute91 := p_from.qualifier_attribute91;
    p_to.qualifier_attribute92 := p_from.qualifier_attribute92;
    p_to.qualifier_attribute93 := p_from.qualifier_attribute93;
    p_to.qualifier_attribute94 := p_from.qualifier_attribute94;
    p_to.qualifier_attribute95 := p_from.qualifier_attribute95;
    p_to.qualifier_attribute96 := p_from.qualifier_attribute96;
    p_to.qualifier_attribute97 := p_from.qualifier_attribute97;
    p_to.qualifier_attribute98 := p_from.qualifier_attribute98;
    p_to.qualifier_attribute99 := p_from.qualifier_attribute99;
    p_to.qualifier_attribute100 := p_from.qualifier_attribute100;
    p_to.last_update_login := p_from.last_update_login;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date:= p_from.program_update_date;
    p_to.request_id := p_from.request_id;
    p_to.object_version_number := p_from.object_version_number;
    END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- validate_row for:OKC_PRICE_ATT_VALUES_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pavv_rec                     pavv_rec_type := p_pavv_rec;
    l_pav_rec                      pav_rec_type;
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
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_pavv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_pavv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
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
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:PAVV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pavv_tbl.COUNT > 0) THEN
      i := p_pavv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pavv_rec                     => p_pavv_tbl(i));
        EXIT WHEN (i = p_pavv_tbl.LAST);
        i := p_pavv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- insert_row for:OKC_PRICE_ATT_VALUES --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pav_rec                      IN pav_rec_type,
    x_pav_rec                      OUT NOCOPY pav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALUES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pav_rec                      pav_rec_type := p_pav_rec;
    l_def_pav_rec                  pav_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ATT_VALUES --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_pav_rec IN  pav_rec_type,
      x_pav_rec OUT NOCOPY pav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pav_rec := p_pav_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_pav_rec,                         -- IN
      l_pav_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_PRICE_ATT_VALUES(
        id,
        flex_title,
        pricing_context,
        pricing_attribute1,
        chr_id,
        pricing_attribute2,
        cle_id,
        pricing_attribute3,
        pricing_attribute4,
        pricing_attribute5,
        pricing_attribute6,
        pricing_attribute7,
        pricing_attribute8,
        pricing_attribute9,
        pricing_attribute10,
        pricing_attribute11,
        pricing_attribute12,
        pricing_attribute13,
        pricing_attribute14,
        pricing_attribute15,
        pricing_attribute16,
        pricing_attribute17,
        pricing_attribute18,
        pricing_attribute19,
        pricing_attribute20,
        pricing_attribute21,
        pricing_attribute22,
        pricing_attribute23,
        pricing_attribute24,
        pricing_attribute25,
        pricing_attribute26,
        pricing_attribute27,
        pricing_attribute28,
        pricing_attribute29,
        pricing_attribute30,
        pricing_attribute31,
        pricing_attribute32,
        pricing_attribute33,
        pricing_attribute34,
        pricing_attribute35,
        pricing_attribute36,
        pricing_attribute37,
        pricing_attribute38,
        pricing_attribute39,
        pricing_attribute40,
        pricing_attribute41,
        pricing_attribute42,
        pricing_attribute43,
        pricing_attribute44,
        pricing_attribute45,
        pricing_attribute46,
        pricing_attribute47,
        pricing_attribute48,
        pricing_attribute49,
        pricing_attribute50,
        pricing_attribute51,
        pricing_attribute52,
        pricing_attribute53,
        pricing_attribute54,
        pricing_attribute55,
        pricing_attribute56,
        pricing_attribute57,
        pricing_attribute58,
        pricing_attribute59,
        pricing_attribute60,
        pricing_attribute61,
        pricing_attribute62,
        pricing_attribute63,
        pricing_attribute64,
        pricing_attribute65,
        pricing_attribute66,
        pricing_attribute67,
        pricing_attribute68,
        pricing_attribute69,
        pricing_attribute70,
        pricing_attribute71,
        pricing_attribute72,
        pricing_attribute73,
        pricing_attribute74,
        pricing_attribute75,
        pricing_attribute76,
        pricing_attribute77,
        pricing_attribute78,
        pricing_attribute79,
        pricing_attribute80,
        pricing_attribute81,
        pricing_attribute82,
        pricing_attribute83,
        pricing_attribute84,
        pricing_attribute85,
        pricing_attribute86,
        pricing_attribute87,
        pricing_attribute88,
        pricing_attribute89,
        pricing_attribute90,
        pricing_attribute91,
        pricing_attribute92,
        pricing_attribute93,
        pricing_attribute94,
        pricing_attribute95,
        pricing_attribute96,
        pricing_attribute97,
        pricing_attribute98,
        pricing_attribute99,
        pricing_attribute100,
        qualifier_context,
        qualifier_attribute1,
        qualifier_attribute2,
        created_by,
        qualifier_attribute3,
        creation_date,
        qualifier_attribute4,
        qualifier_attribute5,
        last_updated_by,
        qualifier_attribute6,
        last_update_date,
        qualifier_attribute7,
        qualifier_attribute8,
        qualifier_attribute9,
        qualifier_attribute10,
        qualifier_attribute11,
        qualifier_attribute12,
        qualifier_attribute13,
        qualifier_attribute14,
        qualifier_attribute15,
        qualifier_attribute16,
        qualifier_attribute17,
        qualifier_attribute18,
        qualifier_attribute19,
        qualifier_attribute20,
        qualifier_attribute21,
        qualifier_attribute22,
        qualifier_attribute23,
        qualifier_attribute24,
        qualifier_attribute25,
        qualifier_attribute26,
        qualifier_attribute27,
        qualifier_attribute28,
        qualifier_attribute29,
        qualifier_attribute30,
        qualifier_attribute31,
        qualifier_attribute32,
        qualifier_attribute33,
        qualifier_attribute34,
        qualifier_attribute35,
        qualifier_attribute36,
        qualifier_attribute37,
        qualifier_attribute38,
        qualifier_attribute39,
        qualifier_attribute40,
        qualifier_attribute41,
        qualifier_attribute42,
        qualifier_attribute43,
        qualifier_attribute44,
        qualifier_attribute45,
        qualifier_attribute46,
        qualifier_attribute47,
        qualifier_attribute48,
        qualifier_attribute49,
        qualifier_attribute50,
        qualifier_attribute51,
        qualifier_attribute52,
        qualifier_attribute53,
        qualifier_attribute54,
        qualifier_attribute55,
        qualifier_attribute56,
        qualifier_attribute57,
        qualifier_attribute58,
        qualifier_attribute59,
        qualifier_attribute60,
        qualifier_attribute61,
        qualifier_attribute62,
        qualifier_attribute63,
        qualifier_attribute64,
        qualifier_attribute65,
        qualifier_attribute66,
        qualifier_attribute67,
        qualifier_attribute68,
        qualifier_attribute69,
        qualifier_attribute70,
        qualifier_attribute71,
        qualifier_attribute72,
        qualifier_attribute73,
        qualifier_attribute74,
        qualifier_attribute75,
        qualifier_attribute76,
        qualifier_attribute77,
        qualifier_attribute78,
        qualifier_attribute79,
        qualifier_attribute80,
        qualifier_attribute81,
        qualifier_attribute82,
        qualifier_attribute83,
        qualifier_attribute84,
        qualifier_attribute85,
        qualifier_attribute86,
        qualifier_attribute87,
        qualifier_attribute88,
        qualifier_attribute89,
        qualifier_attribute90,
        qualifier_attribute91,
        qualifier_attribute92,
        qualifier_attribute93,
        qualifier_attribute94,
        qualifier_attribute95,
        qualifier_attribute96,
        qualifier_attribute97,
        qualifier_attribute98,
        qualifier_attribute99,
        qualifier_attribute100,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
       object_version_number)
       VALUES (
        l_pav_rec.id,
        l_pav_rec.flex_title,
        l_pav_rec.pricing_context,
        l_pav_rec.pricing_attribute1,
        l_pav_rec.chr_id,
        l_pav_rec.pricing_attribute2,
        l_pav_rec.cle_id,
        l_pav_rec.pricing_attribute3,
        l_pav_rec.pricing_attribute4,
        l_pav_rec.pricing_attribute5,
        l_pav_rec.pricing_attribute6,
        l_pav_rec.pricing_attribute7,
        l_pav_rec.pricing_attribute8,
        l_pav_rec.pricing_attribute9,
        l_pav_rec.pricing_attribute10,
        l_pav_rec.pricing_attribute11,
        l_pav_rec.pricing_attribute12,
        l_pav_rec.pricing_attribute13,
        l_pav_rec.pricing_attribute14,
        l_pav_rec.pricing_attribute15,
        l_pav_rec.pricing_attribute16,
        l_pav_rec.pricing_attribute17,
        l_pav_rec.pricing_attribute18,
        l_pav_rec.pricing_attribute19,
        l_pav_rec.pricing_attribute20,
        l_pav_rec.pricing_attribute21,
        l_pav_rec.pricing_attribute22,
        l_pav_rec.pricing_attribute23,
        l_pav_rec.pricing_attribute24,
        l_pav_rec.pricing_attribute25,
        l_pav_rec.pricing_attribute26,
        l_pav_rec.pricing_attribute27,
        l_pav_rec.pricing_attribute28,
        l_pav_rec.pricing_attribute29,
        l_pav_rec.pricing_attribute30,
        l_pav_rec.pricing_attribute31,
        l_pav_rec.pricing_attribute32,
        l_pav_rec.pricing_attribute33,
        l_pav_rec.pricing_attribute34,
        l_pav_rec.pricing_attribute35,
        l_pav_rec.pricing_attribute36,
        l_pav_rec.pricing_attribute37,
        l_pav_rec.pricing_attribute38,
        l_pav_rec.pricing_attribute39,
        l_pav_rec.pricing_attribute40,
        l_pav_rec.pricing_attribute41,
        l_pav_rec.pricing_attribute42,
        l_pav_rec.pricing_attribute43,
        l_pav_rec.pricing_attribute44,
        l_pav_rec.pricing_attribute45,
        l_pav_rec.pricing_attribute46,
        l_pav_rec.pricing_attribute47,
        l_pav_rec.pricing_attribute48,
        l_pav_rec.pricing_attribute49,
        l_pav_rec.pricing_attribute50,
        l_pav_rec.pricing_attribute51,
        l_pav_rec.pricing_attribute52,
        l_pav_rec.pricing_attribute53,
        l_pav_rec.pricing_attribute54,
        l_pav_rec.pricing_attribute55,
        l_pav_rec.pricing_attribute56,
        l_pav_rec.pricing_attribute57,
        l_pav_rec.pricing_attribute58,
        l_pav_rec.pricing_attribute59,
        l_pav_rec.pricing_attribute60,
        l_pav_rec.pricing_attribute61,
        l_pav_rec.pricing_attribute62,
        l_pav_rec.pricing_attribute63,
        l_pav_rec.pricing_attribute64,
        l_pav_rec.pricing_attribute65,
        l_pav_rec.pricing_attribute66,
        l_pav_rec.pricing_attribute67,
        l_pav_rec.pricing_attribute68,
        l_pav_rec.pricing_attribute69,
        l_pav_rec.pricing_attribute70,
        l_pav_rec.pricing_attribute71,
        l_pav_rec.pricing_attribute72,
        l_pav_rec.pricing_attribute73,
        l_pav_rec.pricing_attribute74,
        l_pav_rec.pricing_attribute75,
        l_pav_rec.pricing_attribute76,
        l_pav_rec.pricing_attribute77,
        l_pav_rec.pricing_attribute78,
        l_pav_rec.pricing_attribute79,
        l_pav_rec.pricing_attribute80,
        l_pav_rec.pricing_attribute81,
        l_pav_rec.pricing_attribute82,
        l_pav_rec.pricing_attribute83,
        l_pav_rec.pricing_attribute84,
        l_pav_rec.pricing_attribute85,
        l_pav_rec.pricing_attribute86,
        l_pav_rec.pricing_attribute87,
        l_pav_rec.pricing_attribute88,
        l_pav_rec.pricing_attribute89,
        l_pav_rec.pricing_attribute90,
        l_pav_rec.pricing_attribute91,
        l_pav_rec.pricing_attribute92,
        l_pav_rec.pricing_attribute93,
        l_pav_rec.pricing_attribute94,
        l_pav_rec.pricing_attribute95,
        l_pav_rec.pricing_attribute96,
        l_pav_rec.pricing_attribute97,
        l_pav_rec.pricing_attribute98,
        l_pav_rec.pricing_attribute99,
        l_pav_rec.pricing_attribute100,
        l_pav_rec.qualifier_context,
        l_pav_rec.qualifier_attribute1,
        l_pav_rec.qualifier_attribute2,
        l_pav_rec.created_by,
        l_pav_rec.qualifier_attribute3,
        l_pav_rec.creation_date,
        l_pav_rec.qualifier_attribute4,
        l_pav_rec.qualifier_attribute5,
        l_pav_rec.last_updated_by,
        l_pav_rec.qualifier_attribute6,
        l_pav_rec.last_update_date,
        l_pav_rec.qualifier_attribute7,
        l_pav_rec.qualifier_attribute8,
        l_pav_rec.qualifier_attribute9,
        l_pav_rec.qualifier_attribute10,
        l_pav_rec.qualifier_attribute11,
        l_pav_rec.qualifier_attribute12,
        l_pav_rec.qualifier_attribute13,
        l_pav_rec.qualifier_attribute14,
        l_pav_rec.qualifier_attribute15,
        l_pav_rec.qualifier_attribute16,
        l_pav_rec.qualifier_attribute17,
        l_pav_rec.qualifier_attribute18,
        l_pav_rec.qualifier_attribute19,
        l_pav_rec.qualifier_attribute20,
        l_pav_rec.qualifier_attribute21,
        l_pav_rec.qualifier_attribute22,
        l_pav_rec.qualifier_attribute23,
        l_pav_rec.qualifier_attribute24,
        l_pav_rec.qualifier_attribute25,
        l_pav_rec.qualifier_attribute26,
        l_pav_rec.qualifier_attribute27,
        l_pav_rec.qualifier_attribute28,
        l_pav_rec.qualifier_attribute29,
        l_pav_rec.qualifier_attribute30,
        l_pav_rec.qualifier_attribute31,
        l_pav_rec.qualifier_attribute32,
        l_pav_rec.qualifier_attribute33,
        l_pav_rec.qualifier_attribute34,
        l_pav_rec.qualifier_attribute35,
        l_pav_rec.qualifier_attribute36,
        l_pav_rec.qualifier_attribute37,
        l_pav_rec.qualifier_attribute38,
        l_pav_rec.qualifier_attribute39,
        l_pav_rec.qualifier_attribute40,
        l_pav_rec.qualifier_attribute41,
        l_pav_rec.qualifier_attribute42,
        l_pav_rec.qualifier_attribute43,
        l_pav_rec.qualifier_attribute44,
        l_pav_rec.qualifier_attribute45,
        l_pav_rec.qualifier_attribute46,
        l_pav_rec.qualifier_attribute47,
        l_pav_rec.qualifier_attribute48,
        l_pav_rec.qualifier_attribute49,
        l_pav_rec.qualifier_attribute50,
        l_pav_rec.qualifier_attribute51,
        l_pav_rec.qualifier_attribute52,
        l_pav_rec.qualifier_attribute53,
        l_pav_rec.qualifier_attribute54,
        l_pav_rec.qualifier_attribute55,
        l_pav_rec.qualifier_attribute56,
        l_pav_rec.qualifier_attribute57,
        l_pav_rec.qualifier_attribute58,
        l_pav_rec.qualifier_attribute59,
        l_pav_rec.qualifier_attribute60,
        l_pav_rec.qualifier_attribute61,
        l_pav_rec.qualifier_attribute62,
        l_pav_rec.qualifier_attribute63,
        l_pav_rec.qualifier_attribute64,
        l_pav_rec.qualifier_attribute65,
        l_pav_rec.qualifier_attribute66,
        l_pav_rec.qualifier_attribute67,
        l_pav_rec.qualifier_attribute68,
        l_pav_rec.qualifier_attribute69,
        l_pav_rec.qualifier_attribute70,
        l_pav_rec.qualifier_attribute71,
        l_pav_rec.qualifier_attribute72,
        l_pav_rec.qualifier_attribute73,
        l_pav_rec.qualifier_attribute74,
        l_pav_rec.qualifier_attribute75,
        l_pav_rec.qualifier_attribute76,
        l_pav_rec.qualifier_attribute77,
        l_pav_rec.qualifier_attribute78,
        l_pav_rec.qualifier_attribute79,
        l_pav_rec.qualifier_attribute80,
        l_pav_rec.qualifier_attribute81,
        l_pav_rec.qualifier_attribute82,
        l_pav_rec.qualifier_attribute83,
        l_pav_rec.qualifier_attribute84,
        l_pav_rec.qualifier_attribute85,
        l_pav_rec.qualifier_attribute86,
        l_pav_rec.qualifier_attribute87,
        l_pav_rec.qualifier_attribute88,
        l_pav_rec.qualifier_attribute89,
        l_pav_rec.qualifier_attribute90,
        l_pav_rec.qualifier_attribute91,
        l_pav_rec.qualifier_attribute92,
        l_pav_rec.qualifier_attribute93,
        l_pav_rec.qualifier_attribute94,
        l_pav_rec.qualifier_attribute95,
        l_pav_rec.qualifier_attribute96,
        l_pav_rec.qualifier_attribute97,
        l_pav_rec.qualifier_attribute98,
        l_pav_rec.qualifier_attribute99,
        l_pav_rec.qualifier_attribute100,
        l_pav_rec.last_update_login,
        decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
        decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
        decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
        decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
        l_pav_rec.object_version_number);
-- Set OUT values
    x_pav_rec := l_pav_rec;
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
  END insert_row;
  -------------------------------------------
  -- insert_row for:OKC_PRICE_ATT_VALUES_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type,
    x_pavv_rec                     OUT NOCOPY pavv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pavv_rec                     pavv_rec_type;
    l_def_pavv_rec                 pavv_rec_type;
    l_pav_rec                      pav_rec_type;
    lx_pav_rec                     pav_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pavv_rec	IN pavv_rec_type
    ) RETURN pavv_rec_type IS
      l_pavv_rec	pavv_rec_type := p_pavv_rec;
    BEGIN
      l_pavv_rec.CREATION_DATE := SYSDATE;
      l_pavv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pavv_rec.LAST_UPDATE_DATE := l_pavv_rec.CREATION_DATE;
      l_pavv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pavv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pavv_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ATT_VALUES_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_pavv_rec IN  pavv_rec_type,
      x_pavv_rec OUT NOCOPY pavv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pavv_rec := p_pavv_rec;
      x_pavv_rec.OBJECT_VERSION_NUMBER := 1;
     RETURN(l_return_status);
    END Set_Attributes;
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
    l_pavv_rec := null_out_defaults(p_pavv_rec);
    -- Set primary key value
    l_pavv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_pavv_rec,                        -- IN
      l_def_pavv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pavv_rec := fill_who_columns(l_def_pavv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pavv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pavv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pavv_rec, l_pav_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pav_rec,
      lx_pav_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pav_rec, l_def_pavv_rec);
    -- Set OUT values
    x_pavv_rec := l_def_pavv_rec;
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
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:PAVV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type,
    x_pavv_tbl                     OUT NOCOPY pavv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pavv_tbl.COUNT > 0) THEN
      i := p_pavv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pavv_rec                     => p_pavv_tbl(i),
          x_pavv_rec                     => x_pavv_tbl(i));
        EXIT WHEN (i = p_pavv_tbl.LAST);
        i := p_pavv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- lock_row for:OKC_PRICE_ATT_VALUES --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pav_rec                      IN pav_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pav_rec IN pav_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_PRICE_ATT_VALUES
     WHERE ID = p_pav_rec.id
       AND OBJECT_VERSION_NUMBER = p_pav_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

 CURSOR  lchk_csr (p_pav_rec IN pav_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_PRICE_ATT_VALUES
    WHERE ID = p_pav_rec.id;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALUES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_PRICE_ATT_VALUES.OBJECT_VERSION_NUMBER%TYPE;
   lc_object_version_number      OKC_PRICE_ATT_VALUES.OBJECT_VERSION_NUMBER%TYPE;

    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_pav_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;
    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_pav_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF ( lc_row_notfound ) THEN
      OKC_API.set_message(G_APP_NAME,'OKC_FORM_RECORD_DELETED');
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pav_rec.object_version_number THEN
      OKC_API.set_message(G_APP_NAME,'OKC_FORM_RECORD_CHANGED');
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pav_rec.object_version_number THEN
      OKC_API.set_message(G_APP_NAME,'OKC_FORM_RECORD_CHANGED');
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_FND_APP,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
  END lock_row;
  -----------------------------------------
  -- lock_row for:OKC_PRICE_ATT_VALUES_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pav_rec                      pav_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_pavv_rec, l_pav_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pav_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
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
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:PAVV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pavv_tbl.COUNT > 0) THEN
      i := p_pavv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pavv_rec                     => p_pavv_tbl(i));
        EXIT WHEN (i = p_pavv_tbl.LAST);
        i := p_pavv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- update_row for:OKC_PRICE_ATT_VALUES --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pav_rec                      IN pav_rec_type,
    x_pav_rec                      OUT NOCOPY pav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALUES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pav_rec                      pav_rec_type := p_pav_rec;
    l_def_pav_rec                  pav_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pav_rec	IN pav_rec_type,
      x_pav_rec	OUT NOCOPY pav_rec_type
    ) RETURN VARCHAR2 IS
      l_pav_rec                      pav_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pav_rec := p_pav_rec;
      -- Get current database values
      l_pav_rec := get_rec(p_pav_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pav_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pav_rec.id := l_pav_rec.id;
      END IF;
      IF (x_pav_rec.flex_title = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.flex_title := l_pav_rec.flex_title;
      END IF;
      IF (x_pav_rec.pricing_context = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_context := l_pav_rec.pricing_context;
      END IF;
      IF (x_pav_rec.pricing_attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute1 := l_pav_rec.pricing_attribute1;
      END IF;
      IF (x_pav_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_pav_rec.chr_id := l_pav_rec.chr_id;
      END IF;
      IF (x_pav_rec.pricing_attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute2 := l_pav_rec.pricing_attribute2;
      END IF;
      IF (x_pav_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_pav_rec.cle_id := l_pav_rec.cle_id;
      END IF;
      IF (x_pav_rec.pricing_attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute3 := l_pav_rec.pricing_attribute3;
      END IF;
      IF (x_pav_rec.pricing_attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute4 := l_pav_rec.pricing_attribute4;
      END IF;
      IF (x_pav_rec.pricing_attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute5 := l_pav_rec.pricing_attribute5;
      END IF;
      IF (x_pav_rec.pricing_attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute6 := l_pav_rec.pricing_attribute6;
      END IF;
      IF (x_pav_rec.pricing_attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute7 := l_pav_rec.pricing_attribute7;
      END IF;
      IF (x_pav_rec.pricing_attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute8 := l_pav_rec.pricing_attribute8;
      END IF;
      IF (x_pav_rec.pricing_attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute9 := l_pav_rec.pricing_attribute9;
      END IF;
      IF (x_pav_rec.pricing_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute10 := l_pav_rec.pricing_attribute10;
      END IF;
      IF (x_pav_rec.pricing_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute11 := l_pav_rec.pricing_attribute11;
      END IF;
      IF (x_pav_rec.pricing_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute12 := l_pav_rec.pricing_attribute12;
      END IF;
      IF (x_pav_rec.pricing_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute13 := l_pav_rec.pricing_attribute13;
      END IF;
      IF (x_pav_rec.pricing_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute14 := l_pav_rec.pricing_attribute14;
      END IF;
      IF (x_pav_rec.pricing_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute15 := l_pav_rec.pricing_attribute15;
      END IF;
      IF (x_pav_rec.pricing_attribute16 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute16 := l_pav_rec.pricing_attribute16;
      END IF;
      IF (x_pav_rec.pricing_attribute17 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute17 := l_pav_rec.pricing_attribute17;
      END IF;
      IF (x_pav_rec.pricing_attribute18 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute18 := l_pav_rec.pricing_attribute18;
      END IF;
      IF (x_pav_rec.pricing_attribute19 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute19 := l_pav_rec.pricing_attribute19;
      END IF;
      IF (x_pav_rec.pricing_attribute20 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute20 := l_pav_rec.pricing_attribute20;
      END IF;
      IF (x_pav_rec.pricing_attribute21 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute21 := l_pav_rec.pricing_attribute21;
      END IF;
      IF (x_pav_rec.pricing_attribute22 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute22 := l_pav_rec.pricing_attribute22;
      END IF;
      IF (x_pav_rec.pricing_attribute23 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute23 := l_pav_rec.pricing_attribute23;
      END IF;
      IF (x_pav_rec.pricing_attribute24 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute24 := l_pav_rec.pricing_attribute24;
      END IF;
      IF (x_pav_rec.pricing_attribute25 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute25 := l_pav_rec.pricing_attribute25;
      END IF;
      IF (x_pav_rec.pricing_attribute26 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute26 := l_pav_rec.pricing_attribute26;
      END IF;
      IF (x_pav_rec.pricing_attribute27 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute27 := l_pav_rec.pricing_attribute27;
      END IF;
      IF (x_pav_rec.pricing_attribute28 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute28 := l_pav_rec.pricing_attribute28;
      END IF;
      IF (x_pav_rec.pricing_attribute29 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute29 := l_pav_rec.pricing_attribute29;
      END IF;
      IF (x_pav_rec.pricing_attribute30 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute30 := l_pav_rec.pricing_attribute30;
      END IF;
      IF (x_pav_rec.pricing_attribute31 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute31 := l_pav_rec.pricing_attribute31;
      END IF;
      IF (x_pav_rec.pricing_attribute32 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute32 := l_pav_rec.pricing_attribute32;
      END IF;
      IF (x_pav_rec.pricing_attribute33 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute33 := l_pav_rec.pricing_attribute33;
      END IF;
      IF (x_pav_rec.pricing_attribute34 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute34 := l_pav_rec.pricing_attribute34;
      END IF;
      IF (x_pav_rec.pricing_attribute35 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute35 := l_pav_rec.pricing_attribute35;
      END IF;
      IF (x_pav_rec.pricing_attribute36 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute36 := l_pav_rec.pricing_attribute36;
      END IF;
      IF (x_pav_rec.pricing_attribute37 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute37 := l_pav_rec.pricing_attribute37;
      END IF;
      IF (x_pav_rec.pricing_attribute38 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute38 := l_pav_rec.pricing_attribute38;
      END IF;
      IF (x_pav_rec.pricing_attribute39 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute39 := l_pav_rec.pricing_attribute39;
      END IF;
      IF (x_pav_rec.pricing_attribute40 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute40 := l_pav_rec.pricing_attribute40;
      END IF;
      IF (x_pav_rec.pricing_attribute41 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute41 := l_pav_rec.pricing_attribute41;
      END IF;
      IF (x_pav_rec.pricing_attribute42 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute42 := l_pav_rec.pricing_attribute42;
      END IF;
      IF (x_pav_rec.pricing_attribute43 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute43 := l_pav_rec.pricing_attribute43;
      END IF;
      IF (x_pav_rec.pricing_attribute44 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute44 := l_pav_rec.pricing_attribute44;
      END IF;
      IF (x_pav_rec.pricing_attribute45 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute45 := l_pav_rec.pricing_attribute45;
      END IF;
      IF (x_pav_rec.pricing_attribute46 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute46 := l_pav_rec.pricing_attribute46;
      END IF;
      IF (x_pav_rec.pricing_attribute47 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute47 := l_pav_rec.pricing_attribute47;
      END IF;
      IF (x_pav_rec.pricing_attribute48 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute48 := l_pav_rec.pricing_attribute48;
      END IF;
      IF (x_pav_rec.pricing_attribute49 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute49 := l_pav_rec.pricing_attribute49;
      END IF;
      IF (x_pav_rec.pricing_attribute50 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute50 := l_pav_rec.pricing_attribute50;
      END IF;
      IF (x_pav_rec.pricing_attribute51 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute51 := l_pav_rec.pricing_attribute51;
      END IF;
      IF (x_pav_rec.pricing_attribute52 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute52 := l_pav_rec.pricing_attribute52;
      END IF;
      IF (x_pav_rec.pricing_attribute53 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute53 := l_pav_rec.pricing_attribute53;
      END IF;
      IF (x_pav_rec.pricing_attribute54 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute54 := l_pav_rec.pricing_attribute54;
      END IF;
      IF (x_pav_rec.pricing_attribute55 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute55 := l_pav_rec.pricing_attribute55;
      END IF;
      IF (x_pav_rec.pricing_attribute56 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute56 := l_pav_rec.pricing_attribute56;
      END IF;
      IF (x_pav_rec.pricing_attribute57 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute57 := l_pav_rec.pricing_attribute57;
      END IF;
      IF (x_pav_rec.pricing_attribute58 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute58 := l_pav_rec.pricing_attribute58;
      END IF;
      IF (x_pav_rec.pricing_attribute59 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute59 := l_pav_rec.pricing_attribute59;
      END IF;
      IF (x_pav_rec.pricing_attribute60 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute60 := l_pav_rec.pricing_attribute60;
      END IF;
      IF (x_pav_rec.pricing_attribute61 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute61 := l_pav_rec.pricing_attribute61;
      END IF;
      IF (x_pav_rec.pricing_attribute62 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute62 := l_pav_rec.pricing_attribute62;
      END IF;
      IF (x_pav_rec.pricing_attribute63 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute63 := l_pav_rec.pricing_attribute63;
      END IF;
      IF (x_pav_rec.pricing_attribute64 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute64 := l_pav_rec.pricing_attribute64;
      END IF;
      IF (x_pav_rec.pricing_attribute65 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute65 := l_pav_rec.pricing_attribute65;
      END IF;
      IF (x_pav_rec.pricing_attribute66 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute66 := l_pav_rec.pricing_attribute66;
      END IF;
      IF (x_pav_rec.pricing_attribute67 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute67 := l_pav_rec.pricing_attribute67;
      END IF;
      IF (x_pav_rec.pricing_attribute68 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute68 := l_pav_rec.pricing_attribute68;
      END IF;
      IF (x_pav_rec.pricing_attribute69 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute69 := l_pav_rec.pricing_attribute69;
      END IF;
      IF (x_pav_rec.pricing_attribute70 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute70 := l_pav_rec.pricing_attribute70;
      END IF;
      IF (x_pav_rec.pricing_attribute71 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute71 := l_pav_rec.pricing_attribute71;
      END IF;
      IF (x_pav_rec.pricing_attribute72 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute72 := l_pav_rec.pricing_attribute72;
      END IF;
      IF (x_pav_rec.pricing_attribute73 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute73 := l_pav_rec.pricing_attribute73;
      END IF;
      IF (x_pav_rec.pricing_attribute74 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute74 := l_pav_rec.pricing_attribute74;
      END IF;
      IF (x_pav_rec.pricing_attribute75 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute75 := l_pav_rec.pricing_attribute75;
      END IF;
      IF (x_pav_rec.pricing_attribute76 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute76 := l_pav_rec.pricing_attribute76;
      END IF;
      IF (x_pav_rec.pricing_attribute77 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute77 := l_pav_rec.pricing_attribute77;
      END IF;
      IF (x_pav_rec.pricing_attribute78 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute78 := l_pav_rec.pricing_attribute78;
      END IF;
      IF (x_pav_rec.pricing_attribute79 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute79 := l_pav_rec.pricing_attribute79;
      END IF;
      IF (x_pav_rec.pricing_attribute80 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute80 := l_pav_rec.pricing_attribute80;
      END IF;
      IF (x_pav_rec.pricing_attribute81 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute81 := l_pav_rec.pricing_attribute81;
      END IF;
      IF (x_pav_rec.pricing_attribute82 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute82 := l_pav_rec.pricing_attribute82;
      END IF;
      IF (x_pav_rec.pricing_attribute83 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute83 := l_pav_rec.pricing_attribute83;
      END IF;
      IF (x_pav_rec.pricing_attribute84 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute84 := l_pav_rec.pricing_attribute84;
      END IF;
      IF (x_pav_rec.pricing_attribute85 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute85 := l_pav_rec.pricing_attribute85;
      END IF;
      IF (x_pav_rec.pricing_attribute86 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute86 := l_pav_rec.pricing_attribute86;
      END IF;
      IF (x_pav_rec.pricing_attribute87 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute87 := l_pav_rec.pricing_attribute87;
      END IF;
      IF (x_pav_rec.pricing_attribute88 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute88 := l_pav_rec.pricing_attribute88;
      END IF;
      IF (x_pav_rec.pricing_attribute89 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute89 := l_pav_rec.pricing_attribute89;
      END IF;
      IF (x_pav_rec.pricing_attribute90 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute90 := l_pav_rec.pricing_attribute90;
      END IF;
      IF (x_pav_rec.pricing_attribute91 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute91 := l_pav_rec.pricing_attribute91;
      END IF;
      IF (x_pav_rec.pricing_attribute92 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute92 := l_pav_rec.pricing_attribute92;
      END IF;
      IF (x_pav_rec.pricing_attribute93 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute93 := l_pav_rec.pricing_attribute93;
      END IF;
      IF (x_pav_rec.pricing_attribute94 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute94 := l_pav_rec.pricing_attribute94;
      END IF;
      IF (x_pav_rec.pricing_attribute95 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute95 := l_pav_rec.pricing_attribute95;
      END IF;
      IF (x_pav_rec.pricing_attribute96 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute96 := l_pav_rec.pricing_attribute96;
      END IF;
      IF (x_pav_rec.pricing_attribute97 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute97 := l_pav_rec.pricing_attribute97;
      END IF;
      IF (x_pav_rec.pricing_attribute98 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute98 := l_pav_rec.pricing_attribute98;
      END IF;
      IF (x_pav_rec.pricing_attribute99 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute99 := l_pav_rec.pricing_attribute99;
      END IF;
      IF (x_pav_rec.pricing_attribute100 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.pricing_attribute100 := l_pav_rec.pricing_attribute100;
      END IF;
      IF (x_pav_rec.qualifier_context = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_context := l_pav_rec.qualifier_context;
      END IF;
      IF (x_pav_rec.qualifier_attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute1 := l_pav_rec.qualifier_attribute1;
      END IF;
      IF (x_pav_rec.qualifier_attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute2 := l_pav_rec.qualifier_attribute2;
      END IF;
      IF (x_pav_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pav_rec.created_by := l_pav_rec.created_by;
      END IF;
      IF (x_pav_rec.qualifier_attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute3 := l_pav_rec.qualifier_attribute3;
      END IF;
      IF (x_pav_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pav_rec.creation_date := l_pav_rec.creation_date;
      END IF;
      IF (x_pav_rec.qualifier_attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute4 := l_pav_rec.qualifier_attribute4;
      END IF;
      IF (x_pav_rec.qualifier_attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute5 := l_pav_rec.qualifier_attribute5;
      END IF;
      IF (x_pav_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pav_rec.last_updated_by := l_pav_rec.last_updated_by;
      END IF;
      IF (x_pav_rec.qualifier_attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute6 := l_pav_rec.qualifier_attribute6;
      END IF;
      IF (x_pav_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pav_rec.last_update_date := l_pav_rec.last_update_date;
      END IF;
      IF (x_pav_rec.qualifier_attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute7 := l_pav_rec.qualifier_attribute7;
      END IF;
      IF (x_pav_rec.qualifier_attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute8 := l_pav_rec.qualifier_attribute8;
      END IF;
      IF (x_pav_rec.qualifier_attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute9 := l_pav_rec.qualifier_attribute9;
      END IF;
      IF (x_pav_rec.qualifier_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute10 := l_pav_rec.qualifier_attribute10;
      END IF;
      IF (x_pav_rec.qualifier_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute11 := l_pav_rec.qualifier_attribute11;
      END IF;
      IF (x_pav_rec.qualifier_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute12 := l_pav_rec.qualifier_attribute12;
      END IF;
      IF (x_pav_rec.qualifier_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute13 := l_pav_rec.qualifier_attribute13;
      END IF;
      IF (x_pav_rec.qualifier_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute14 := l_pav_rec.qualifier_attribute14;
      END IF;
      IF (x_pav_rec.qualifier_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute15 := l_pav_rec.qualifier_attribute15;
      END IF;
      IF (x_pav_rec.qualifier_attribute16 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute16 := l_pav_rec.qualifier_attribute16;
      END IF;
      IF (x_pav_rec.qualifier_attribute17 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute17 := l_pav_rec.qualifier_attribute17;
      END IF;
      IF (x_pav_rec.qualifier_attribute18 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute18 := l_pav_rec.qualifier_attribute18;
      END IF;
      IF (x_pav_rec.qualifier_attribute19 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute19 := l_pav_rec.qualifier_attribute19;
      END IF;
      IF (x_pav_rec.qualifier_attribute20 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute20 := l_pav_rec.qualifier_attribute20;
      END IF;
      IF (x_pav_rec.qualifier_attribute21 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute21 := l_pav_rec.qualifier_attribute21;
      END IF;
      IF (x_pav_rec.qualifier_attribute22 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute22 := l_pav_rec.qualifier_attribute22;
      END IF;
      IF (x_pav_rec.qualifier_attribute23 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute23 := l_pav_rec.qualifier_attribute23;
      END IF;
      IF (x_pav_rec.qualifier_attribute24 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute24 := l_pav_rec.qualifier_attribute24;
      END IF;
      IF (x_pav_rec.qualifier_attribute25 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute25 := l_pav_rec.qualifier_attribute25;
      END IF;
      IF (x_pav_rec.qualifier_attribute26 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute26 := l_pav_rec.qualifier_attribute26;
      END IF;
      IF (x_pav_rec.qualifier_attribute27 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute27 := l_pav_rec.qualifier_attribute27;
      END IF;
      IF (x_pav_rec.qualifier_attribute28 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute28 := l_pav_rec.qualifier_attribute28;
      END IF;
      IF (x_pav_rec.qualifier_attribute29 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute29 := l_pav_rec.qualifier_attribute29;
      END IF;
      IF (x_pav_rec.qualifier_attribute30 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute30 := l_pav_rec.qualifier_attribute30;
      END IF;
      IF (x_pav_rec.qualifier_attribute31 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute31 := l_pav_rec.qualifier_attribute31;
      END IF;
      IF (x_pav_rec.qualifier_attribute32 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute32 := l_pav_rec.qualifier_attribute32;
      END IF;
      IF (x_pav_rec.qualifier_attribute33 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute33 := l_pav_rec.qualifier_attribute33;
      END IF;
      IF (x_pav_rec.qualifier_attribute34 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute34 := l_pav_rec.qualifier_attribute34;
      END IF;
      IF (x_pav_rec.qualifier_attribute35 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute35 := l_pav_rec.qualifier_attribute35;
      END IF;
      IF (x_pav_rec.qualifier_attribute36 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute36 := l_pav_rec.qualifier_attribute36;
      END IF;
      IF (x_pav_rec.qualifier_attribute37 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute37 := l_pav_rec.qualifier_attribute37;
      END IF;
      IF (x_pav_rec.qualifier_attribute38 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute38 := l_pav_rec.qualifier_attribute38;
      END IF;
      IF (x_pav_rec.qualifier_attribute39 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute39 := l_pav_rec.qualifier_attribute39;
      END IF;
      IF (x_pav_rec.qualifier_attribute40 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute40 := l_pav_rec.qualifier_attribute40;
      END IF;
      IF (x_pav_rec.qualifier_attribute41 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute41 := l_pav_rec.qualifier_attribute41;
      END IF;
      IF (x_pav_rec.qualifier_attribute42 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute42 := l_pav_rec.qualifier_attribute42;
      END IF;
      IF (x_pav_rec.qualifier_attribute43 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute43 := l_pav_rec.qualifier_attribute43;
      END IF;
      IF (x_pav_rec.qualifier_attribute44 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute44 := l_pav_rec.qualifier_attribute44;
      END IF;
      IF (x_pav_rec.qualifier_attribute45 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute45 := l_pav_rec.qualifier_attribute45;
      END IF;
      IF (x_pav_rec.qualifier_attribute46 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute46 := l_pav_rec.qualifier_attribute46;
      END IF;
      IF (x_pav_rec.qualifier_attribute47 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute47 := l_pav_rec.qualifier_attribute47;
      END IF;
      IF (x_pav_rec.qualifier_attribute48 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute48 := l_pav_rec.qualifier_attribute48;
      END IF;
      IF (x_pav_rec.qualifier_attribute49 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute49 := l_pav_rec.qualifier_attribute49;
      END IF;
      IF (x_pav_rec.qualifier_attribute50 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute50 := l_pav_rec.qualifier_attribute50;
      END IF;
      IF (x_pav_rec.qualifier_attribute51 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute51 := l_pav_rec.qualifier_attribute51;
      END IF;
      IF (x_pav_rec.qualifier_attribute52 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute52 := l_pav_rec.qualifier_attribute52;
      END IF;
      IF (x_pav_rec.qualifier_attribute53 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute53 := l_pav_rec.qualifier_attribute53;
      END IF;
      IF (x_pav_rec.qualifier_attribute54 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute54 := l_pav_rec.qualifier_attribute54;
      END IF;
      IF (x_pav_rec.qualifier_attribute55 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute55 := l_pav_rec.qualifier_attribute55;
      END IF;
      IF (x_pav_rec.qualifier_attribute56 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute56 := l_pav_rec.qualifier_attribute56;
      END IF;
      IF (x_pav_rec.qualifier_attribute57 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute57 := l_pav_rec.qualifier_attribute57;
      END IF;
      IF (x_pav_rec.qualifier_attribute58 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute58 := l_pav_rec.qualifier_attribute58;
      END IF;
      IF (x_pav_rec.qualifier_attribute59 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute59 := l_pav_rec.qualifier_attribute59;
      END IF;
      IF (x_pav_rec.qualifier_attribute60 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute60 := l_pav_rec.qualifier_attribute60;
      END IF;
      IF (x_pav_rec.qualifier_attribute61 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute61 := l_pav_rec.qualifier_attribute61;
      END IF;
      IF (x_pav_rec.qualifier_attribute62 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute62 := l_pav_rec.qualifier_attribute62;
      END IF;
      IF (x_pav_rec.qualifier_attribute63 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute63 := l_pav_rec.qualifier_attribute63;
      END IF;
      IF (x_pav_rec.qualifier_attribute64 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute64 := l_pav_rec.qualifier_attribute64;
      END IF;
      IF (x_pav_rec.qualifier_attribute65 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute65 := l_pav_rec.qualifier_attribute65;
      END IF;
      IF (x_pav_rec.qualifier_attribute66 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute66 := l_pav_rec.qualifier_attribute66;
      END IF;
      IF (x_pav_rec.qualifier_attribute67 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute67 := l_pav_rec.qualifier_attribute67;
      END IF;
      IF (x_pav_rec.qualifier_attribute68 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute68 := l_pav_rec.qualifier_attribute68;
      END IF;
      IF (x_pav_rec.qualifier_attribute69 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute69 := l_pav_rec.qualifier_attribute69;
      END IF;
      IF (x_pav_rec.qualifier_attribute70 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute70 := l_pav_rec.qualifier_attribute70;
      END IF;
      IF (x_pav_rec.qualifier_attribute71 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute71 := l_pav_rec.qualifier_attribute71;
      END IF;
      IF (x_pav_rec.qualifier_attribute72 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute72 := l_pav_rec.qualifier_attribute72;
      END IF;
      IF (x_pav_rec.qualifier_attribute73 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute73 := l_pav_rec.qualifier_attribute73;
      END IF;
      IF (x_pav_rec.qualifier_attribute74 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute74 := l_pav_rec.qualifier_attribute74;
      END IF;
      IF (x_pav_rec.qualifier_attribute75 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute75 := l_pav_rec.qualifier_attribute75;
      END IF;
      IF (x_pav_rec.qualifier_attribute76 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute76 := l_pav_rec.qualifier_attribute76;
      END IF;
      IF (x_pav_rec.qualifier_attribute77 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute77 := l_pav_rec.qualifier_attribute77;
      END IF;
      IF (x_pav_rec.qualifier_attribute78 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute78 := l_pav_rec.qualifier_attribute78;
      END IF;
      IF (x_pav_rec.qualifier_attribute79 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute79 := l_pav_rec.qualifier_attribute79;
      END IF;
      IF (x_pav_rec.qualifier_attribute80 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute80 := l_pav_rec.qualifier_attribute80;
      END IF;
      IF (x_pav_rec.qualifier_attribute81 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute81 := l_pav_rec.qualifier_attribute81;
      END IF;
      IF (x_pav_rec.qualifier_attribute82 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute82 := l_pav_rec.qualifier_attribute82;
      END IF;
      IF (x_pav_rec.qualifier_attribute83 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute83 := l_pav_rec.qualifier_attribute83;
      END IF;
      IF (x_pav_rec.qualifier_attribute84 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute84 := l_pav_rec.qualifier_attribute84;
      END IF;
      IF (x_pav_rec.qualifier_attribute85 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute85 := l_pav_rec.qualifier_attribute85;
      END IF;
      IF (x_pav_rec.qualifier_attribute86 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute86 := l_pav_rec.qualifier_attribute86;
      END IF;
      IF (x_pav_rec.qualifier_attribute87 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute87 := l_pav_rec.qualifier_attribute87;
      END IF;
      IF (x_pav_rec.qualifier_attribute88 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute88 := l_pav_rec.qualifier_attribute88;
      END IF;
      IF (x_pav_rec.qualifier_attribute89 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute89 := l_pav_rec.qualifier_attribute89;
      END IF;
      IF (x_pav_rec.qualifier_attribute90 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute90 := l_pav_rec.qualifier_attribute90;
      END IF;
      IF (x_pav_rec.qualifier_attribute91 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute91 := l_pav_rec.qualifier_attribute91;
      END IF;
      IF (x_pav_rec.qualifier_attribute92 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute92 := l_pav_rec.qualifier_attribute92;
      END IF;
      IF (x_pav_rec.qualifier_attribute93 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute93 := l_pav_rec.qualifier_attribute93;
      END IF;
      IF (x_pav_rec.qualifier_attribute94 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute94 := l_pav_rec.qualifier_attribute94;
      END IF;
      IF (x_pav_rec.qualifier_attribute95 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute95 := l_pav_rec.qualifier_attribute95;
      END IF;
      IF (x_pav_rec.qualifier_attribute96 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute96 := l_pav_rec.qualifier_attribute96;
      END IF;
      IF (x_pav_rec.qualifier_attribute97 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute97 := l_pav_rec.qualifier_attribute97;
      END IF;
      IF (x_pav_rec.qualifier_attribute98 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute98 := l_pav_rec.qualifier_attribute98;
      END IF;
      IF (x_pav_rec.qualifier_attribute99 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute99 := l_pav_rec.qualifier_attribute99;
      END IF;
      IF (x_pav_rec.qualifier_attribute100 = OKC_API.G_MISS_CHAR)
      THEN
        x_pav_rec.qualifier_attribute100 := l_pav_rec.qualifier_attribute100;
      END IF;
      IF (x_pav_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pav_rec.last_update_login := l_pav_rec.last_update_login;
      END IF;
   IF (x_pav_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_pav_rec.program_application_id := l_pav_rec.program_application_id;
      END IF;
   IF (x_pav_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_pav_rec.program_id := l_pav_rec.program_id;
      END IF;
   IF (x_pav_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pav_rec.program_update_date := l_pav_rec.program_update_date;
      END IF;
   IF (x_pav_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_pav_rec.request_id := l_pav_rec.request_id;
      END IF;
   IF (x_pav_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pav_rec.object_version_number := l_pav_rec.object_version_number;
      END IF;
 RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ATT_VALUES --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_pav_rec IN  pav_rec_type,
      x_pav_rec OUT NOCOPY pav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pav_rec := p_pav_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_pav_rec,                         -- IN
      l_pav_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pav_rec, l_def_pav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_PRICE_ATT_VALUES
    SET FLEX_TITLE = l_def_pav_rec.flex_title,
        PRICING_CONTEXT = l_def_pav_rec.pricing_context,
        PRICING_ATTRIBUTE1 = l_def_pav_rec.pricing_attribute1,
        CHR_ID = l_def_pav_rec.chr_id,
        PRICING_ATTRIBUTE2 = l_def_pav_rec.pricing_attribute2,
        CLE_ID = l_def_pav_rec.cle_id,
        PRICING_ATTRIBUTE3 = l_def_pav_rec.pricing_attribute3,
        PRICING_ATTRIBUTE4 = l_def_pav_rec.pricing_attribute4,
        PRICING_ATTRIBUTE5 = l_def_pav_rec.pricing_attribute5,
        PRICING_ATTRIBUTE6 = l_def_pav_rec.pricing_attribute6,
        PRICING_ATTRIBUTE7 = l_def_pav_rec.pricing_attribute7,
        PRICING_ATTRIBUTE8 = l_def_pav_rec.pricing_attribute8,
        PRICING_ATTRIBUTE9 = l_def_pav_rec.pricing_attribute9,
        PRICING_ATTRIBUTE10 = l_def_pav_rec.pricing_attribute10,
        PRICING_ATTRIBUTE11 = l_def_pav_rec.pricing_attribute11,
        PRICING_ATTRIBUTE12 = l_def_pav_rec.pricing_attribute12,
        PRICING_ATTRIBUTE13 = l_def_pav_rec.pricing_attribute13,
        PRICING_ATTRIBUTE14 = l_def_pav_rec.pricing_attribute14,
        PRICING_ATTRIBUTE15 = l_def_pav_rec.pricing_attribute15,
        PRICING_ATTRIBUTE16 = l_def_pav_rec.pricing_attribute16,
        PRICING_ATTRIBUTE17 = l_def_pav_rec.pricing_attribute17,
        PRICING_ATTRIBUTE18 = l_def_pav_rec.pricing_attribute18,
        PRICING_ATTRIBUTE19 = l_def_pav_rec.pricing_attribute19,
        PRICING_ATTRIBUTE20 = l_def_pav_rec.pricing_attribute20,
        PRICING_ATTRIBUTE21 = l_def_pav_rec.pricing_attribute21,
        PRICING_ATTRIBUTE22 = l_def_pav_rec.pricing_attribute22,
        PRICING_ATTRIBUTE23 = l_def_pav_rec.pricing_attribute23,
        PRICING_ATTRIBUTE24 = l_def_pav_rec.pricing_attribute24,
        PRICING_ATTRIBUTE25 = l_def_pav_rec.pricing_attribute25,
        PRICING_ATTRIBUTE26 = l_def_pav_rec.pricing_attribute26,
        PRICING_ATTRIBUTE27 = l_def_pav_rec.pricing_attribute27,
        PRICING_ATTRIBUTE28 = l_def_pav_rec.pricing_attribute28,
        PRICING_ATTRIBUTE29 = l_def_pav_rec.pricing_attribute29,
        PRICING_ATTRIBUTE30 = l_def_pav_rec.pricing_attribute30,
        PRICING_ATTRIBUTE31 = l_def_pav_rec.pricing_attribute31,
        PRICING_ATTRIBUTE32 = l_def_pav_rec.pricing_attribute32,
        PRICING_ATTRIBUTE33 = l_def_pav_rec.pricing_attribute33,
        PRICING_ATTRIBUTE34 = l_def_pav_rec.pricing_attribute34,
        PRICING_ATTRIBUTE35 = l_def_pav_rec.pricing_attribute35,
        PRICING_ATTRIBUTE36 = l_def_pav_rec.pricing_attribute36,
        PRICING_ATTRIBUTE37 = l_def_pav_rec.pricing_attribute37,
        PRICING_ATTRIBUTE38 = l_def_pav_rec.pricing_attribute38,
        PRICING_ATTRIBUTE39 = l_def_pav_rec.pricing_attribute39,
        PRICING_ATTRIBUTE40 = l_def_pav_rec.pricing_attribute40,
        PRICING_ATTRIBUTE41 = l_def_pav_rec.pricing_attribute41,
        PRICING_ATTRIBUTE42 = l_def_pav_rec.pricing_attribute42,
        PRICING_ATTRIBUTE43 = l_def_pav_rec.pricing_attribute43,
        PRICING_ATTRIBUTE44 = l_def_pav_rec.pricing_attribute44,
        PRICING_ATTRIBUTE45 = l_def_pav_rec.pricing_attribute45,
        PRICING_ATTRIBUTE46 = l_def_pav_rec.pricing_attribute46,
        PRICING_ATTRIBUTE47 = l_def_pav_rec.pricing_attribute47,
        PRICING_ATTRIBUTE48 = l_def_pav_rec.pricing_attribute48,
        PRICING_ATTRIBUTE49 = l_def_pav_rec.pricing_attribute49,
        PRICING_ATTRIBUTE50 = l_def_pav_rec.pricing_attribute50,
        PRICING_ATTRIBUTE51 = l_def_pav_rec.pricing_attribute51,
        PRICING_ATTRIBUTE52 = l_def_pav_rec.pricing_attribute52,
        PRICING_ATTRIBUTE53 = l_def_pav_rec.pricing_attribute53,
        PRICING_ATTRIBUTE54 = l_def_pav_rec.pricing_attribute54,
        PRICING_ATTRIBUTE55 = l_def_pav_rec.pricing_attribute55,
        PRICING_ATTRIBUTE56 = l_def_pav_rec.pricing_attribute56,
        PRICING_ATTRIBUTE57 = l_def_pav_rec.pricing_attribute57,
        PRICING_ATTRIBUTE58 = l_def_pav_rec.pricing_attribute58,
        PRICING_ATTRIBUTE59 = l_def_pav_rec.pricing_attribute59,
        PRICING_ATTRIBUTE60 = l_def_pav_rec.pricing_attribute60,
        PRICING_ATTRIBUTE61 = l_def_pav_rec.pricing_attribute61,
        PRICING_ATTRIBUTE62 = l_def_pav_rec.pricing_attribute62,
        PRICING_ATTRIBUTE63 = l_def_pav_rec.pricing_attribute63,
        PRICING_ATTRIBUTE64 = l_def_pav_rec.pricing_attribute64,
        PRICING_ATTRIBUTE65 = l_def_pav_rec.pricing_attribute65,
        PRICING_ATTRIBUTE66 = l_def_pav_rec.pricing_attribute66,
        PRICING_ATTRIBUTE67 = l_def_pav_rec.pricing_attribute67,
        PRICING_ATTRIBUTE68 = l_def_pav_rec.pricing_attribute68,
        PRICING_ATTRIBUTE69 = l_def_pav_rec.pricing_attribute69,
        PRICING_ATTRIBUTE70 = l_def_pav_rec.pricing_attribute70,
        PRICING_ATTRIBUTE71 = l_def_pav_rec.pricing_attribute71,
        PRICING_ATTRIBUTE72 = l_def_pav_rec.pricing_attribute72,
        PRICING_ATTRIBUTE73 = l_def_pav_rec.pricing_attribute73,
        PRICING_ATTRIBUTE74 = l_def_pav_rec.pricing_attribute74,
        PRICING_ATTRIBUTE75 = l_def_pav_rec.pricing_attribute75,
        PRICING_ATTRIBUTE76 = l_def_pav_rec.pricing_attribute76,
        PRICING_ATTRIBUTE77 = l_def_pav_rec.pricing_attribute77,
        PRICING_ATTRIBUTE78 = l_def_pav_rec.pricing_attribute78,
        PRICING_ATTRIBUTE79 = l_def_pav_rec.pricing_attribute79,
        PRICING_ATTRIBUTE80 = l_def_pav_rec.pricing_attribute80,
        PRICING_ATTRIBUTE81 = l_def_pav_rec.pricing_attribute81,
        PRICING_ATTRIBUTE82 = l_def_pav_rec.pricing_attribute82,
        PRICING_ATTRIBUTE83 = l_def_pav_rec.pricing_attribute83,
        PRICING_ATTRIBUTE84 = l_def_pav_rec.pricing_attribute84,
        PRICING_ATTRIBUTE85 = l_def_pav_rec.pricing_attribute85,
        PRICING_ATTRIBUTE86 = l_def_pav_rec.pricing_attribute86,
        PRICING_ATTRIBUTE87 = l_def_pav_rec.pricing_attribute87,
        PRICING_ATTRIBUTE88 = l_def_pav_rec.pricing_attribute88,
        PRICING_ATTRIBUTE89 = l_def_pav_rec.pricing_attribute89,
        PRICING_ATTRIBUTE90 = l_def_pav_rec.pricing_attribute90,
        PRICING_ATTRIBUTE91 = l_def_pav_rec.pricing_attribute91,
        PRICING_ATTRIBUTE92 = l_def_pav_rec.pricing_attribute92,
        PRICING_ATTRIBUTE93 = l_def_pav_rec.pricing_attribute93,
        PRICING_ATTRIBUTE94 = l_def_pav_rec.pricing_attribute94,
        PRICING_ATTRIBUTE95 = l_def_pav_rec.pricing_attribute95,
        PRICING_ATTRIBUTE96 = l_def_pav_rec.pricing_attribute96,
        PRICING_ATTRIBUTE97 = l_def_pav_rec.pricing_attribute97,
        PRICING_ATTRIBUTE98 = l_def_pav_rec.pricing_attribute98,
        PRICING_ATTRIBUTE99 = l_def_pav_rec.pricing_attribute99,
        PRICING_ATTRIBUTE100 = l_def_pav_rec.pricing_attribute100,
        QUALIFIER_CONTEXT = l_def_pav_rec.qualifier_context,
        QUALIFIER_ATTRIBUTE1 = l_def_pav_rec.qualifier_attribute1,
        QUALIFIER_ATTRIBUTE2 = l_def_pav_rec.qualifier_attribute2,
        CREATED_BY = l_def_pav_rec.created_by,
        QUALIFIER_ATTRIBUTE3 = l_def_pav_rec.qualifier_attribute3,
        CREATION_DATE = l_def_pav_rec.creation_date,
        QUALIFIER_ATTRIBUTE4 = l_def_pav_rec.qualifier_attribute4,
        QUALIFIER_ATTRIBUTE5 = l_def_pav_rec.qualifier_attribute5,
        LAST_UPDATED_BY = l_def_pav_rec.last_updated_by,
        QUALIFIER_ATTRIBUTE6 = l_def_pav_rec.qualifier_attribute6,
        LAST_UPDATE_DATE = l_def_pav_rec.last_update_date,
        QUALIFIER_ATTRIBUTE7 = l_def_pav_rec.qualifier_attribute7,
        QUALIFIER_ATTRIBUTE8 = l_def_pav_rec.qualifier_attribute8,
        QUALIFIER_ATTRIBUTE9 = l_def_pav_rec.qualifier_attribute9,
        QUALIFIER_ATTRIBUTE10 = l_def_pav_rec.qualifier_attribute10,
        QUALIFIER_ATTRIBUTE11 = l_def_pav_rec.qualifier_attribute11,
        QUALIFIER_ATTRIBUTE12 = l_def_pav_rec.qualifier_attribute12,
        QUALIFIER_ATTRIBUTE13 = l_def_pav_rec.qualifier_attribute13,
        QUALIFIER_ATTRIBUTE14 = l_def_pav_rec.qualifier_attribute14,
        QUALIFIER_ATTRIBUTE15 = l_def_pav_rec.qualifier_attribute15,
        QUALIFIER_ATTRIBUTE16 = l_def_pav_rec.qualifier_attribute16,
        QUALIFIER_ATTRIBUTE17 = l_def_pav_rec.qualifier_attribute17,
        QUALIFIER_ATTRIBUTE18 = l_def_pav_rec.qualifier_attribute18,
        QUALIFIER_ATTRIBUTE19 = l_def_pav_rec.qualifier_attribute19,
        QUALIFIER_ATTRIBUTE20 = l_def_pav_rec.qualifier_attribute20,
        QUALIFIER_ATTRIBUTE21 = l_def_pav_rec.qualifier_attribute21,
        QUALIFIER_ATTRIBUTE22 = l_def_pav_rec.qualifier_attribute22,
        QUALIFIER_ATTRIBUTE23 = l_def_pav_rec.qualifier_attribute23,
        QUALIFIER_ATTRIBUTE24 = l_def_pav_rec.qualifier_attribute24,
        QUALIFIER_ATTRIBUTE25 = l_def_pav_rec.qualifier_attribute25,
        QUALIFIER_ATTRIBUTE26 = l_def_pav_rec.qualifier_attribute26,
        QUALIFIER_ATTRIBUTE27 = l_def_pav_rec.qualifier_attribute27,
        QUALIFIER_ATTRIBUTE28 = l_def_pav_rec.qualifier_attribute28,
        QUALIFIER_ATTRIBUTE29 = l_def_pav_rec.qualifier_attribute29,
        QUALIFIER_ATTRIBUTE30 = l_def_pav_rec.qualifier_attribute30,
        QUALIFIER_ATTRIBUTE31 = l_def_pav_rec.qualifier_attribute31,
        QUALIFIER_ATTRIBUTE32 = l_def_pav_rec.qualifier_attribute32,
        QUALIFIER_ATTRIBUTE33 = l_def_pav_rec.qualifier_attribute33,
        QUALIFIER_ATTRIBUTE34 = l_def_pav_rec.qualifier_attribute34,
        QUALIFIER_ATTRIBUTE35 = l_def_pav_rec.qualifier_attribute35,
        QUALIFIER_ATTRIBUTE36 = l_def_pav_rec.qualifier_attribute36,
        QUALIFIER_ATTRIBUTE37 = l_def_pav_rec.qualifier_attribute37,
        QUALIFIER_ATTRIBUTE38 = l_def_pav_rec.qualifier_attribute38,
        QUALIFIER_ATTRIBUTE39 = l_def_pav_rec.qualifier_attribute39,
        QUALIFIER_ATTRIBUTE40 = l_def_pav_rec.qualifier_attribute40,
        QUALIFIER_ATTRIBUTE41 = l_def_pav_rec.qualifier_attribute41,
        QUALIFIER_ATTRIBUTE42 = l_def_pav_rec.qualifier_attribute42,
        QUALIFIER_ATTRIBUTE43 = l_def_pav_rec.qualifier_attribute43,
        QUALIFIER_ATTRIBUTE44 = l_def_pav_rec.qualifier_attribute44,
        QUALIFIER_ATTRIBUTE45 = l_def_pav_rec.qualifier_attribute45,
        QUALIFIER_ATTRIBUTE46 = l_def_pav_rec.qualifier_attribute46,
        QUALIFIER_ATTRIBUTE47 = l_def_pav_rec.qualifier_attribute47,
        QUALIFIER_ATTRIBUTE48 = l_def_pav_rec.qualifier_attribute48,
        QUALIFIER_ATTRIBUTE49 = l_def_pav_rec.qualifier_attribute49,
        QUALIFIER_ATTRIBUTE50 = l_def_pav_rec.qualifier_attribute50,
        QUALIFIER_ATTRIBUTE51 = l_def_pav_rec.qualifier_attribute51,
        QUALIFIER_ATTRIBUTE52 = l_def_pav_rec.qualifier_attribute52,
        QUALIFIER_ATTRIBUTE53 = l_def_pav_rec.qualifier_attribute53,
        QUALIFIER_ATTRIBUTE54 = l_def_pav_rec.qualifier_attribute54,
        QUALIFIER_ATTRIBUTE55 = l_def_pav_rec.qualifier_attribute55,
        QUALIFIER_ATTRIBUTE56 = l_def_pav_rec.qualifier_attribute56,
        QUALIFIER_ATTRIBUTE57 = l_def_pav_rec.qualifier_attribute57,
        QUALIFIER_ATTRIBUTE58 = l_def_pav_rec.qualifier_attribute58,
        QUALIFIER_ATTRIBUTE59 = l_def_pav_rec.qualifier_attribute59,
        QUALIFIER_ATTRIBUTE60 = l_def_pav_rec.qualifier_attribute60,
        QUALIFIER_ATTRIBUTE61 = l_def_pav_rec.qualifier_attribute61,
        QUALIFIER_ATTRIBUTE62 = l_def_pav_rec.qualifier_attribute62,
        QUALIFIER_ATTRIBUTE63 = l_def_pav_rec.qualifier_attribute63,
        QUALIFIER_ATTRIBUTE64 = l_def_pav_rec.qualifier_attribute64,
        QUALIFIER_ATTRIBUTE65 = l_def_pav_rec.qualifier_attribute65,
        QUALIFIER_ATTRIBUTE66 = l_def_pav_rec.qualifier_attribute66,
        QUALIFIER_ATTRIBUTE67 = l_def_pav_rec.qualifier_attribute67,
        QUALIFIER_ATTRIBUTE68 = l_def_pav_rec.qualifier_attribute68,
        QUALIFIER_ATTRIBUTE69 = l_def_pav_rec.qualifier_attribute69,
        QUALIFIER_ATTRIBUTE70 = l_def_pav_rec.qualifier_attribute70,
        QUALIFIER_ATTRIBUTE71 = l_def_pav_rec.qualifier_attribute71,
        QUALIFIER_ATTRIBUTE72 = l_def_pav_rec.qualifier_attribute72,
        QUALIFIER_ATTRIBUTE73 = l_def_pav_rec.qualifier_attribute73,
        QUALIFIER_ATTRIBUTE74 = l_def_pav_rec.qualifier_attribute74,
        QUALIFIER_ATTRIBUTE75 = l_def_pav_rec.qualifier_attribute75,
        QUALIFIER_ATTRIBUTE76 = l_def_pav_rec.qualifier_attribute76,
        QUALIFIER_ATTRIBUTE77 = l_def_pav_rec.qualifier_attribute77,
        QUALIFIER_ATTRIBUTE78 = l_def_pav_rec.qualifier_attribute78,
        QUALIFIER_ATTRIBUTE79 = l_def_pav_rec.qualifier_attribute79,
        QUALIFIER_ATTRIBUTE80 = l_def_pav_rec.qualifier_attribute80,
        QUALIFIER_ATTRIBUTE81 = l_def_pav_rec.qualifier_attribute81,
        QUALIFIER_ATTRIBUTE82 = l_def_pav_rec.qualifier_attribute82,
        QUALIFIER_ATTRIBUTE83 = l_def_pav_rec.qualifier_attribute83,
        QUALIFIER_ATTRIBUTE84 = l_def_pav_rec.qualifier_attribute84,
        QUALIFIER_ATTRIBUTE85 = l_def_pav_rec.qualifier_attribute85,
        QUALIFIER_ATTRIBUTE86 = l_def_pav_rec.qualifier_attribute86,
        QUALIFIER_ATTRIBUTE87 = l_def_pav_rec.qualifier_attribute87,
        QUALIFIER_ATTRIBUTE88 = l_def_pav_rec.qualifier_attribute88,
        QUALIFIER_ATTRIBUTE89 = l_def_pav_rec.qualifier_attribute89,
        QUALIFIER_ATTRIBUTE90 = l_def_pav_rec.qualifier_attribute90,
        QUALIFIER_ATTRIBUTE91 = l_def_pav_rec.qualifier_attribute91,
        QUALIFIER_ATTRIBUTE92 = l_def_pav_rec.qualifier_attribute92,
        QUALIFIER_ATTRIBUTE93 = l_def_pav_rec.qualifier_attribute93,
        QUALIFIER_ATTRIBUTE94 = l_def_pav_rec.qualifier_attribute94,
        QUALIFIER_ATTRIBUTE95 = l_def_pav_rec.qualifier_attribute95,
        QUALIFIER_ATTRIBUTE96 = l_def_pav_rec.qualifier_attribute96,
        QUALIFIER_ATTRIBUTE97 = l_def_pav_rec.qualifier_attribute97,
        QUALIFIER_ATTRIBUTE98 = l_def_pav_rec.qualifier_attribute98,
        QUALIFIER_ATTRIBUTE99 = l_def_pav_rec.qualifier_attribute99,
        QUALIFIER_ATTRIBUTE100 = l_def_pav_rec.qualifier_attribute100,
        LAST_UPDATE_LOGIN = l_def_pav_rec.last_update_login,
 REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),l_def_pav_rec.request_id),
PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),l_def_pav_rec.program_application_id),
PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),l_def_pav_rec.program_id),
PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,l_def_pav_rec.program_update_date,SYSDATE),
 OBJECT_VERSION_NUMBER = l_def_pav_rec.object_version_number
     WHERE ID = l_def_pav_rec.id;

    x_pav_rec := l_def_pav_rec;
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
  END update_row;
  -------------------------------------------
  -- update_row for:OKC_PRICE_ATT_VALUES_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type,
    x_pavv_rec                     OUT NOCOPY pavv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pavv_rec                     pavv_rec_type := p_pavv_rec;
    l_def_pavv_rec                 pavv_rec_type;
    l_pav_rec                      pav_rec_type;
    lx_pav_rec                     pav_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pavv_rec	IN pavv_rec_type
    ) RETURN pavv_rec_type IS
      l_pavv_rec	pavv_rec_type := p_pavv_rec;
    BEGIN
      l_pavv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pavv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pavv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pavv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pavv_rec	IN pavv_rec_type,
      x_pavv_rec	OUT NOCOPY pavv_rec_type
    ) RETURN VARCHAR2 IS
      l_pavv_rec                     pavv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pavv_rec := p_pavv_rec;
      -- Get current database values
      l_pavv_rec := get_rec(p_pavv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pavv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pavv_rec.id := l_pavv_rec.id;
      END IF;
      IF (x_pavv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_pavv_rec.chr_id := l_pavv_rec.chr_id;
      END IF;
      IF (x_pavv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_pavv_rec.cle_id := l_pavv_rec.cle_id;
      END IF;
      IF (x_pavv_rec.flex_title = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.flex_title := l_pavv_rec.flex_title;
      END IF;
      IF (x_pavv_rec.pricing_context = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_context := l_pavv_rec.pricing_context;
      END IF;
      IF (x_pavv_rec.pricing_attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute1 := l_pavv_rec.pricing_attribute1;
      END IF;
      IF (x_pavv_rec.pricing_attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute2 := l_pavv_rec.pricing_attribute2;
      END IF;
      IF (x_pavv_rec.pricing_attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute3 := l_pavv_rec.pricing_attribute3;
      END IF;
      IF (x_pavv_rec.pricing_attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute4 := l_pavv_rec.pricing_attribute4;
      END IF;
      IF (x_pavv_rec.pricing_attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute5 := l_pavv_rec.pricing_attribute5;
      END IF;
      IF (x_pavv_rec.pricing_attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute6 := l_pavv_rec.pricing_attribute6;
      END IF;
      IF (x_pavv_rec.pricing_attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute7 := l_pavv_rec.pricing_attribute7;
      END IF;
      IF (x_pavv_rec.pricing_attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute8 := l_pavv_rec.pricing_attribute8;
      END IF;
      IF (x_pavv_rec.pricing_attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute9 := l_pavv_rec.pricing_attribute9;
      END IF;
      IF (x_pavv_rec.pricing_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute10 := l_pavv_rec.pricing_attribute10;
      END IF;
      IF (x_pavv_rec.pricing_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute11 := l_pavv_rec.pricing_attribute11;
      END IF;
      IF (x_pavv_rec.pricing_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute12 := l_pavv_rec.pricing_attribute12;
      END IF;
      IF (x_pavv_rec.pricing_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute13 := l_pavv_rec.pricing_attribute13;
      END IF;
      IF (x_pavv_rec.pricing_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute14 := l_pavv_rec.pricing_attribute14;
      END IF;
      IF (x_pavv_rec.pricing_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute15 := l_pavv_rec.pricing_attribute15;
      END IF;
      IF (x_pavv_rec.pricing_attribute16 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute16 := l_pavv_rec.pricing_attribute16;
      END IF;
      IF (x_pavv_rec.pricing_attribute17 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute17 := l_pavv_rec.pricing_attribute17;
      END IF;
      IF (x_pavv_rec.pricing_attribute18 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute18 := l_pavv_rec.pricing_attribute18;
      END IF;
      IF (x_pavv_rec.pricing_attribute19 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute19 := l_pavv_rec.pricing_attribute19;
      END IF;
      IF (x_pavv_rec.pricing_attribute20 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute20 := l_pavv_rec.pricing_attribute20;
      END IF;
      IF (x_pavv_rec.pricing_attribute21 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute21 := l_pavv_rec.pricing_attribute21;
      END IF;
      IF (x_pavv_rec.pricing_attribute22 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute22 := l_pavv_rec.pricing_attribute22;
      END IF;
      IF (x_pavv_rec.pricing_attribute23 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute23 := l_pavv_rec.pricing_attribute23;
      END IF;
      IF (x_pavv_rec.pricing_attribute24 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute24 := l_pavv_rec.pricing_attribute24;
      END IF;
      IF (x_pavv_rec.pricing_attribute25 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute25 := l_pavv_rec.pricing_attribute25;
      END IF;
      IF (x_pavv_rec.pricing_attribute26 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute26 := l_pavv_rec.pricing_attribute26;
      END IF;
      IF (x_pavv_rec.pricing_attribute27 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute27 := l_pavv_rec.pricing_attribute27;
      END IF;
      IF (x_pavv_rec.pricing_attribute28 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute28 := l_pavv_rec.pricing_attribute28;
      END IF;
      IF (x_pavv_rec.pricing_attribute29 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute29 := l_pavv_rec.pricing_attribute29;
      END IF;
      IF (x_pavv_rec.pricing_attribute30 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute30 := l_pavv_rec.pricing_attribute30;
      END IF;
      IF (x_pavv_rec.pricing_attribute31 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute31 := l_pavv_rec.pricing_attribute31;
      END IF;
      IF (x_pavv_rec.pricing_attribute32 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute32 := l_pavv_rec.pricing_attribute32;
      END IF;
      IF (x_pavv_rec.pricing_attribute33 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute33 := l_pavv_rec.pricing_attribute33;
      END IF;
      IF (x_pavv_rec.pricing_attribute34 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute34 := l_pavv_rec.pricing_attribute34;
      END IF;
      IF (x_pavv_rec.pricing_attribute35 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute35 := l_pavv_rec.pricing_attribute35;
      END IF;
      IF (x_pavv_rec.pricing_attribute36 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute36 := l_pavv_rec.pricing_attribute36;
      END IF;
      IF (x_pavv_rec.pricing_attribute37 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute37 := l_pavv_rec.pricing_attribute37;
      END IF;
      IF (x_pavv_rec.pricing_attribute38 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute38 := l_pavv_rec.pricing_attribute38;
      END IF;
      IF (x_pavv_rec.pricing_attribute39 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute39 := l_pavv_rec.pricing_attribute39;
      END IF;
      IF (x_pavv_rec.pricing_attribute40 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute40 := l_pavv_rec.pricing_attribute40;
      END IF;
      IF (x_pavv_rec.pricing_attribute41 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute41 := l_pavv_rec.pricing_attribute41;
      END IF;
      IF (x_pavv_rec.pricing_attribute42 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute42 := l_pavv_rec.pricing_attribute42;
      END IF;
      IF (x_pavv_rec.pricing_attribute43 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute43 := l_pavv_rec.pricing_attribute43;
      END IF;
      IF (x_pavv_rec.pricing_attribute44 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute44 := l_pavv_rec.pricing_attribute44;
      END IF;
      IF (x_pavv_rec.pricing_attribute45 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute45 := l_pavv_rec.pricing_attribute45;
      END IF;
      IF (x_pavv_rec.pricing_attribute46 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute46 := l_pavv_rec.pricing_attribute46;
      END IF;
      IF (x_pavv_rec.pricing_attribute47 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute47 := l_pavv_rec.pricing_attribute47;
      END IF;
      IF (x_pavv_rec.pricing_attribute48 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute48 := l_pavv_rec.pricing_attribute48;
      END IF;
      IF (x_pavv_rec.pricing_attribute49 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute49 := l_pavv_rec.pricing_attribute49;
      END IF;
      IF (x_pavv_rec.pricing_attribute50 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute50 := l_pavv_rec.pricing_attribute50;
      END IF;
      IF (x_pavv_rec.pricing_attribute51 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute51 := l_pavv_rec.pricing_attribute51;
      END IF;
      IF (x_pavv_rec.pricing_attribute52 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute52 := l_pavv_rec.pricing_attribute52;
      END IF;
      IF (x_pavv_rec.pricing_attribute53 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute53 := l_pavv_rec.pricing_attribute53;
      END IF;
      IF (x_pavv_rec.pricing_attribute54 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute54 := l_pavv_rec.pricing_attribute54;
      END IF;
      IF (x_pavv_rec.pricing_attribute55 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute55 := l_pavv_rec.pricing_attribute55;
      END IF;
      IF (x_pavv_rec.pricing_attribute56 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute56 := l_pavv_rec.pricing_attribute56;
      END IF;
      IF (x_pavv_rec.pricing_attribute57 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute57 := l_pavv_rec.pricing_attribute57;
      END IF;
      IF (x_pavv_rec.pricing_attribute58 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute58 := l_pavv_rec.pricing_attribute58;
      END IF;
      IF (x_pavv_rec.pricing_attribute59 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute59 := l_pavv_rec.pricing_attribute59;
      END IF;
      IF (x_pavv_rec.pricing_attribute60 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute60 := l_pavv_rec.pricing_attribute60;
      END IF;
      IF (x_pavv_rec.pricing_attribute61 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute61 := l_pavv_rec.pricing_attribute61;
      END IF;
      IF (x_pavv_rec.pricing_attribute62 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute62 := l_pavv_rec.pricing_attribute62;
      END IF;
      IF (x_pavv_rec.pricing_attribute63 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute63 := l_pavv_rec.pricing_attribute63;
      END IF;
      IF (x_pavv_rec.pricing_attribute64 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute64 := l_pavv_rec.pricing_attribute64;
      END IF;
      IF (x_pavv_rec.pricing_attribute65 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute65 := l_pavv_rec.pricing_attribute65;
      END IF;
      IF (x_pavv_rec.pricing_attribute66 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute66 := l_pavv_rec.pricing_attribute66;
      END IF;
      IF (x_pavv_rec.pricing_attribute67 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute67 := l_pavv_rec.pricing_attribute67;
      END IF;
      IF (x_pavv_rec.pricing_attribute68 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute68 := l_pavv_rec.pricing_attribute68;
      END IF;
      IF (x_pavv_rec.pricing_attribute69 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute69 := l_pavv_rec.pricing_attribute69;
      END IF;
      IF (x_pavv_rec.pricing_attribute70 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute70 := l_pavv_rec.pricing_attribute70;
      END IF;
      IF (x_pavv_rec.pricing_attribute71 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute71 := l_pavv_rec.pricing_attribute71;
      END IF;
      IF (x_pavv_rec.pricing_attribute72 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute72 := l_pavv_rec.pricing_attribute72;
      END IF;
      IF (x_pavv_rec.pricing_attribute73 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute73 := l_pavv_rec.pricing_attribute73;
      END IF;
      IF (x_pavv_rec.pricing_attribute74 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute74 := l_pavv_rec.pricing_attribute74;
      END IF;
      IF (x_pavv_rec.pricing_attribute75 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute75 := l_pavv_rec.pricing_attribute75;
      END IF;
      IF (x_pavv_rec.pricing_attribute76 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute76 := l_pavv_rec.pricing_attribute76;
      END IF;
      IF (x_pavv_rec.pricing_attribute77 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute77 := l_pavv_rec.pricing_attribute77;
      END IF;
      IF (x_pavv_rec.pricing_attribute78 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute78 := l_pavv_rec.pricing_attribute78;
      END IF;
      IF (x_pavv_rec.pricing_attribute79 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute79 := l_pavv_rec.pricing_attribute79;
      END IF;
      IF (x_pavv_rec.pricing_attribute80 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute80 := l_pavv_rec.pricing_attribute80;
      END IF;
      IF (x_pavv_rec.pricing_attribute81 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute81 := l_pavv_rec.pricing_attribute81;
      END IF;
      IF (x_pavv_rec.pricing_attribute82 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute82 := l_pavv_rec.pricing_attribute82;
      END IF;
      IF (x_pavv_rec.pricing_attribute83 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute83 := l_pavv_rec.pricing_attribute83;
      END IF;
      IF (x_pavv_rec.pricing_attribute84 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute84 := l_pavv_rec.pricing_attribute84;
      END IF;
      IF (x_pavv_rec.pricing_attribute85 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute85 := l_pavv_rec.pricing_attribute85;
      END IF;
      IF (x_pavv_rec.pricing_attribute86 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute86 := l_pavv_rec.pricing_attribute86;
      END IF;
      IF (x_pavv_rec.pricing_attribute87 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute87 := l_pavv_rec.pricing_attribute87;
      END IF;
      IF (x_pavv_rec.pricing_attribute88 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute88 := l_pavv_rec.pricing_attribute88;
      END IF;
      IF (x_pavv_rec.pricing_attribute89 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute89 := l_pavv_rec.pricing_attribute89;
      END IF;
      IF (x_pavv_rec.pricing_attribute90 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute90 := l_pavv_rec.pricing_attribute90;
      END IF;
      IF (x_pavv_rec.pricing_attribute91 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute91 := l_pavv_rec.pricing_attribute91;
      END IF;
      IF (x_pavv_rec.pricing_attribute92 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute92 := l_pavv_rec.pricing_attribute92;
      END IF;
      IF (x_pavv_rec.pricing_attribute93 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute93 := l_pavv_rec.pricing_attribute93;
      END IF;
      IF (x_pavv_rec.pricing_attribute94 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute94 := l_pavv_rec.pricing_attribute94;
      END IF;
      IF (x_pavv_rec.pricing_attribute95 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute95 := l_pavv_rec.pricing_attribute95;
      END IF;
      IF (x_pavv_rec.pricing_attribute96 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute96 := l_pavv_rec.pricing_attribute96;
      END IF;
      IF (x_pavv_rec.pricing_attribute97 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute97 := l_pavv_rec.pricing_attribute97;
      END IF;
      IF (x_pavv_rec.pricing_attribute98 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute98 := l_pavv_rec.pricing_attribute98;
      END IF;
      IF (x_pavv_rec.pricing_attribute99 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute99 := l_pavv_rec.pricing_attribute99;
      END IF;
      IF (x_pavv_rec.pricing_attribute100 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.pricing_attribute100 := l_pavv_rec.pricing_attribute100;
      END IF;
      IF (x_pavv_rec.qualifier_context = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_context := l_pavv_rec.qualifier_context;
      END IF;
      IF (x_pavv_rec.qualifier_attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute1 := l_pavv_rec.qualifier_attribute1;
      END IF;
      IF (x_pavv_rec.qualifier_attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute2 := l_pavv_rec.qualifier_attribute2;
      END IF;
      IF (x_pavv_rec.qualifier_attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute3 := l_pavv_rec.qualifier_attribute3;
      END IF;
      IF (x_pavv_rec.qualifier_attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute4 := l_pavv_rec.qualifier_attribute4;
      END IF;
      IF (x_pavv_rec.qualifier_attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute5 := l_pavv_rec.qualifier_attribute5;
      END IF;
      IF (x_pavv_rec.qualifier_attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute6 := l_pavv_rec.qualifier_attribute6;
      END IF;
      IF (x_pavv_rec.qualifier_attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute7 := l_pavv_rec.qualifier_attribute7;
      END IF;
      IF (x_pavv_rec.qualifier_attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute8 := l_pavv_rec.qualifier_attribute8;
      END IF;
      IF (x_pavv_rec.qualifier_attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute9 := l_pavv_rec.qualifier_attribute9;
      END IF;
      IF (x_pavv_rec.qualifier_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute10 := l_pavv_rec.qualifier_attribute10;
      END IF;
      IF (x_pavv_rec.qualifier_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute11 := l_pavv_rec.qualifier_attribute11;
      END IF;
      IF (x_pavv_rec.qualifier_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute12 := l_pavv_rec.qualifier_attribute12;
      END IF;
      IF (x_pavv_rec.qualifier_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute13 := l_pavv_rec.qualifier_attribute13;
      END IF;
      IF (x_pavv_rec.qualifier_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute14 := l_pavv_rec.qualifier_attribute14;
      END IF;
      IF (x_pavv_rec.qualifier_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute15 := l_pavv_rec.qualifier_attribute15;
      END IF;
      IF (x_pavv_rec.qualifier_attribute16 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute16 := l_pavv_rec.qualifier_attribute16;
      END IF;
      IF (x_pavv_rec.qualifier_attribute17 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute17 := l_pavv_rec.qualifier_attribute17;
      END IF;
      IF (x_pavv_rec.qualifier_attribute18 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute18 := l_pavv_rec.qualifier_attribute18;
      END IF;
      IF (x_pavv_rec.qualifier_attribute19 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute19 := l_pavv_rec.qualifier_attribute19;
      END IF;
      IF (x_pavv_rec.qualifier_attribute20 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute20 := l_pavv_rec.qualifier_attribute20;
      END IF;
      IF (x_pavv_rec.qualifier_attribute21 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute21 := l_pavv_rec.qualifier_attribute21;
      END IF;
      IF (x_pavv_rec.qualifier_attribute22 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute22 := l_pavv_rec.qualifier_attribute22;
      END IF;
      IF (x_pavv_rec.qualifier_attribute23 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute23 := l_pavv_rec.qualifier_attribute23;
      END IF;
      IF (x_pavv_rec.qualifier_attribute24 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute24 := l_pavv_rec.qualifier_attribute24;
      END IF;
      IF (x_pavv_rec.qualifier_attribute25 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute25 := l_pavv_rec.qualifier_attribute25;
      END IF;
      IF (x_pavv_rec.qualifier_attribute26 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute26 := l_pavv_rec.qualifier_attribute26;
      END IF;
      IF (x_pavv_rec.qualifier_attribute27 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute27 := l_pavv_rec.qualifier_attribute27;
      END IF;
      IF (x_pavv_rec.qualifier_attribute28 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute28 := l_pavv_rec.qualifier_attribute28;
      END IF;
      IF (x_pavv_rec.qualifier_attribute29 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute29 := l_pavv_rec.qualifier_attribute29;
      END IF;
      IF (x_pavv_rec.qualifier_attribute30 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute30 := l_pavv_rec.qualifier_attribute30;
      END IF;
      IF (x_pavv_rec.qualifier_attribute31 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute31 := l_pavv_rec.qualifier_attribute31;
      END IF;
      IF (x_pavv_rec.qualifier_attribute32 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute32 := l_pavv_rec.qualifier_attribute32;
      END IF;
      IF (x_pavv_rec.qualifier_attribute33 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute33 := l_pavv_rec.qualifier_attribute33;
      END IF;
      IF (x_pavv_rec.qualifier_attribute34 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute34 := l_pavv_rec.qualifier_attribute34;
      END IF;
      IF (x_pavv_rec.qualifier_attribute35 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute35 := l_pavv_rec.qualifier_attribute35;
      END IF;
      IF (x_pavv_rec.qualifier_attribute36 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute36 := l_pavv_rec.qualifier_attribute36;
      END IF;
      IF (x_pavv_rec.qualifier_attribute37 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute37 := l_pavv_rec.qualifier_attribute37;
      END IF;
      IF (x_pavv_rec.qualifier_attribute38 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute38 := l_pavv_rec.qualifier_attribute38;
      END IF;
      IF (x_pavv_rec.qualifier_attribute39 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute39 := l_pavv_rec.qualifier_attribute39;
      END IF;
      IF (x_pavv_rec.qualifier_attribute40 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute40 := l_pavv_rec.qualifier_attribute40;
      END IF;
      IF (x_pavv_rec.qualifier_attribute41 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute41 := l_pavv_rec.qualifier_attribute41;
      END IF;
      IF (x_pavv_rec.qualifier_attribute42 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute42 := l_pavv_rec.qualifier_attribute42;
      END IF;
      IF (x_pavv_rec.qualifier_attribute43 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute43 := l_pavv_rec.qualifier_attribute43;
      END IF;
      IF (x_pavv_rec.qualifier_attribute44 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute44 := l_pavv_rec.qualifier_attribute44;
      END IF;
      IF (x_pavv_rec.qualifier_attribute45 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute45 := l_pavv_rec.qualifier_attribute45;
      END IF;
      IF (x_pavv_rec.qualifier_attribute46 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute46 := l_pavv_rec.qualifier_attribute46;
      END IF;
      IF (x_pavv_rec.qualifier_attribute47 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute47 := l_pavv_rec.qualifier_attribute47;
      END IF;
      IF (x_pavv_rec.qualifier_attribute48 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute48 := l_pavv_rec.qualifier_attribute48;
      END IF;
      IF (x_pavv_rec.qualifier_attribute49 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute49 := l_pavv_rec.qualifier_attribute49;
      END IF;
      IF (x_pavv_rec.qualifier_attribute50 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute50 := l_pavv_rec.qualifier_attribute50;
      END IF;
      IF (x_pavv_rec.qualifier_attribute51 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute51 := l_pavv_rec.qualifier_attribute51;
      END IF;
      IF (x_pavv_rec.qualifier_attribute52 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute52 := l_pavv_rec.qualifier_attribute52;
      END IF;
      IF (x_pavv_rec.qualifier_attribute53 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute53 := l_pavv_rec.qualifier_attribute53;
      END IF;
      IF (x_pavv_rec.qualifier_attribute54 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute54 := l_pavv_rec.qualifier_attribute54;
      END IF;
      IF (x_pavv_rec.qualifier_attribute55 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute55 := l_pavv_rec.qualifier_attribute55;
      END IF;
      IF (x_pavv_rec.qualifier_attribute56 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute56 := l_pavv_rec.qualifier_attribute56;
      END IF;
      IF (x_pavv_rec.qualifier_attribute57 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute57 := l_pavv_rec.qualifier_attribute57;
      END IF;
      IF (x_pavv_rec.qualifier_attribute58 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute58 := l_pavv_rec.qualifier_attribute58;
      END IF;
      IF (x_pavv_rec.qualifier_attribute59 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute59 := l_pavv_rec.qualifier_attribute59;
      END IF;
      IF (x_pavv_rec.qualifier_attribute60 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute60 := l_pavv_rec.qualifier_attribute60;
      END IF;
      IF (x_pavv_rec.qualifier_attribute61 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute61 := l_pavv_rec.qualifier_attribute61;
      END IF;
      IF (x_pavv_rec.qualifier_attribute62 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute62 := l_pavv_rec.qualifier_attribute62;
      END IF;
      IF (x_pavv_rec.qualifier_attribute63 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute63 := l_pavv_rec.qualifier_attribute63;
      END IF;
      IF (x_pavv_rec.qualifier_attribute64 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute64 := l_pavv_rec.qualifier_attribute64;
      END IF;
      IF (x_pavv_rec.qualifier_attribute65 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute65 := l_pavv_rec.qualifier_attribute65;
      END IF;
      IF (x_pavv_rec.qualifier_attribute66 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute66 := l_pavv_rec.qualifier_attribute66;
      END IF;
      IF (x_pavv_rec.qualifier_attribute67 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute67 := l_pavv_rec.qualifier_attribute67;
      END IF;
      IF (x_pavv_rec.qualifier_attribute68 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute68 := l_pavv_rec.qualifier_attribute68;
      END IF;
      IF (x_pavv_rec.qualifier_attribute69 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute69 := l_pavv_rec.qualifier_attribute69;
      END IF;
      IF (x_pavv_rec.qualifier_attribute70 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute70 := l_pavv_rec.qualifier_attribute70;
      END IF;
      IF (x_pavv_rec.qualifier_attribute71 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute71 := l_pavv_rec.qualifier_attribute71;
      END IF;
      IF (x_pavv_rec.qualifier_attribute72 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute72 := l_pavv_rec.qualifier_attribute72;
      END IF;
      IF (x_pavv_rec.qualifier_attribute73 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute73 := l_pavv_rec.qualifier_attribute73;
      END IF;
      IF (x_pavv_rec.qualifier_attribute74 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute74 := l_pavv_rec.qualifier_attribute74;
      END IF;
      IF (x_pavv_rec.qualifier_attribute75 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute75 := l_pavv_rec.qualifier_attribute75;
      END IF;
      IF (x_pavv_rec.qualifier_attribute76 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute76 := l_pavv_rec.qualifier_attribute76;
      END IF;
      IF (x_pavv_rec.qualifier_attribute77 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute77 := l_pavv_rec.qualifier_attribute77;
      END IF;
      IF (x_pavv_rec.qualifier_attribute78 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute78 := l_pavv_rec.qualifier_attribute78;
      END IF;
      IF (x_pavv_rec.qualifier_attribute79 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute79 := l_pavv_rec.qualifier_attribute79;
      END IF;
      IF (x_pavv_rec.qualifier_attribute80 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute80 := l_pavv_rec.qualifier_attribute80;
      END IF;
      IF (x_pavv_rec.qualifier_attribute81 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute81 := l_pavv_rec.qualifier_attribute81;
      END IF;
      IF (x_pavv_rec.qualifier_attribute82 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute82 := l_pavv_rec.qualifier_attribute82;
      END IF;
      IF (x_pavv_rec.qualifier_attribute83 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute83 := l_pavv_rec.qualifier_attribute83;
      END IF;
      IF (x_pavv_rec.qualifier_attribute84 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute84 := l_pavv_rec.qualifier_attribute84;
      END IF;
      IF (x_pavv_rec.qualifier_attribute85 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute85 := l_pavv_rec.qualifier_attribute85;
      END IF;
      IF (x_pavv_rec.qualifier_attribute86 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute86 := l_pavv_rec.qualifier_attribute86;
      END IF;
      IF (x_pavv_rec.qualifier_attribute87 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute87 := l_pavv_rec.qualifier_attribute87;
      END IF;
      IF (x_pavv_rec.qualifier_attribute88 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute88 := l_pavv_rec.qualifier_attribute88;
      END IF;
      IF (x_pavv_rec.qualifier_attribute89 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute89 := l_pavv_rec.qualifier_attribute89;
      END IF;
      IF (x_pavv_rec.qualifier_attribute90 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute90 := l_pavv_rec.qualifier_attribute90;
      END IF;
      IF (x_pavv_rec.qualifier_attribute91 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute91 := l_pavv_rec.qualifier_attribute91;
      END IF;
      IF (x_pavv_rec.qualifier_attribute92 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute92 := l_pavv_rec.qualifier_attribute92;
      END IF;
      IF (x_pavv_rec.qualifier_attribute93 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute93 := l_pavv_rec.qualifier_attribute93;
      END IF;
      IF (x_pavv_rec.qualifier_attribute94 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute94 := l_pavv_rec.qualifier_attribute94;
      END IF;
      IF (x_pavv_rec.qualifier_attribute95 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute95 := l_pavv_rec.qualifier_attribute95;
      END IF;
      IF (x_pavv_rec.qualifier_attribute96 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute96 := l_pavv_rec.qualifier_attribute96;
      END IF;
      IF (x_pavv_rec.qualifier_attribute97 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute97 := l_pavv_rec.qualifier_attribute97;
      END IF;
      IF (x_pavv_rec.qualifier_attribute98 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute98 := l_pavv_rec.qualifier_attribute98;
      END IF;
      IF (x_pavv_rec.qualifier_attribute99 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute99 := l_pavv_rec.qualifier_attribute99;
      END IF;
      IF (x_pavv_rec.qualifier_attribute100 = OKC_API.G_MISS_CHAR)
      THEN
        x_pavv_rec.qualifier_attribute100 := l_pavv_rec.qualifier_attribute100;
      END IF;
      IF (x_pavv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pavv_rec.created_by := l_pavv_rec.created_by;
      END IF;
      IF (x_pavv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pavv_rec.creation_date := l_pavv_rec.creation_date;
      END IF;
      IF (x_pavv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pavv_rec.last_updated_by := l_pavv_rec.last_updated_by;
      END IF;
      IF (x_pavv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pavv_rec.last_update_date := l_pavv_rec.last_update_date;
      END IF;
      IF (x_pavv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pavv_rec.last_update_login := l_pavv_rec.last_update_login;
      END IF;
     IF (x_pavv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_pavv_rec.program_application_id := l_pavv_rec.program_application_id;
      END IF;
     IF (x_pavv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_pavv_rec.program_id := l_pavv_rec.program_id;
      END IF;
     IF (x_pavv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pavv_rec.program_update_date := l_pavv_rec.program_update_date;
      END IF;
    IF (x_pavv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_pavv_rec.request_id := l_pavv_rec.request_id;
      END IF;
      IF (x_pavv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pavv_rec.object_version_number := l_pavv_rec.object_version_number;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ATT_VALUES_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_pavv_rec IN  pavv_rec_type,
      x_pavv_rec OUT NOCOPY pavv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pavv_rec := p_pavv_rec;
      x_pavv_rec.OBJECT_VERSION_NUMBER := NVL(x_pavv_rec.OBJECT_VERSION_NUMBER,0) + 1;
     RETURN(l_return_status);
    END Set_Attributes;
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
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_pavv_rec,                        -- IN
      l_pavv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pavv_rec, l_def_pavv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pavv_rec := fill_who_columns(l_def_pavv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pavv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pavv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pavv_rec, l_pav_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pav_rec,
      lx_pav_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pav_rec, l_def_pavv_rec);
    x_pavv_rec := l_def_pavv_rec;
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
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:PAVV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type,
    x_pavv_tbl                     OUT NOCOPY pavv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pavv_tbl.COUNT > 0) THEN
      i := p_pavv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pavv_rec                     => p_pavv_tbl(i),
          x_pavv_rec                     => x_pavv_tbl(i));
        EXIT WHEN (i = p_pavv_tbl.LAST);
        i := p_pavv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- delete_row for:OKC_PRICE_ATT_VALUES --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pav_rec                      IN pav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALUES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pav_rec                      pav_rec_type:= p_pav_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_PRICE_ATT_VALUES
     WHERE ID = l_pav_rec.id;

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
  END delete_row;
  -------------------------------------------
  -- delete_row for:OKC_PRICE_ATT_VALUES_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pavv_rec                     pavv_rec_type := p_pavv_rec;
    l_pav_rec                      pav_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_pavv_rec, l_pav_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pav_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
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
  END delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:PAVV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pavv_tbl.COUNT > 0) THEN
      i := p_pavv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pavv_rec                     => p_pavv_tbl(i));
        EXIT WHEN (i = p_pavv_tbl.LAST);
        i := p_pavv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
  END delete_row;

---------------------------------------------------------------
-- Procedure for mass insert in OKC_PRICE_ATT_VALUES _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_pavv_tbl pavv_tbl_type) IS
BEGIN
----need to substitue
 OKC_SPLIT2_PAV_PVT.INSERT_ROW_UPG(x_return_status ,p_pavv_tbl );

---------
END INSERT_ROW_UPG;


   FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO okc_price_att_values_h
  (
        id,
        flex_title,
        pricing_context,
        pricing_attribute1,
        chr_id,
        pricing_attribute2,
        cle_id,
        pricing_attribute3,
        pricing_attribute4,
        pricing_attribute5,
        pricing_attribute6,
        pricing_attribute7,
        pricing_attribute8,
        pricing_attribute9,
        pricing_attribute10,
        pricing_attribute11,
        pricing_attribute12,
        pricing_attribute13,
        pricing_attribute14,
        pricing_attribute15,
        pricing_attribute16,
        pricing_attribute17,
        pricing_attribute18,
        pricing_attribute19,
        pricing_attribute20,
        pricing_attribute21,
        pricing_attribute22,
        pricing_attribute23,
        pricing_attribute24,
        pricing_attribute25,
        pricing_attribute26,
        pricing_attribute27,
        pricing_attribute28,
        pricing_attribute29,
        pricing_attribute30,
        pricing_attribute31,
        pricing_attribute32,
        pricing_attribute33,
        pricing_attribute34,
        pricing_attribute35,
        pricing_attribute36,
        pricing_attribute37,
        pricing_attribute38,
        pricing_attribute39,
        pricing_attribute40,
        pricing_attribute41,
        pricing_attribute42,
        pricing_attribute43,
        pricing_attribute44,
        pricing_attribute45,
        pricing_attribute46,
        pricing_attribute47,
        pricing_attribute48,
        pricing_attribute49,
        pricing_attribute50,
        pricing_attribute51,
        pricing_attribute52,
        pricing_attribute53,
        pricing_attribute54,
        pricing_attribute55,
        pricing_attribute56,
        pricing_attribute57,
        pricing_attribute58,
        pricing_attribute59,
        pricing_attribute60,
        pricing_attribute61,
        pricing_attribute62,
        pricing_attribute63,
        pricing_attribute64,
        pricing_attribute65,
        pricing_attribute66,
        pricing_attribute67,
        pricing_attribute68,
        pricing_attribute69,
        pricing_attribute70,
        pricing_attribute71,
        pricing_attribute72,
        pricing_attribute73,
        pricing_attribute74,
        pricing_attribute75,
        pricing_attribute76,
        pricing_attribute77,
        pricing_attribute78,
        pricing_attribute79,
        pricing_attribute80,
        pricing_attribute81,
        pricing_attribute82,
        pricing_attribute83,
        pricing_attribute84,
        pricing_attribute85,
        pricing_attribute86,
        pricing_attribute87,
        pricing_attribute88,
        pricing_attribute89,
        pricing_attribute90,
        pricing_attribute91,
        pricing_attribute92,
        pricing_attribute93,
        pricing_attribute94,
        pricing_attribute95,
        pricing_attribute96,
        pricing_attribute97,
        pricing_attribute98,
        pricing_attribute99,
        pricing_attribute100,
        qualifier_context,
        qualifier_attribute1,
        qualifier_attribute2,
        created_by,
        qualifier_attribute3,
        creation_date,
        qualifier_attribute4,
        qualifier_attribute5,
        last_updated_by,
        qualifier_attribute6,
        last_update_date,
        qualifier_attribute7,
        qualifier_attribute8,
        qualifier_attribute9,
        qualifier_attribute10,
        qualifier_attribute11,
        qualifier_attribute12,
        qualifier_attribute13,
        qualifier_attribute14,
        qualifier_attribute15,
        qualifier_attribute16,
        qualifier_attribute17,
        qualifier_attribute18,
        qualifier_attribute19,
        qualifier_attribute20,
        qualifier_attribute21,
        qualifier_attribute22,
        qualifier_attribute23,
        qualifier_attribute24,
        qualifier_attribute25,
        qualifier_attribute26,
        qualifier_attribute27,
        qualifier_attribute28,
        qualifier_attribute29,
        qualifier_attribute30,
        qualifier_attribute31,
        qualifier_attribute32,
        qualifier_attribute33,
        qualifier_attribute34,
        qualifier_attribute35,
        qualifier_attribute36,
        qualifier_attribute37,
        qualifier_attribute38,
        qualifier_attribute39,
        qualifier_attribute40,
        qualifier_attribute41,
        qualifier_attribute42,
        qualifier_attribute43,
        qualifier_attribute44,
        qualifier_attribute45,
        qualifier_attribute46,
        qualifier_attribute47,
        qualifier_attribute48,
        qualifier_attribute49,
        qualifier_attribute50,
        qualifier_attribute51,
        qualifier_attribute52,
        qualifier_attribute53,
        qualifier_attribute54,
        qualifier_attribute55,
        qualifier_attribute56,
        qualifier_attribute57,
        qualifier_attribute58,
        qualifier_attribute59,
        qualifier_attribute60,
        qualifier_attribute61,
        qualifier_attribute62,
        qualifier_attribute63,
        qualifier_attribute64,
        qualifier_attribute65,
        qualifier_attribute66,
        qualifier_attribute67,
        qualifier_attribute68,
        qualifier_attribute69,
        qualifier_attribute70,
        qualifier_attribute71,
        qualifier_attribute72,
        qualifier_attribute73,
        qualifier_attribute74,
        qualifier_attribute75,
        qualifier_attribute76,
        qualifier_attribute77,
        qualifier_attribute78,
        qualifier_attribute79,
        qualifier_attribute80,
        qualifier_attribute81,
        qualifier_attribute82,
        qualifier_attribute83,
        qualifier_attribute84,
        qualifier_attribute85,
        qualifier_attribute86,
        qualifier_attribute87,
        qualifier_attribute88,
        qualifier_attribute89,
        qualifier_attribute90,
        qualifier_attribute91,
        qualifier_attribute92,
        qualifier_attribute93,
        qualifier_attribute94,
        qualifier_attribute95,
        qualifier_attribute96,
        qualifier_attribute97,
        qualifier_attribute98,
        qualifier_attribute99,
        qualifier_attribute100,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
       object_version_number,
       major_version
      )

SELECT

        id,
        flex_title,
        pricing_context,
        pricing_attribute1,
        chr_id,
        pricing_attribute2,
        cle_id,
        pricing_attribute3,
        pricing_attribute4,
        pricing_attribute5,
        pricing_attribute6,
        pricing_attribute7,
        pricing_attribute8,
        pricing_attribute9,
        pricing_attribute10,
        pricing_attribute11,
        pricing_attribute12,
        pricing_attribute13,
        pricing_attribute14,
        pricing_attribute15,
        pricing_attribute16,
        pricing_attribute17,
        pricing_attribute18,
        pricing_attribute19,
        pricing_attribute20,
        pricing_attribute21,
        pricing_attribute22,
        pricing_attribute23,
        pricing_attribute24,
        pricing_attribute25,
        pricing_attribute26,
        pricing_attribute27,
        pricing_attribute28,
        pricing_attribute29,
        pricing_attribute30,
        pricing_attribute31,
        pricing_attribute32,
        pricing_attribute33,
        pricing_attribute34,
        pricing_attribute35,
        pricing_attribute36,
        pricing_attribute37,
        pricing_attribute38,
        pricing_attribute39,
        pricing_attribute40,
        pricing_attribute41,
        pricing_attribute42,
        pricing_attribute43,
        pricing_attribute44,
        pricing_attribute45,
        pricing_attribute46,
        pricing_attribute47,
        pricing_attribute48,
        pricing_attribute49,
        pricing_attribute50,
        pricing_attribute51,
        pricing_attribute52,
        pricing_attribute53,
        pricing_attribute54,
        pricing_attribute55,
        pricing_attribute56,
        pricing_attribute57,
        pricing_attribute58,
        pricing_attribute59,
        pricing_attribute60,
        pricing_attribute61,
        pricing_attribute62,
        pricing_attribute63,
        pricing_attribute64,
        pricing_attribute65,
        pricing_attribute66,
        pricing_attribute67,
        pricing_attribute68,
        pricing_attribute69,
        pricing_attribute70,
        pricing_attribute71,
        pricing_attribute72,
        pricing_attribute73,
        pricing_attribute74,
        pricing_attribute75,
        pricing_attribute76,
        pricing_attribute77,
        pricing_attribute78,
        pricing_attribute79,
        pricing_attribute80,
        pricing_attribute81,
        pricing_attribute82,
        pricing_attribute83,
        pricing_attribute84,
        pricing_attribute85,
        pricing_attribute86,
        pricing_attribute87,
        pricing_attribute88,
        pricing_attribute89,
        pricing_attribute90,
        pricing_attribute91,
        pricing_attribute92,
        pricing_attribute93,
        pricing_attribute94,
        pricing_attribute95,
        pricing_attribute96,
        pricing_attribute97,
        pricing_attribute98,
        pricing_attribute99,
        pricing_attribute100,
        qualifier_context,
        qualifier_attribute1,
        qualifier_attribute2,
        created_by,
        qualifier_attribute3,
        creation_date,
        qualifier_attribute4,
        qualifier_attribute5,
        last_updated_by,
        qualifier_attribute6,
        last_update_date,
        qualifier_attribute7,
        qualifier_attribute8,
        qualifier_attribute9,
        qualifier_attribute10,
        qualifier_attribute11,
        qualifier_attribute12,
        qualifier_attribute13,
        qualifier_attribute14,
        qualifier_attribute15,
        qualifier_attribute16,
        qualifier_attribute17,
        qualifier_attribute18,
        qualifier_attribute19,
        qualifier_attribute20,
        qualifier_attribute21,
        qualifier_attribute22,
        qualifier_attribute23,
        qualifier_attribute24,
        qualifier_attribute25,
        qualifier_attribute26,
        qualifier_attribute27,
        qualifier_attribute28,
        qualifier_attribute29,
        qualifier_attribute30,
        qualifier_attribute31,
        qualifier_attribute32,
        qualifier_attribute33,
        qualifier_attribute34,
        qualifier_attribute35,
        qualifier_attribute36,
        qualifier_attribute37,
        qualifier_attribute38,
        qualifier_attribute39,
        qualifier_attribute40,
        qualifier_attribute41,
        qualifier_attribute42,
        qualifier_attribute43,
        qualifier_attribute44,
        qualifier_attribute45,
        qualifier_attribute46,
        qualifier_attribute47,
        qualifier_attribute48,
        qualifier_attribute49,
        qualifier_attribute50,
        qualifier_attribute51,
        qualifier_attribute52,
        qualifier_attribute53,
        qualifier_attribute54,
        qualifier_attribute55,
        qualifier_attribute56,
        qualifier_attribute57,
        qualifier_attribute58,
        qualifier_attribute59,
        qualifier_attribute60,
        qualifier_attribute61,
        qualifier_attribute62,
        qualifier_attribute63,
        qualifier_attribute64,
        qualifier_attribute65,
        qualifier_attribute66,
        qualifier_attribute67,
        qualifier_attribute68,
        qualifier_attribute69,
        qualifier_attribute70,
        qualifier_attribute71,
        qualifier_attribute72,
        qualifier_attribute73,
        qualifier_attribute74,
        qualifier_attribute75,
        qualifier_attribute76,
        qualifier_attribute77,
        qualifier_attribute78,
        qualifier_attribute79,
        qualifier_attribute80,
        qualifier_attribute81,
        qualifier_attribute82,
        qualifier_attribute83,
        qualifier_attribute84,
        qualifier_attribute85,
        qualifier_attribute86,
        qualifier_attribute87,
        qualifier_attribute88,
        qualifier_attribute89,
        qualifier_attribute90,
        qualifier_attribute91,
        qualifier_attribute92,
        qualifier_attribute93,
        qualifier_attribute94,
        qualifier_attribute95,
        qualifier_attribute96,
        qualifier_attribute97,
        qualifier_attribute98,
        qualifier_attribute99,
        qualifier_attribute100,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
        object_version_number,
        p_major_version
FROM    okc_price_att_values
WHERE   chr_id = p_chr_id
UNION     /* bugfix 2138898 - OR is replaced by UNION */
SELECT
        id,
        flex_title,
        pricing_context,
        pricing_attribute1,
        chr_id,
        pricing_attribute2,
        cle_id,
        pricing_attribute3,
        pricing_attribute4,
        pricing_attribute5,
        pricing_attribute6,
        pricing_attribute7,
        pricing_attribute8,
        pricing_attribute9,
        pricing_attribute10,
        pricing_attribute11,
        pricing_attribute12,
        pricing_attribute13,
        pricing_attribute14,
        pricing_attribute15,
        pricing_attribute16,
        pricing_attribute17,
        pricing_attribute18,
        pricing_attribute19,
        pricing_attribute20,
        pricing_attribute21,
        pricing_attribute22,
        pricing_attribute23,
        pricing_attribute24,
        pricing_attribute25,
        pricing_attribute26,
        pricing_attribute27,
        pricing_attribute28,
        pricing_attribute29,
        pricing_attribute30,
        pricing_attribute31,
        pricing_attribute32,
        pricing_attribute33,
        pricing_attribute34,
        pricing_attribute35,
        pricing_attribute36,
        pricing_attribute37,
        pricing_attribute38,
        pricing_attribute39,
        pricing_attribute40,
        pricing_attribute41,
        pricing_attribute42,
        pricing_attribute43,
        pricing_attribute44,
        pricing_attribute45,
        pricing_attribute46,
        pricing_attribute47,
        pricing_attribute48,
        pricing_attribute49,
        pricing_attribute50,
        pricing_attribute51,
        pricing_attribute52,
        pricing_attribute53,
        pricing_attribute54,
        pricing_attribute55,
        pricing_attribute56,
        pricing_attribute57,
        pricing_attribute58,
        pricing_attribute59,
        pricing_attribute60,
        pricing_attribute61,
        pricing_attribute62,
        pricing_attribute63,
        pricing_attribute64,
        pricing_attribute65,
        pricing_attribute66,
        pricing_attribute67,
        pricing_attribute68,
        pricing_attribute69,
        pricing_attribute70,
        pricing_attribute71,
        pricing_attribute72,
        pricing_attribute73,
        pricing_attribute74,
        pricing_attribute75,
        pricing_attribute76,
        pricing_attribute77,
        pricing_attribute78,
        pricing_attribute79,
        pricing_attribute80,
        pricing_attribute81,
        pricing_attribute82,
        pricing_attribute83,
        pricing_attribute84,
        pricing_attribute85,
        pricing_attribute86,
        pricing_attribute87,
        pricing_attribute88,
        pricing_attribute89,
        pricing_attribute90,
        pricing_attribute91,
        pricing_attribute92,
        pricing_attribute93,
        pricing_attribute94,
        pricing_attribute95,
        pricing_attribute96,
        pricing_attribute97,
        pricing_attribute98,
        pricing_attribute99,
        pricing_attribute100,
        qualifier_context,
        qualifier_attribute1,
        qualifier_attribute2,
        created_by,
        qualifier_attribute3,
        creation_date,
        qualifier_attribute4,
        qualifier_attribute5,
        last_updated_by,
        qualifier_attribute6,
        last_update_date,
        qualifier_attribute7,
        qualifier_attribute8,
        qualifier_attribute9,
        qualifier_attribute10,
        qualifier_attribute11,
        qualifier_attribute12,
        qualifier_attribute13,
        qualifier_attribute14,
        qualifier_attribute15,
        qualifier_attribute16,
        qualifier_attribute17,
        qualifier_attribute18,
        qualifier_attribute19,
        qualifier_attribute20,
        qualifier_attribute21,
        qualifier_attribute22,
        qualifier_attribute23,
        qualifier_attribute24,
        qualifier_attribute25,
        qualifier_attribute26,
        qualifier_attribute27,
        qualifier_attribute28,
        qualifier_attribute29,
        qualifier_attribute30,
        qualifier_attribute31,
        qualifier_attribute32,
        qualifier_attribute33,
        qualifier_attribute34,
        qualifier_attribute35,
        qualifier_attribute36,
        qualifier_attribute37,
        qualifier_attribute38,
        qualifier_attribute39,
        qualifier_attribute40,
        qualifier_attribute41,
        qualifier_attribute42,
        qualifier_attribute43,
        qualifier_attribute44,
        qualifier_attribute45,
        qualifier_attribute46,
        qualifier_attribute47,
        qualifier_attribute48,
        qualifier_attribute49,
        qualifier_attribute50,
        qualifier_attribute51,
        qualifier_attribute52,
        qualifier_attribute53,
        qualifier_attribute54,
        qualifier_attribute55,
        qualifier_attribute56,
        qualifier_attribute57,
        qualifier_attribute58,
        qualifier_attribute59,
        qualifier_attribute60,
        qualifier_attribute61,
        qualifier_attribute62,
        qualifier_attribute63,
        qualifier_attribute64,
        qualifier_attribute65,
        qualifier_attribute66,
        qualifier_attribute67,
        qualifier_attribute68,
        qualifier_attribute69,
        qualifier_attribute70,
        qualifier_attribute71,
        qualifier_attribute72,
        qualifier_attribute73,
        qualifier_attribute74,
        qualifier_attribute75,
        qualifier_attribute76,
        qualifier_attribute77,
        qualifier_attribute78,
        qualifier_attribute79,
        qualifier_attribute80,
        qualifier_attribute81,
        qualifier_attribute82,
        qualifier_attribute83,
        qualifier_attribute84,
        qualifier_attribute85,
        qualifier_attribute86,
        qualifier_attribute87,
        qualifier_attribute88,
        qualifier_attribute89,
        qualifier_attribute90,
        qualifier_attribute91,
        qualifier_attribute92,
        qualifier_attribute93,
        qualifier_attribute94,
        qualifier_attribute95,
        qualifier_attribute96,
        qualifier_attribute97,
        qualifier_attribute98,
        qualifier_attribute99,
        qualifier_attribute100,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
        object_version_number,
        p_major_version
FROM    okc_price_att_values
WHERE   cle_id IN
           (SELECT id
            FROM OKC_K_LINES_B
            WHERE dnz_chr_id = p_chr_id
           );

RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END create_version;

FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
-------
l_return_status := OKC_SPLIT2_PAV_PVT.restore_version(p_chr_id   => p_chr_id  ,
             p_major_version   => p_major_version );
-------

             return l_return_status;
END restore_version;


END OKC_PAV_PVT;

/
