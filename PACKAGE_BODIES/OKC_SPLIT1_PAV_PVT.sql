--------------------------------------------------------
--  DDL for Package Body OKC_SPLIT1_PAV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SPLIT1_PAV_PVT" AS
/* $Header: OKCSPAVSPOB.pls 120.0.12010000.1 2010/06/22 10:41:53 nvvaidya noship $ */
 ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_PRICE_ATT_VALUES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pav_rec                      IN OKC_PAV_PVT.pav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OKC_PAV_PVT.pav_rec_type IS
       CURSOR pav_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            FLEX_TITLE,
            PRICING_CONTEXT,
            PRICING_ATTRIBUTE1,
            CHR_ID,
            PRICING_ATTRIBUTE2,
            CLE_ID,
            PRICING_ATTRIBUTE3,
            PRICING_ATTRIBUTE4,
            PRICING_ATTRIBUTE5,
            PRICING_ATTRIBUTE6,
            PRICING_ATTRIBUTE7,
            PRICING_ATTRIBUTE8,
            PRICING_ATTRIBUTE9,
            PRICING_ATTRIBUTE10,
            PRICING_ATTRIBUTE11,
            PRICING_ATTRIBUTE12,
            PRICING_ATTRIBUTE13,
            PRICING_ATTRIBUTE14,
            PRICING_ATTRIBUTE15,
            PRICING_ATTRIBUTE16,
            PRICING_ATTRIBUTE17,
            PRICING_ATTRIBUTE18,
            PRICING_ATTRIBUTE19,
            PRICING_ATTRIBUTE20,
            PRICING_ATTRIBUTE21,
            PRICING_ATTRIBUTE22,
            PRICING_ATTRIBUTE23,
            PRICING_ATTRIBUTE24,
            PRICING_ATTRIBUTE25,
            PRICING_ATTRIBUTE26,
            PRICING_ATTRIBUTE27,
            PRICING_ATTRIBUTE28,
            PRICING_ATTRIBUTE29,
            PRICING_ATTRIBUTE30,
            PRICING_ATTRIBUTE31,
            PRICING_ATTRIBUTE32,
            PRICING_ATTRIBUTE33,
            PRICING_ATTRIBUTE34,
            PRICING_ATTRIBUTE35,
            PRICING_ATTRIBUTE36,
            PRICING_ATTRIBUTE37,
            PRICING_ATTRIBUTE38,
            PRICING_ATTRIBUTE39,
            PRICING_ATTRIBUTE40,
            PRICING_ATTRIBUTE41,
            PRICING_ATTRIBUTE42,
            PRICING_ATTRIBUTE43,
            PRICING_ATTRIBUTE44,
            PRICING_ATTRIBUTE45,
            PRICING_ATTRIBUTE46,
            PRICING_ATTRIBUTE47,
            PRICING_ATTRIBUTE48,
            PRICING_ATTRIBUTE49,
            PRICING_ATTRIBUTE50,
            PRICING_ATTRIBUTE51,
            PRICING_ATTRIBUTE52,
            PRICING_ATTRIBUTE53,
            PRICING_ATTRIBUTE54,
            PRICING_ATTRIBUTE55,
            PRICING_ATTRIBUTE56,
            PRICING_ATTRIBUTE57,
            PRICING_ATTRIBUTE58,
            PRICING_ATTRIBUTE59,
            PRICING_ATTRIBUTE60,
            PRICING_ATTRIBUTE61,
            PRICING_ATTRIBUTE62,
            PRICING_ATTRIBUTE63,
            PRICING_ATTRIBUTE64,
            PRICING_ATTRIBUTE65,
            PRICING_ATTRIBUTE66,
            PRICING_ATTRIBUTE67,
            PRICING_ATTRIBUTE68,
            PRICING_ATTRIBUTE69,
            PRICING_ATTRIBUTE70,
            PRICING_ATTRIBUTE71,
            PRICING_ATTRIBUTE72,
            PRICING_ATTRIBUTE73,
            PRICING_ATTRIBUTE74,
            PRICING_ATTRIBUTE75,
            PRICING_ATTRIBUTE76,
            PRICING_ATTRIBUTE77,
            PRICING_ATTRIBUTE78,
            PRICING_ATTRIBUTE79,
            PRICING_ATTRIBUTE80,
            PRICING_ATTRIBUTE81,
            PRICING_ATTRIBUTE82,
            PRICING_ATTRIBUTE83,
            PRICING_ATTRIBUTE84,
            PRICING_ATTRIBUTE85,
            PRICING_ATTRIBUTE86,
            PRICING_ATTRIBUTE87,
            PRICING_ATTRIBUTE88,
            PRICING_ATTRIBUTE89,
            PRICING_ATTRIBUTE90,
            PRICING_ATTRIBUTE91,
            PRICING_ATTRIBUTE92,
            PRICING_ATTRIBUTE93,
            PRICING_ATTRIBUTE94,
            PRICING_ATTRIBUTE95,
            PRICING_ATTRIBUTE96,
            PRICING_ATTRIBUTE97,
            PRICING_ATTRIBUTE98,
            PRICING_ATTRIBUTE99,
            PRICING_ATTRIBUTE100,
            QUALIFIER_CONTEXT,
            QUALIFIER_ATTRIBUTE1,
            QUALIFIER_ATTRIBUTE2,
            CREATED_BY,
            QUALIFIER_ATTRIBUTE3,
            CREATION_DATE,
            QUALIFIER_ATTRIBUTE4,
            QUALIFIER_ATTRIBUTE5,
            LAST_UPDATED_BY,
            QUALIFIER_ATTRIBUTE6,
            LAST_UPDATE_DATE,
            QUALIFIER_ATTRIBUTE7,
            QUALIFIER_ATTRIBUTE8,
            QUALIFIER_ATTRIBUTE9,
            QUALIFIER_ATTRIBUTE10,
            QUALIFIER_ATTRIBUTE11,
            QUALIFIER_ATTRIBUTE12,
            QUALIFIER_ATTRIBUTE13,
            QUALIFIER_ATTRIBUTE14,
            QUALIFIER_ATTRIBUTE15,
            QUALIFIER_ATTRIBUTE16,
            QUALIFIER_ATTRIBUTE17,
            QUALIFIER_ATTRIBUTE18,
            QUALIFIER_ATTRIBUTE19,
            QUALIFIER_ATTRIBUTE20,
            QUALIFIER_ATTRIBUTE21,
            QUALIFIER_ATTRIBUTE22,
            QUALIFIER_ATTRIBUTE23,
            QUALIFIER_ATTRIBUTE24,
            QUALIFIER_ATTRIBUTE25,
            QUALIFIER_ATTRIBUTE26,
            QUALIFIER_ATTRIBUTE27,
            QUALIFIER_ATTRIBUTE28,
            QUALIFIER_ATTRIBUTE29,
            QUALIFIER_ATTRIBUTE30,
            QUALIFIER_ATTRIBUTE31,
            QUALIFIER_ATTRIBUTE32,
            QUALIFIER_ATTRIBUTE33,
            QUALIFIER_ATTRIBUTE34,
            QUALIFIER_ATTRIBUTE35,
            QUALIFIER_ATTRIBUTE36,
            QUALIFIER_ATTRIBUTE37,
            QUALIFIER_ATTRIBUTE38,
            QUALIFIER_ATTRIBUTE39,
            QUALIFIER_ATTRIBUTE40,
            QUALIFIER_ATTRIBUTE41,
            QUALIFIER_ATTRIBUTE42,
            QUALIFIER_ATTRIBUTE43,
            QUALIFIER_ATTRIBUTE44,
            QUALIFIER_ATTRIBUTE45,
            QUALIFIER_ATTRIBUTE46,
            QUALIFIER_ATTRIBUTE47,
            QUALIFIER_ATTRIBUTE48,
            QUALIFIER_ATTRIBUTE49,
            QUALIFIER_ATTRIBUTE50,
            QUALIFIER_ATTRIBUTE51,
            QUALIFIER_ATTRIBUTE52,
            QUALIFIER_ATTRIBUTE53,
            QUALIFIER_ATTRIBUTE54,
            QUALIFIER_ATTRIBUTE55,
            QUALIFIER_ATTRIBUTE56,
            QUALIFIER_ATTRIBUTE57,
            QUALIFIER_ATTRIBUTE58,
            QUALIFIER_ATTRIBUTE59,
            QUALIFIER_ATTRIBUTE60,
            QUALIFIER_ATTRIBUTE61,
            QUALIFIER_ATTRIBUTE62,
            QUALIFIER_ATTRIBUTE63,
            QUALIFIER_ATTRIBUTE64,
            QUALIFIER_ATTRIBUTE65,
            QUALIFIER_ATTRIBUTE66,
            QUALIFIER_ATTRIBUTE67,
            QUALIFIER_ATTRIBUTE68,
            QUALIFIER_ATTRIBUTE69,
            QUALIFIER_ATTRIBUTE70,
            QUALIFIER_ATTRIBUTE71,
            QUALIFIER_ATTRIBUTE72,
            QUALIFIER_ATTRIBUTE73,
            QUALIFIER_ATTRIBUTE74,
            QUALIFIER_ATTRIBUTE75,
            QUALIFIER_ATTRIBUTE76,
            QUALIFIER_ATTRIBUTE77,
            QUALIFIER_ATTRIBUTE78,
            QUALIFIER_ATTRIBUTE79,
            QUALIFIER_ATTRIBUTE80,
            QUALIFIER_ATTRIBUTE81,
            QUALIFIER_ATTRIBUTE82,
            QUALIFIER_ATTRIBUTE83,
            QUALIFIER_ATTRIBUTE84,
            QUALIFIER_ATTRIBUTE85,
            QUALIFIER_ATTRIBUTE86,
            QUALIFIER_ATTRIBUTE87,
            QUALIFIER_ATTRIBUTE88,
            QUALIFIER_ATTRIBUTE89,
            QUALIFIER_ATTRIBUTE90,
            QUALIFIER_ATTRIBUTE91,
            QUALIFIER_ATTRIBUTE92,
            QUALIFIER_ATTRIBUTE93,
            QUALIFIER_ATTRIBUTE94,
            QUALIFIER_ATTRIBUTE95,
            QUALIFIER_ATTRIBUTE96,
            QUALIFIER_ATTRIBUTE97,
            QUALIFIER_ATTRIBUTE98,
            QUALIFIER_ATTRIBUTE99,
            QUALIFIER_ATTRIBUTE100,
            LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
           OBJECT_VERSION_NUMBER
        FROM Okc_Price_Att_Values
     WHERE okc_price_att_values.id = p_id;
    l_pav_pk                       pav_pk_csr%ROWTYPE;
    l_pav_rec                      OKC_PAV_PVT.pav_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN pav_pk_csr (p_pav_rec.id);
    FETCH pav_pk_csr INTO
              l_pav_rec.ID,
              l_pav_rec.FLEX_TITLE,
              l_pav_rec.PRICING_CONTEXT,
              l_pav_rec.PRICING_ATTRIBUTE1,
              l_pav_rec.CHR_ID,
              l_pav_rec.PRICING_ATTRIBUTE2,
              l_pav_rec.CLE_ID,
              l_pav_rec.PRICING_ATTRIBUTE3,
              l_pav_rec.PRICING_ATTRIBUTE4,
              l_pav_rec.PRICING_ATTRIBUTE5,
              l_pav_rec.PRICING_ATTRIBUTE6,
              l_pav_rec.PRICING_ATTRIBUTE7,
              l_pav_rec.PRICING_ATTRIBUTE8,
              l_pav_rec.PRICING_ATTRIBUTE9,
              l_pav_rec.PRICING_ATTRIBUTE10,
              l_pav_rec.PRICING_ATTRIBUTE11,
              l_pav_rec.PRICING_ATTRIBUTE12,
              l_pav_rec.PRICING_ATTRIBUTE13,
              l_pav_rec.PRICING_ATTRIBUTE14,
              l_pav_rec.PRICING_ATTRIBUTE15,
              l_pav_rec.PRICING_ATTRIBUTE16,
              l_pav_rec.PRICING_ATTRIBUTE17,
              l_pav_rec.PRICING_ATTRIBUTE18,
              l_pav_rec.PRICING_ATTRIBUTE19,
              l_pav_rec.PRICING_ATTRIBUTE20,
              l_pav_rec.PRICING_ATTRIBUTE21,
              l_pav_rec.PRICING_ATTRIBUTE22,
              l_pav_rec.PRICING_ATTRIBUTE23,
              l_pav_rec.PRICING_ATTRIBUTE24,
              l_pav_rec.PRICING_ATTRIBUTE25,
              l_pav_rec.PRICING_ATTRIBUTE26,
              l_pav_rec.PRICING_ATTRIBUTE27,
              l_pav_rec.PRICING_ATTRIBUTE28,
              l_pav_rec.PRICING_ATTRIBUTE29,
              l_pav_rec.PRICING_ATTRIBUTE30,
              l_pav_rec.PRICING_ATTRIBUTE31,
              l_pav_rec.PRICING_ATTRIBUTE32,
              l_pav_rec.PRICING_ATTRIBUTE33,
              l_pav_rec.PRICING_ATTRIBUTE34,
              l_pav_rec.PRICING_ATTRIBUTE35,
              l_pav_rec.PRICING_ATTRIBUTE36,
              l_pav_rec.PRICING_ATTRIBUTE37,
              l_pav_rec.PRICING_ATTRIBUTE38,
              l_pav_rec.PRICING_ATTRIBUTE39,
              l_pav_rec.PRICING_ATTRIBUTE40,
              l_pav_rec.PRICING_ATTRIBUTE41,
              l_pav_rec.PRICING_ATTRIBUTE42,
              l_pav_rec.PRICING_ATTRIBUTE43,
              l_pav_rec.PRICING_ATTRIBUTE44,
              l_pav_rec.PRICING_ATTRIBUTE45,
              l_pav_rec.PRICING_ATTRIBUTE46,
              l_pav_rec.PRICING_ATTRIBUTE47,
              l_pav_rec.PRICING_ATTRIBUTE48,
              l_pav_rec.PRICING_ATTRIBUTE49,
              l_pav_rec.PRICING_ATTRIBUTE50,
              l_pav_rec.PRICING_ATTRIBUTE51,
              l_pav_rec.PRICING_ATTRIBUTE52,
              l_pav_rec.PRICING_ATTRIBUTE53,
              l_pav_rec.PRICING_ATTRIBUTE54,
              l_pav_rec.PRICING_ATTRIBUTE55,
              l_pav_rec.PRICING_ATTRIBUTE56,
              l_pav_rec.PRICING_ATTRIBUTE57,
              l_pav_rec.PRICING_ATTRIBUTE58,
              l_pav_rec.PRICING_ATTRIBUTE59,
              l_pav_rec.PRICING_ATTRIBUTE60,
              l_pav_rec.PRICING_ATTRIBUTE61,
              l_pav_rec.PRICING_ATTRIBUTE62,
              l_pav_rec.PRICING_ATTRIBUTE63,
              l_pav_rec.PRICING_ATTRIBUTE64,
              l_pav_rec.PRICING_ATTRIBUTE65,
              l_pav_rec.PRICING_ATTRIBUTE66,
              l_pav_rec.PRICING_ATTRIBUTE67,
              l_pav_rec.PRICING_ATTRIBUTE68,
              l_pav_rec.PRICING_ATTRIBUTE69,
              l_pav_rec.PRICING_ATTRIBUTE70,
              l_pav_rec.PRICING_ATTRIBUTE71,
              l_pav_rec.PRICING_ATTRIBUTE72,
              l_pav_rec.PRICING_ATTRIBUTE73,
              l_pav_rec.PRICING_ATTRIBUTE74,
              l_pav_rec.PRICING_ATTRIBUTE75,
              l_pav_rec.PRICING_ATTRIBUTE76,
              l_pav_rec.PRICING_ATTRIBUTE77,
              l_pav_rec.PRICING_ATTRIBUTE78,
              l_pav_rec.PRICING_ATTRIBUTE79,
              l_pav_rec.PRICING_ATTRIBUTE80,
              l_pav_rec.PRICING_ATTRIBUTE81,
              l_pav_rec.PRICING_ATTRIBUTE82,
              l_pav_rec.PRICING_ATTRIBUTE83,
              l_pav_rec.PRICING_ATTRIBUTE84,
              l_pav_rec.PRICING_ATTRIBUTE85,
              l_pav_rec.PRICING_ATTRIBUTE86,
              l_pav_rec.PRICING_ATTRIBUTE87,
              l_pav_rec.PRICING_ATTRIBUTE88,
              l_pav_rec.PRICING_ATTRIBUTE89,
              l_pav_rec.PRICING_ATTRIBUTE90,
              l_pav_rec.PRICING_ATTRIBUTE91,
              l_pav_rec.PRICING_ATTRIBUTE92,
              l_pav_rec.PRICING_ATTRIBUTE93,
              l_pav_rec.PRICING_ATTRIBUTE94,
              l_pav_rec.PRICING_ATTRIBUTE95,
              l_pav_rec.PRICING_ATTRIBUTE96,
              l_pav_rec.PRICING_ATTRIBUTE97,
              l_pav_rec.PRICING_ATTRIBUTE98,
              l_pav_rec.PRICING_ATTRIBUTE99,
              l_pav_rec.PRICING_ATTRIBUTE100,
              l_pav_rec.QUALIFIER_CONTEXT,
              l_pav_rec.QUALIFIER_ATTRIBUTE1,
              l_pav_rec.QUALIFIER_ATTRIBUTE2,
              l_pav_rec.CREATED_BY,
              l_pav_rec.QUALIFIER_ATTRIBUTE3,
              l_pav_rec.CREATION_DATE,
              l_pav_rec.QUALIFIER_ATTRIBUTE4,
              l_pav_rec.QUALIFIER_ATTRIBUTE5,
              l_pav_rec.LAST_UPDATED_BY,
              l_pav_rec.QUALIFIER_ATTRIBUTE6,
              l_pav_rec.LAST_UPDATE_DATE,
              l_pav_rec.QUALIFIER_ATTRIBUTE7,
              l_pav_rec.QUALIFIER_ATTRIBUTE8,
              l_pav_rec.QUALIFIER_ATTRIBUTE9,
              l_pav_rec.QUALIFIER_ATTRIBUTE10,
              l_pav_rec.QUALIFIER_ATTRIBUTE11,
              l_pav_rec.QUALIFIER_ATTRIBUTE12,
              l_pav_rec.QUALIFIER_ATTRIBUTE13,
              l_pav_rec.QUALIFIER_ATTRIBUTE14,
              l_pav_rec.QUALIFIER_ATTRIBUTE15,
              l_pav_rec.QUALIFIER_ATTRIBUTE16,
              l_pav_rec.QUALIFIER_ATTRIBUTE17,
              l_pav_rec.QUALIFIER_ATTRIBUTE18,
              l_pav_rec.QUALIFIER_ATTRIBUTE19,
              l_pav_rec.QUALIFIER_ATTRIBUTE20,
              l_pav_rec.QUALIFIER_ATTRIBUTE21,
              l_pav_rec.QUALIFIER_ATTRIBUTE22,
              l_pav_rec.QUALIFIER_ATTRIBUTE23,
              l_pav_rec.QUALIFIER_ATTRIBUTE24,
              l_pav_rec.QUALIFIER_ATTRIBUTE25,
              l_pav_rec.QUALIFIER_ATTRIBUTE26,
              l_pav_rec.QUALIFIER_ATTRIBUTE27,
              l_pav_rec.QUALIFIER_ATTRIBUTE28,
              l_pav_rec.QUALIFIER_ATTRIBUTE29,
              l_pav_rec.QUALIFIER_ATTRIBUTE30,
              l_pav_rec.QUALIFIER_ATTRIBUTE31,
              l_pav_rec.QUALIFIER_ATTRIBUTE32,
              l_pav_rec.QUALIFIER_ATTRIBUTE33,
              l_pav_rec.QUALIFIER_ATTRIBUTE34,
              l_pav_rec.QUALIFIER_ATTRIBUTE35,
              l_pav_rec.QUALIFIER_ATTRIBUTE36,
              l_pav_rec.QUALIFIER_ATTRIBUTE37,
              l_pav_rec.QUALIFIER_ATTRIBUTE38,
              l_pav_rec.QUALIFIER_ATTRIBUTE39,
              l_pav_rec.QUALIFIER_ATTRIBUTE40,
              l_pav_rec.QUALIFIER_ATTRIBUTE41,
              l_pav_rec.QUALIFIER_ATTRIBUTE42,
              l_pav_rec.QUALIFIER_ATTRIBUTE43,
              l_pav_rec.QUALIFIER_ATTRIBUTE44,
              l_pav_rec.QUALIFIER_ATTRIBUTE45,
              l_pav_rec.QUALIFIER_ATTRIBUTE46,
              l_pav_rec.QUALIFIER_ATTRIBUTE47,
              l_pav_rec.QUALIFIER_ATTRIBUTE48,
              l_pav_rec.QUALIFIER_ATTRIBUTE49,
              l_pav_rec.QUALIFIER_ATTRIBUTE50,
              l_pav_rec.QUALIFIER_ATTRIBUTE51,
              l_pav_rec.QUALIFIER_ATTRIBUTE52,
              l_pav_rec.QUALIFIER_ATTRIBUTE53,
              l_pav_rec.QUALIFIER_ATTRIBUTE54,
              l_pav_rec.QUALIFIER_ATTRIBUTE55,
              l_pav_rec.QUALIFIER_ATTRIBUTE56,
              l_pav_rec.QUALIFIER_ATTRIBUTE57,
              l_pav_rec.QUALIFIER_ATTRIBUTE58,
              l_pav_rec.QUALIFIER_ATTRIBUTE59,
              l_pav_rec.QUALIFIER_ATTRIBUTE60,
              l_pav_rec.QUALIFIER_ATTRIBUTE61,
              l_pav_rec.QUALIFIER_ATTRIBUTE62,
              l_pav_rec.QUALIFIER_ATTRIBUTE63,
              l_pav_rec.QUALIFIER_ATTRIBUTE64,
              l_pav_rec.QUALIFIER_ATTRIBUTE65,
              l_pav_rec.QUALIFIER_ATTRIBUTE66,
              l_pav_rec.QUALIFIER_ATTRIBUTE67,
              l_pav_rec.QUALIFIER_ATTRIBUTE68,
              l_pav_rec.QUALIFIER_ATTRIBUTE69,
              l_pav_rec.QUALIFIER_ATTRIBUTE70,
              l_pav_rec.QUALIFIER_ATTRIBUTE71,
              l_pav_rec.QUALIFIER_ATTRIBUTE72,
              l_pav_rec.QUALIFIER_ATTRIBUTE73,
              l_pav_rec.QUALIFIER_ATTRIBUTE74,
              l_pav_rec.QUALIFIER_ATTRIBUTE75,
              l_pav_rec.QUALIFIER_ATTRIBUTE76,
              l_pav_rec.QUALIFIER_ATTRIBUTE77,
              l_pav_rec.QUALIFIER_ATTRIBUTE78,
              l_pav_rec.QUALIFIER_ATTRIBUTE79,
              l_pav_rec.QUALIFIER_ATTRIBUTE80,
              l_pav_rec.QUALIFIER_ATTRIBUTE81,
              l_pav_rec.QUALIFIER_ATTRIBUTE82,
              l_pav_rec.QUALIFIER_ATTRIBUTE83,
              l_pav_rec.QUALIFIER_ATTRIBUTE84,
              l_pav_rec.QUALIFIER_ATTRIBUTE85,
              l_pav_rec.QUALIFIER_ATTRIBUTE86,
              l_pav_rec.QUALIFIER_ATTRIBUTE87,
              l_pav_rec.QUALIFIER_ATTRIBUTE88,
              l_pav_rec.QUALIFIER_ATTRIBUTE89,
              l_pav_rec.QUALIFIER_ATTRIBUTE90,
              l_pav_rec.QUALIFIER_ATTRIBUTE91,
              l_pav_rec.QUALIFIER_ATTRIBUTE92,
              l_pav_rec.QUALIFIER_ATTRIBUTE93,
              l_pav_rec.QUALIFIER_ATTRIBUTE94,
              l_pav_rec.QUALIFIER_ATTRIBUTE95,
              l_pav_rec.QUALIFIER_ATTRIBUTE96,
              l_pav_rec.QUALIFIER_ATTRIBUTE97,
              l_pav_rec.QUALIFIER_ATTRIBUTE98,
              l_pav_rec.QUALIFIER_ATTRIBUTE99,
              l_pav_rec.QUALIFIER_ATTRIBUTE100,
              l_pav_rec.LAST_UPDATE_LOGIN,
              l_pav_rec.PROGRAM_APPLICATION_ID,
              l_pav_rec.PROGRAM_ID,
              l_pav_rec.PROGRAM_UPDATE_DATE,
              l_pav_rec.REQUEST_ID,
              l_pav_rec.OBJECT_VERSION_NUMBER;
      x_no_data_found := pav_pk_csr%NOTFOUND;
    CLOSE pav_pk_csr;
    RETURN(l_pav_rec);
  END get_rec;
 ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_PRICE_ATT_VALUES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pavv_rec                     IN OKC_PAV_PVT.pavv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OKC_PAV_PVT.pavv_rec_type IS
    CURSOR okc_pavv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CHR_ID,
            CLE_ID,
            FLEX_TITLE,
            PRICING_CONTEXT,
            PRICING_ATTRIBUTE1,
            PRICING_ATTRIBUTE2,
            PRICING_ATTRIBUTE3,
            PRICING_ATTRIBUTE4,
            PRICING_ATTRIBUTE5,
            PRICING_ATTRIBUTE6,
            PRICING_ATTRIBUTE7,
            PRICING_ATTRIBUTE8,
            PRICING_ATTRIBUTE9,
            PRICING_ATTRIBUTE10,
            PRICING_ATTRIBUTE11,
            PRICING_ATTRIBUTE12,
            PRICING_ATTRIBUTE13,
            PRICING_ATTRIBUTE14,
            PRICING_ATTRIBUTE15,
            PRICING_ATTRIBUTE16,
            PRICING_ATTRIBUTE17,
            PRICING_ATTRIBUTE18,
            PRICING_ATTRIBUTE19,
            PRICING_ATTRIBUTE20,
            PRICING_ATTRIBUTE21,
            PRICING_ATTRIBUTE22,
            PRICING_ATTRIBUTE23,
            PRICING_ATTRIBUTE24,
            PRICING_ATTRIBUTE25,
            PRICING_ATTRIBUTE26,
            PRICING_ATTRIBUTE27,
            PRICING_ATTRIBUTE28,
            PRICING_ATTRIBUTE29,
            PRICING_ATTRIBUTE30,
            PRICING_ATTRIBUTE31,
            PRICING_ATTRIBUTE32,
            PRICING_ATTRIBUTE33,
            PRICING_ATTRIBUTE34,
            PRICING_ATTRIBUTE35,
            PRICING_ATTRIBUTE36,
            PRICING_ATTRIBUTE37,
            PRICING_ATTRIBUTE38,
            PRICING_ATTRIBUTE39,
            PRICING_ATTRIBUTE40,
            PRICING_ATTRIBUTE41,
            PRICING_ATTRIBUTE42,
            PRICING_ATTRIBUTE43,
            PRICING_ATTRIBUTE44,
            PRICING_ATTRIBUTE45,
            PRICING_ATTRIBUTE46,
            PRICING_ATTRIBUTE47,
            PRICING_ATTRIBUTE48,
            PRICING_ATTRIBUTE49,
            PRICING_ATTRIBUTE50,
            PRICING_ATTRIBUTE51,
            PRICING_ATTRIBUTE52,
            PRICING_ATTRIBUTE53,
            PRICING_ATTRIBUTE54,
            PRICING_ATTRIBUTE55,
            PRICING_ATTRIBUTE56,
            PRICING_ATTRIBUTE57,
            PRICING_ATTRIBUTE58,
            PRICING_ATTRIBUTE59,
            PRICING_ATTRIBUTE60,
            PRICING_ATTRIBUTE61,
            PRICING_ATTRIBUTE62,
            PRICING_ATTRIBUTE63,
            PRICING_ATTRIBUTE64,
            PRICING_ATTRIBUTE65,
            PRICING_ATTRIBUTE66,
            PRICING_ATTRIBUTE67,
            PRICING_ATTRIBUTE68,
            PRICING_ATTRIBUTE69,
            PRICING_ATTRIBUTE70,
            PRICING_ATTRIBUTE71,
            PRICING_ATTRIBUTE72,
            PRICING_ATTRIBUTE73,
            PRICING_ATTRIBUTE74,
            PRICING_ATTRIBUTE75,
            PRICING_ATTRIBUTE76,
            PRICING_ATTRIBUTE77,
            PRICING_ATTRIBUTE78,
            PRICING_ATTRIBUTE79,
            PRICING_ATTRIBUTE80,
            PRICING_ATTRIBUTE81,
            PRICING_ATTRIBUTE82,
            PRICING_ATTRIBUTE83,
            PRICING_ATTRIBUTE84,
            PRICING_ATTRIBUTE85,
            PRICING_ATTRIBUTE86,
            PRICING_ATTRIBUTE87,
            PRICING_ATTRIBUTE88,
            PRICING_ATTRIBUTE89,
            PRICING_ATTRIBUTE90,
            PRICING_ATTRIBUTE91,
            PRICING_ATTRIBUTE92,
            PRICING_ATTRIBUTE93,
            PRICING_ATTRIBUTE94,
            PRICING_ATTRIBUTE95,
            PRICING_ATTRIBUTE96,
            PRICING_ATTRIBUTE97,
            PRICING_ATTRIBUTE98,
            PRICING_ATTRIBUTE99,
            PRICING_ATTRIBUTE100,
            QUALIFIER_CONTEXT,
            QUALIFIER_ATTRIBUTE1,
            QUALIFIER_ATTRIBUTE2,
            QUALIFIER_ATTRIBUTE3,
            QUALIFIER_ATTRIBUTE4,
            QUALIFIER_ATTRIBUTE5,
            QUALIFIER_ATTRIBUTE6,
            QUALIFIER_ATTRIBUTE7,
            QUALIFIER_ATTRIBUTE8,
            QUALIFIER_ATTRIBUTE9,
            QUALIFIER_ATTRIBUTE10,
            QUALIFIER_ATTRIBUTE11,
            QUALIFIER_ATTRIBUTE12,
            QUALIFIER_ATTRIBUTE13,
            QUALIFIER_ATTRIBUTE14,
            QUALIFIER_ATTRIBUTE15,
            QUALIFIER_ATTRIBUTE16,
            QUALIFIER_ATTRIBUTE17,
            QUALIFIER_ATTRIBUTE18,
            QUALIFIER_ATTRIBUTE19,
            QUALIFIER_ATTRIBUTE20,
            QUALIFIER_ATTRIBUTE21,
            QUALIFIER_ATTRIBUTE22,
            QUALIFIER_ATTRIBUTE23,
            QUALIFIER_ATTRIBUTE24,
            QUALIFIER_ATTRIBUTE25,
            QUALIFIER_ATTRIBUTE26,
            QUALIFIER_ATTRIBUTE27,
            QUALIFIER_ATTRIBUTE28,
            QUALIFIER_ATTRIBUTE29,
            QUALIFIER_ATTRIBUTE30,
            QUALIFIER_ATTRIBUTE31,
            QUALIFIER_ATTRIBUTE32,
            QUALIFIER_ATTRIBUTE33,
            QUALIFIER_ATTRIBUTE34,
            QUALIFIER_ATTRIBUTE35,
            QUALIFIER_ATTRIBUTE36,
            QUALIFIER_ATTRIBUTE37,
            QUALIFIER_ATTRIBUTE38,
            QUALIFIER_ATTRIBUTE39,
            QUALIFIER_ATTRIBUTE40,
            QUALIFIER_ATTRIBUTE41,
            QUALIFIER_ATTRIBUTE42,
            QUALIFIER_ATTRIBUTE43,
            QUALIFIER_ATTRIBUTE44,
            QUALIFIER_ATTRIBUTE45,
            QUALIFIER_ATTRIBUTE46,
            QUALIFIER_ATTRIBUTE47,
            QUALIFIER_ATTRIBUTE48,
            QUALIFIER_ATTRIBUTE49,
            QUALIFIER_ATTRIBUTE50,
            QUALIFIER_ATTRIBUTE51,
            QUALIFIER_ATTRIBUTE52,
            QUALIFIER_ATTRIBUTE53,
            QUALIFIER_ATTRIBUTE54,
            QUALIFIER_ATTRIBUTE55,
            QUALIFIER_ATTRIBUTE56,
            QUALIFIER_ATTRIBUTE57,
            QUALIFIER_ATTRIBUTE58,
            QUALIFIER_ATTRIBUTE59,
            QUALIFIER_ATTRIBUTE60,
            QUALIFIER_ATTRIBUTE61,
            QUALIFIER_ATTRIBUTE62,
            QUALIFIER_ATTRIBUTE63,
            QUALIFIER_ATTRIBUTE64,
            QUALIFIER_ATTRIBUTE65,
            QUALIFIER_ATTRIBUTE66,
            QUALIFIER_ATTRIBUTE67,
            QUALIFIER_ATTRIBUTE68,
            QUALIFIER_ATTRIBUTE69,
            QUALIFIER_ATTRIBUTE70,
            QUALIFIER_ATTRIBUTE71,
            QUALIFIER_ATTRIBUTE72,
            QUALIFIER_ATTRIBUTE73,
            QUALIFIER_ATTRIBUTE74,
            QUALIFIER_ATTRIBUTE75,
            QUALIFIER_ATTRIBUTE76,
            QUALIFIER_ATTRIBUTE77,
            QUALIFIER_ATTRIBUTE78,
            QUALIFIER_ATTRIBUTE79,
            QUALIFIER_ATTRIBUTE80,
            QUALIFIER_ATTRIBUTE81,
            QUALIFIER_ATTRIBUTE82,
            QUALIFIER_ATTRIBUTE83,
            QUALIFIER_ATTRIBUTE84,
            QUALIFIER_ATTRIBUTE85,
            QUALIFIER_ATTRIBUTE86,
            QUALIFIER_ATTRIBUTE87,
            QUALIFIER_ATTRIBUTE88,
            QUALIFIER_ATTRIBUTE89,
            QUALIFIER_ATTRIBUTE90,
            QUALIFIER_ATTRIBUTE91,
            QUALIFIER_ATTRIBUTE92,
            QUALIFIER_ATTRIBUTE93,
            QUALIFIER_ATTRIBUTE94,
            QUALIFIER_ATTRIBUTE95,
            QUALIFIER_ATTRIBUTE96,
            QUALIFIER_ATTRIBUTE97,
            QUALIFIER_ATTRIBUTE98,
            QUALIFIER_ATTRIBUTE99,
            QUALIFIER_ATTRIBUTE100,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
           OBJECT_VERSION_NUMBER
       FROM Okc_Price_Att_Values_V
     WHERE okc_price_att_values_v.id = p_id;
    l_okc_pavv_pk                  okc_pavv_pk_csr%ROWTYPE;
    l_pavv_rec                     OKC_PAV_PVT.pavv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_pavv_pk_csr (p_pavv_rec.id);
    FETCH okc_pavv_pk_csr INTO
              l_pavv_rec.ID,
              l_pavv_rec.CHR_ID,
              l_pavv_rec.CLE_ID,
              l_pavv_rec.FLEX_TITLE,
              l_pavv_rec.PRICING_CONTEXT,
              l_pavv_rec.PRICING_ATTRIBUTE1,
              l_pavv_rec.PRICING_ATTRIBUTE2,
              l_pavv_rec.PRICING_ATTRIBUTE3,
              l_pavv_rec.PRICING_ATTRIBUTE4,
              l_pavv_rec.PRICING_ATTRIBUTE5,
              l_pavv_rec.PRICING_ATTRIBUTE6,
              l_pavv_rec.PRICING_ATTRIBUTE7,
              l_pavv_rec.PRICING_ATTRIBUTE8,
              l_pavv_rec.PRICING_ATTRIBUTE9,
              l_pavv_rec.PRICING_ATTRIBUTE10,
              l_pavv_rec.PRICING_ATTRIBUTE11,
              l_pavv_rec.PRICING_ATTRIBUTE12,
              l_pavv_rec.PRICING_ATTRIBUTE13,
              l_pavv_rec.PRICING_ATTRIBUTE14,
              l_pavv_rec.PRICING_ATTRIBUTE15,
              l_pavv_rec.PRICING_ATTRIBUTE16,
              l_pavv_rec.PRICING_ATTRIBUTE17,
              l_pavv_rec.PRICING_ATTRIBUTE18,
              l_pavv_rec.PRICING_ATTRIBUTE19,
              l_pavv_rec.PRICING_ATTRIBUTE20,
              l_pavv_rec.PRICING_ATTRIBUTE21,
              l_pavv_rec.PRICING_ATTRIBUTE22,
              l_pavv_rec.PRICING_ATTRIBUTE23,
              l_pavv_rec.PRICING_ATTRIBUTE24,
              l_pavv_rec.PRICING_ATTRIBUTE25,
              l_pavv_rec.PRICING_ATTRIBUTE26,
              l_pavv_rec.PRICING_ATTRIBUTE27,
              l_pavv_rec.PRICING_ATTRIBUTE28,
              l_pavv_rec.PRICING_ATTRIBUTE29,
              l_pavv_rec.PRICING_ATTRIBUTE30,
              l_pavv_rec.PRICING_ATTRIBUTE31,
              l_pavv_rec.PRICING_ATTRIBUTE32,
              l_pavv_rec.PRICING_ATTRIBUTE33,
              l_pavv_rec.PRICING_ATTRIBUTE34,
              l_pavv_rec.PRICING_ATTRIBUTE35,
              l_pavv_rec.PRICING_ATTRIBUTE36,
              l_pavv_rec.PRICING_ATTRIBUTE37,
              l_pavv_rec.PRICING_ATTRIBUTE38,
              l_pavv_rec.PRICING_ATTRIBUTE39,
              l_pavv_rec.PRICING_ATTRIBUTE40,
              l_pavv_rec.PRICING_ATTRIBUTE41,
              l_pavv_rec.PRICING_ATTRIBUTE42,
              l_pavv_rec.PRICING_ATTRIBUTE43,
              l_pavv_rec.PRICING_ATTRIBUTE44,
              l_pavv_rec.PRICING_ATTRIBUTE45,
              l_pavv_rec.PRICING_ATTRIBUTE46,
              l_pavv_rec.PRICING_ATTRIBUTE47,
              l_pavv_rec.PRICING_ATTRIBUTE48,
              l_pavv_rec.PRICING_ATTRIBUTE49,
              l_pavv_rec.PRICING_ATTRIBUTE50,
              l_pavv_rec.PRICING_ATTRIBUTE51,
              l_pavv_rec.PRICING_ATTRIBUTE52,
              l_pavv_rec.PRICING_ATTRIBUTE53,
              l_pavv_rec.PRICING_ATTRIBUTE54,
              l_pavv_rec.PRICING_ATTRIBUTE55,
              l_pavv_rec.PRICING_ATTRIBUTE56,
              l_pavv_rec.PRICING_ATTRIBUTE57,
              l_pavv_rec.PRICING_ATTRIBUTE58,
              l_pavv_rec.PRICING_ATTRIBUTE59,
              l_pavv_rec.PRICING_ATTRIBUTE60,
              l_pavv_rec.PRICING_ATTRIBUTE61,
              l_pavv_rec.PRICING_ATTRIBUTE62,
              l_pavv_rec.PRICING_ATTRIBUTE63,
              l_pavv_rec.PRICING_ATTRIBUTE64,
              l_pavv_rec.PRICING_ATTRIBUTE65,
              l_pavv_rec.PRICING_ATTRIBUTE66,
              l_pavv_rec.PRICING_ATTRIBUTE67,
              l_pavv_rec.PRICING_ATTRIBUTE68,
              l_pavv_rec.PRICING_ATTRIBUTE69,
              l_pavv_rec.PRICING_ATTRIBUTE70,
              l_pavv_rec.PRICING_ATTRIBUTE71,
              l_pavv_rec.PRICING_ATTRIBUTE72,
              l_pavv_rec.PRICING_ATTRIBUTE73,
              l_pavv_rec.PRICING_ATTRIBUTE74,
              l_pavv_rec.PRICING_ATTRIBUTE75,
              l_pavv_rec.PRICING_ATTRIBUTE76,
              l_pavv_rec.PRICING_ATTRIBUTE77,
              l_pavv_rec.PRICING_ATTRIBUTE78,
              l_pavv_rec.PRICING_ATTRIBUTE79,
              l_pavv_rec.PRICING_ATTRIBUTE80,
              l_pavv_rec.PRICING_ATTRIBUTE81,
              l_pavv_rec.PRICING_ATTRIBUTE82,
              l_pavv_rec.PRICING_ATTRIBUTE83,
              l_pavv_rec.PRICING_ATTRIBUTE84,
              l_pavv_rec.PRICING_ATTRIBUTE85,
              l_pavv_rec.PRICING_ATTRIBUTE86,
              l_pavv_rec.PRICING_ATTRIBUTE87,
              l_pavv_rec.PRICING_ATTRIBUTE88,
              l_pavv_rec.PRICING_ATTRIBUTE89,
              l_pavv_rec.PRICING_ATTRIBUTE90,
              l_pavv_rec.PRICING_ATTRIBUTE91,
              l_pavv_rec.PRICING_ATTRIBUTE92,
              l_pavv_rec.PRICING_ATTRIBUTE93,
              l_pavv_rec.PRICING_ATTRIBUTE94,
              l_pavv_rec.PRICING_ATTRIBUTE95,
              l_pavv_rec.PRICING_ATTRIBUTE96,
              l_pavv_rec.PRICING_ATTRIBUTE97,
              l_pavv_rec.PRICING_ATTRIBUTE98,
              l_pavv_rec.PRICING_ATTRIBUTE99,
              l_pavv_rec.PRICING_ATTRIBUTE100,
              l_pavv_rec.QUALIFIER_CONTEXT,
              l_pavv_rec.QUALIFIER_ATTRIBUTE1,
              l_pavv_rec.QUALIFIER_ATTRIBUTE2,
              l_pavv_rec.QUALIFIER_ATTRIBUTE3,
              l_pavv_rec.QUALIFIER_ATTRIBUTE4,
              l_pavv_rec.QUALIFIER_ATTRIBUTE5,
              l_pavv_rec.QUALIFIER_ATTRIBUTE6,
              l_pavv_rec.QUALIFIER_ATTRIBUTE7,
              l_pavv_rec.QUALIFIER_ATTRIBUTE8,
              l_pavv_rec.QUALIFIER_ATTRIBUTE9,
              l_pavv_rec.QUALIFIER_ATTRIBUTE10,
              l_pavv_rec.QUALIFIER_ATTRIBUTE11,
              l_pavv_rec.QUALIFIER_ATTRIBUTE12,
              l_pavv_rec.QUALIFIER_ATTRIBUTE13,
              l_pavv_rec.QUALIFIER_ATTRIBUTE14,
              l_pavv_rec.QUALIFIER_ATTRIBUTE15,
              l_pavv_rec.QUALIFIER_ATTRIBUTE16,
              l_pavv_rec.QUALIFIER_ATTRIBUTE17,
              l_pavv_rec.QUALIFIER_ATTRIBUTE18,
              l_pavv_rec.QUALIFIER_ATTRIBUTE19,
              l_pavv_rec.QUALIFIER_ATTRIBUTE20,
              l_pavv_rec.QUALIFIER_ATTRIBUTE21,
              l_pavv_rec.QUALIFIER_ATTRIBUTE22,
              l_pavv_rec.QUALIFIER_ATTRIBUTE23,
              l_pavv_rec.QUALIFIER_ATTRIBUTE24,
              l_pavv_rec.QUALIFIER_ATTRIBUTE25,
              l_pavv_rec.QUALIFIER_ATTRIBUTE26,
              l_pavv_rec.QUALIFIER_ATTRIBUTE27,
              l_pavv_rec.QUALIFIER_ATTRIBUTE28,
              l_pavv_rec.QUALIFIER_ATTRIBUTE29,
              l_pavv_rec.QUALIFIER_ATTRIBUTE30,
              l_pavv_rec.QUALIFIER_ATTRIBUTE31,
              l_pavv_rec.QUALIFIER_ATTRIBUTE32,
              l_pavv_rec.QUALIFIER_ATTRIBUTE33,
              l_pavv_rec.QUALIFIER_ATTRIBUTE34,
              l_pavv_rec.QUALIFIER_ATTRIBUTE35,
              l_pavv_rec.QUALIFIER_ATTRIBUTE36,
              l_pavv_rec.QUALIFIER_ATTRIBUTE37,
              l_pavv_rec.QUALIFIER_ATTRIBUTE38,
              l_pavv_rec.QUALIFIER_ATTRIBUTE39,
              l_pavv_rec.QUALIFIER_ATTRIBUTE40,
              l_pavv_rec.QUALIFIER_ATTRIBUTE41,
              l_pavv_rec.QUALIFIER_ATTRIBUTE42,
              l_pavv_rec.QUALIFIER_ATTRIBUTE43,
              l_pavv_rec.QUALIFIER_ATTRIBUTE44,
              l_pavv_rec.QUALIFIER_ATTRIBUTE45,
              l_pavv_rec.QUALIFIER_ATTRIBUTE46,
              l_pavv_rec.QUALIFIER_ATTRIBUTE47,
              l_pavv_rec.QUALIFIER_ATTRIBUTE48,
              l_pavv_rec.QUALIFIER_ATTRIBUTE49,
              l_pavv_rec.QUALIFIER_ATTRIBUTE50,
              l_pavv_rec.QUALIFIER_ATTRIBUTE51,
              l_pavv_rec.QUALIFIER_ATTRIBUTE52,
              l_pavv_rec.QUALIFIER_ATTRIBUTE53,
              l_pavv_rec.QUALIFIER_ATTRIBUTE54,
              l_pavv_rec.QUALIFIER_ATTRIBUTE55,
              l_pavv_rec.QUALIFIER_ATTRIBUTE56,
              l_pavv_rec.QUALIFIER_ATTRIBUTE57,
              l_pavv_rec.QUALIFIER_ATTRIBUTE58,
              l_pavv_rec.QUALIFIER_ATTRIBUTE59,
              l_pavv_rec.QUALIFIER_ATTRIBUTE60,
              l_pavv_rec.QUALIFIER_ATTRIBUTE61,
              l_pavv_rec.QUALIFIER_ATTRIBUTE62,
              l_pavv_rec.QUALIFIER_ATTRIBUTE63,
              l_pavv_rec.QUALIFIER_ATTRIBUTE64,
              l_pavv_rec.QUALIFIER_ATTRIBUTE65,
              l_pavv_rec.QUALIFIER_ATTRIBUTE66,
              l_pavv_rec.QUALIFIER_ATTRIBUTE67,
              l_pavv_rec.QUALIFIER_ATTRIBUTE68,
              l_pavv_rec.QUALIFIER_ATTRIBUTE69,
              l_pavv_rec.QUALIFIER_ATTRIBUTE70,
              l_pavv_rec.QUALIFIER_ATTRIBUTE71,
              l_pavv_rec.QUALIFIER_ATTRIBUTE72,
              l_pavv_rec.QUALIFIER_ATTRIBUTE73,
              l_pavv_rec.QUALIFIER_ATTRIBUTE74,
              l_pavv_rec.QUALIFIER_ATTRIBUTE75,
              l_pavv_rec.QUALIFIER_ATTRIBUTE76,
              l_pavv_rec.QUALIFIER_ATTRIBUTE77,
              l_pavv_rec.QUALIFIER_ATTRIBUTE78,
              l_pavv_rec.QUALIFIER_ATTRIBUTE79,
              l_pavv_rec.QUALIFIER_ATTRIBUTE80,
              l_pavv_rec.QUALIFIER_ATTRIBUTE81,
              l_pavv_rec.QUALIFIER_ATTRIBUTE82,
              l_pavv_rec.QUALIFIER_ATTRIBUTE83,
              l_pavv_rec.QUALIFIER_ATTRIBUTE84,
              l_pavv_rec.QUALIFIER_ATTRIBUTE85,
              l_pavv_rec.QUALIFIER_ATTRIBUTE86,
              l_pavv_rec.QUALIFIER_ATTRIBUTE87,
              l_pavv_rec.QUALIFIER_ATTRIBUTE88,
              l_pavv_rec.QUALIFIER_ATTRIBUTE89,
              l_pavv_rec.QUALIFIER_ATTRIBUTE90,
              l_pavv_rec.QUALIFIER_ATTRIBUTE91,
              l_pavv_rec.QUALIFIER_ATTRIBUTE92,
              l_pavv_rec.QUALIFIER_ATTRIBUTE93,
              l_pavv_rec.QUALIFIER_ATTRIBUTE94,
              l_pavv_rec.QUALIFIER_ATTRIBUTE95,
              l_pavv_rec.QUALIFIER_ATTRIBUTE96,
              l_pavv_rec.QUALIFIER_ATTRIBUTE97,
              l_pavv_rec.QUALIFIER_ATTRIBUTE98,
              l_pavv_rec.QUALIFIER_ATTRIBUTE99,
              l_pavv_rec.QUALIFIER_ATTRIBUTE100,
              l_pavv_rec.CREATED_BY,
              l_pavv_rec.CREATION_DATE,
              l_pavv_rec.LAST_UPDATED_BY,
              l_pavv_rec.LAST_UPDATE_DATE,
              l_pavv_rec.LAST_UPDATE_LOGIN,
              l_pavv_rec.PROGRAM_APPLICATION_ID,
              l_pavv_rec.PROGRAM_ID,
              l_pavv_rec.PROGRAM_UPDATE_DATE,
              l_pavv_rec.REQUEST_ID,
              l_pavv_rec.OBJECT_VERSION_NUMBER;
    x_no_data_found := okc_pavv_pk_csr%NOTFOUND;
    CLOSE okc_pavv_pk_csr;
    RETURN(l_pavv_rec);
  END get_rec;

------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_PRICE_ATT_VALUES_V --
  ------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_pavv_rec	IN OKC_PAV_PVT.pavv_rec_type
  ) RETURN OKC_PAV_PVT.pavv_rec_type IS
    l_pavv_rec	OKC_PAV_PVT.pavv_rec_type := p_pavv_rec;
  BEGIN
    IF (l_pavv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_pavv_rec.chr_id := NULL;
    END IF;
    IF (l_pavv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_pavv_rec.cle_id := NULL;
    END IF;
    IF (l_pavv_rec.flex_title = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.flex_title := NULL;
    END IF;
    IF (l_pavv_rec.pricing_context = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_context := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute1 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute2 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute3 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute4 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute5 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute6 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute7 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute8 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute9 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute10 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute11 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute12 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute13 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute14 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute15 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute16 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute16 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute17 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute17 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute18 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute18 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute19 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute19 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute20 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute20 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute21 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute21 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute22 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute22 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute23 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute23 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute24 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute24 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute25 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute25 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute26 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute26 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute27 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute27 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute28 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute28 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute29 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute29 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute30 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute30 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute31 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute31 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute32 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute32 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute33 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute33 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute34 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute34 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute35 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute35 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute36 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute36 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute37 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute37 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute38 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute38 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute39 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute39 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute40 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute40 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute41 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute41 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute42 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute42 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute43 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute43 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute44 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute44 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute45 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute45 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute46 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute46 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute47 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute47 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute48 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute48 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute49 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute49 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute50 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute50 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute51 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute51 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute52 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute52 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute53 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute53 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute54 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute54 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute55 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute55 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute56 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute56 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute57 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute57 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute58 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute58 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute59 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute59 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute60 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute60 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute61 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute61 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute62 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute62 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute63 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute63 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute64 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute64 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute65 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute65 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute66 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute66 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute67 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute67 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute68 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute68 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute69 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute69 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute70 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute70 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute71 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute71 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute72 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute72 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute73 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute73 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute74 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute74 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute75 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute75 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute76 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute76 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute77 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute77 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute78 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute78 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute79 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute79 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute80 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute80 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute81 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute81 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute82 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute82 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute83 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute83 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute84 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute84 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute85 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute85 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute86 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute86 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute87 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute87 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute88 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute88 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute89 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute89 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute90 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute90 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute91 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute91 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute92 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute92 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute93 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute93 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute94 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute94 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute95 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute95 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute96 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute96 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute97 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute97 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute98 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute98 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute99 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute99 := NULL;
    END IF;
    IF (l_pavv_rec.pricing_attribute100 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.pricing_attribute100 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_context = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_context := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute1 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute2 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute3 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute4 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute5 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute6 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute7 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute8 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute9 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute10 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute11 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute12 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute13 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute14 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute15 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute16 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute16 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute17 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute17 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute18 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute18 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute19 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute19 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute20 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute20 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute21 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute21 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute22 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute22 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute23 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute23 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute24 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute24 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute25 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute25 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute26 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute26 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute27 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute27 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute28 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute28 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute29 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute29 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute30 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute30 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute31 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute31 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute32 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute32 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute33 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute33 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute34 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute34 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute35 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute35 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute36 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute36 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute37 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute37 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute38 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute38 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute39 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute39 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute40 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute40 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute41 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute41 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute42 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute42 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute43 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute43 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute44 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute44 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute45 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute45 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute46 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute46 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute47 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute47 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute48 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute48 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute49 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute49 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute50 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute50 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute51 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute51 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute52 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute52 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute53 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute53 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute54 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute54 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute55 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute55 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute56 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute56 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute57 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute57 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute58 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute58 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute59 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute59 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute60 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute60 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute61 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute61 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute62 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute62 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute63 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute63 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute64 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute64 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute65 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute65 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute66 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute66 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute67 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute67 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute68 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute68 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute69 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute69 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute70 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute70 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute71 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute71 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute72 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute72 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute73 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute73 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute74 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute74 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute75 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute75 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute76 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute76 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute77 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute77 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute78 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute78 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute79 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute79 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute80 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute80 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute81 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute81 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute82 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute82 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute83 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute83 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute84 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute84 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute85 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute85 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute86 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute86 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute87 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute87 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute88 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute88 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute89 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute89 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute90 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute90 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute91 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute91 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute92 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute92 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute93 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute93 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute94 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute94 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute95 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute95 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute96 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute96 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute97 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute97 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute98 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute98 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute99 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute99 := NULL;
    END IF;
    IF (l_pavv_rec.qualifier_attribute100 = OKC_API.G_MISS_CHAR) THEN
      l_pavv_rec.qualifier_attribute100 := NULL;
    END IF;
    IF (l_pavv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_pavv_rec.created_by := NULL;
    END IF;
    IF (l_pavv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_pavv_rec.creation_date := NULL;
    END IF;
    IF (l_pavv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_pavv_rec.last_updated_by := NULL;
    END IF;
    IF (l_pavv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_pavv_rec.last_update_date := NULL;
    END IF;
    IF (l_pavv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_pavv_rec.last_update_login := NULL;
    END IF;
  IF (l_pavv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_pavv_rec.program_application_id := NULL;
    END IF;
    IF (l_pavv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_pavv_rec.program_id := NULL;
    END IF;
  IF (l_pavv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_pavv_rec.program_update_date := NULL;
    END IF;
    IF (l_pavv_rec.request_id= OKC_API.G_MISS_NUM) THEN
      l_pavv_rec.request_id := NULL;
      END IF;
 IF (l_pavv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_pavv_rec.object_version_number := NULL;
    END IF;

    RETURN(l_pavv_rec);
  END null_out_defaults;

END OKC_SPLIT1_PAV_PVT;

/
