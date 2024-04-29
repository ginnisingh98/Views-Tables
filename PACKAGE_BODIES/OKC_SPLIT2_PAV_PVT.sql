--------------------------------------------------------
--  DDL for Package Body OKC_SPLIT2_PAV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SPLIT2_PAV_PVT" AS
/* $Header: OKCSPAVSPTB.pls 120.0.12010000.3 2010/12/16 11:02:53 nvvaidya noship $ */
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN OKC_PAV_PVT.pavv_rec_type,
    p_to	IN OUT NOCOPY OKC_PAV_PVT.pav_rec_type
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

FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO okc_price_att_values
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
       object_version_number
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
        object_version_number
FROM    okc_price_att_values_h
WHERE   chr_id = p_chr_id
AND     major_version = p_major_version
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
        object_version_number
FROM    okc_price_att_values_h
WHERE   cle_id IN
           (SELECT id
            FROM OKC_K_LINES_B
            WHERE dnz_chr_id = p_chr_id
           )
AND     major_version = p_major_version;

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
END restore_version;
---------------------------------------------------------------
-- Procedure for mass insert in OKC_PRICE_ATT_VALUES _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_pavv_tbl OKC_PAV_PVT.pavv_tbl_type) IS
  l_tabsize NUMBER := p_pavv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_chr_id                        OKC_DATATYPES.NumberTabTyp;
  in_cle_id                        OKC_DATATYPES.NumberTabTyp;
  in_flex_title                    OKC_DATATYPES.Var200TabTyp;
  in_pricing_context               OKC_DATATYPES.Var90TabTyp;
  in_pricing_attribute1            OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute2            OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute3            OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute4            OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute5            OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute6            OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute7            OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute8            OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute9            OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute10           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute11           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute12           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute13           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute14           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute15           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute16           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute17           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute18           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute19           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute20           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute21           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute22           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute23           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute24           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute25           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute26           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute27           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute28           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute29           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute30           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute31           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute32           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute33           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute34           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute35           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute36           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute37           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute38           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute39           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute40           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute41           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute42           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute43           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute44           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute45           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute46           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute47           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute48           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute49           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute50           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute51           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute52           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute53           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute54           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute55           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute56           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute57           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute58           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute59           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute60           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute61           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute62           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute63           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute64           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute65           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute66           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute67           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute68           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute69           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute70           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute71           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute72           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute73           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute74           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute75           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute76           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute77           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute78           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute79           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute80           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute81           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute82           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute83           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute84           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute85           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute86           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute87           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute88           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute89           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute90           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute91           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute92           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute93           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute94           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute95           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute96           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute97           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute98           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute99           OKC_DATATYPES.Var1995TabTyp;
  in_pricing_attribute100          OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_context             OKC_DATATYPES.Var90TabTyp;
  in_qualifier_attribute1          OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute2          OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute3          OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute4          OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute5          OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute6          OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute7          OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute8          OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute9          OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute10         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute11         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute12         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute13         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute14         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute15         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute16         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute17         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute18         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute19         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute20         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute21         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute22         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute23         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute24         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute25         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute26         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute27         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute28         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute29         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute30         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute31         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute32         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute33         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute34         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute35         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute36         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute37         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute38         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute39         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute40         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute41         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute42         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute43         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute44         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute45         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute46         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute47         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute48         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute49         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute50         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute51         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute52         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute53         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute54         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute55         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute56         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute57         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute58         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute59         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute60         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute61         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute62         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute63         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute64         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute65         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute66         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute67         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute68         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute69         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute70         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute71         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute72         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute73         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute74         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute75         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute76         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute77         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute78         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute79         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute80         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute81         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute82         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute83         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute84         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute85         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute86         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute87         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute88         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute89         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute90         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute91         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute92         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute93         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute94         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute95         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute96         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute97         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute98         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute99         OKC_DATATYPES.Var1995TabTyp;
  in_qualifier_attribute100        OKC_DATATYPES.Var1995TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
 in_program_application_id        OKC_DATATYPES.NumberTabTyp;
  in_program_id                    OKC_DATATYPES.NumberTabTyp;
  in_program_update_date          OKC_DATATYPES.DateTabTyp;
  in_request_id                   OKC_DATATYPES.NumberTabTyp;
  in_object_version_number           OKC_DATATYPES.NumberTabTyp;
  i number;
  j number;
BEGIN
  --Initialize return status
   x_return_status :=OKC_API.G_RET_STS_SUCCESS;
  i := p_pavv_tbl.FIRST; j:=0;
  while i is not null
  LOOP
    j:=j+1;
    in_id                       (j) := p_pavv_tbl(i).id;
    in_chr_id                   (j) := p_pavv_tbl(i).chr_id;
    in_cle_id                   (j) := p_pavv_tbl(i).cle_id;
    in_flex_title               (j) := p_pavv_tbl(i).flex_title;
    in_pricing_context          (j) := p_pavv_tbl(i).pricing_context;
    in_pricing_attribute1       (j) := p_pavv_tbl(i).pricing_attribute1;
    in_pricing_attribute2       (j) := p_pavv_tbl(i).pricing_attribute2;
    in_pricing_attribute3       (j) := p_pavv_tbl(i).pricing_attribute3;
    in_pricing_attribute4       (j) := p_pavv_tbl(i).pricing_attribute4;
    in_pricing_attribute5       (j) := p_pavv_tbl(i).pricing_attribute5;
    in_pricing_attribute6       (j) := p_pavv_tbl(i).pricing_attribute6;
    in_pricing_attribute7       (j) := p_pavv_tbl(i).pricing_attribute7;
    in_pricing_attribute8       (j) := p_pavv_tbl(i).pricing_attribute8;
    in_pricing_attribute9       (j) := p_pavv_tbl(i).pricing_attribute9;
    in_pricing_attribute10      (j) := p_pavv_tbl(i).pricing_attribute10;
    in_pricing_attribute11      (j) := p_pavv_tbl(i).pricing_attribute11;
    in_pricing_attribute12      (j) := p_pavv_tbl(i).pricing_attribute12;
    in_pricing_attribute13      (j) := p_pavv_tbl(i).pricing_attribute13;
    in_pricing_attribute14      (j) := p_pavv_tbl(i).pricing_attribute14;
    in_pricing_attribute15      (j) := p_pavv_tbl(i).pricing_attribute15;
    in_pricing_attribute16      (j) := p_pavv_tbl(i).pricing_attribute16;
    in_pricing_attribute17      (j) := p_pavv_tbl(i).pricing_attribute17;
    in_pricing_attribute18      (j) := p_pavv_tbl(i).pricing_attribute18;
    in_pricing_attribute19      (j) := p_pavv_tbl(i).pricing_attribute19;
    in_pricing_attribute20      (j) := p_pavv_tbl(i).pricing_attribute20;
    in_pricing_attribute21      (j) := p_pavv_tbl(i).pricing_attribute21;
    in_pricing_attribute22      (j) := p_pavv_tbl(i).pricing_attribute22;
    in_pricing_attribute23      (j) := p_pavv_tbl(i).pricing_attribute23;
    in_pricing_attribute24      (j) := p_pavv_tbl(i).pricing_attribute24;
    in_pricing_attribute25      (j) := p_pavv_tbl(i).pricing_attribute25;
    in_pricing_attribute26      (j) := p_pavv_tbl(i).pricing_attribute26;
    in_pricing_attribute27      (j) := p_pavv_tbl(i).pricing_attribute27;
    in_pricing_attribute28      (j) := p_pavv_tbl(i).pricing_attribute28;
    in_pricing_attribute29      (j) := p_pavv_tbl(i).pricing_attribute29;
    in_pricing_attribute30      (j) := p_pavv_tbl(i).pricing_attribute30;
    in_pricing_attribute31      (j) := p_pavv_tbl(i).pricing_attribute31;
    in_pricing_attribute32      (j) := p_pavv_tbl(i).pricing_attribute32;
    in_pricing_attribute33      (j) := p_pavv_tbl(i).pricing_attribute33;
    in_pricing_attribute34      (j) := p_pavv_tbl(i).pricing_attribute34;
    in_pricing_attribute35      (j) := p_pavv_tbl(i).pricing_attribute35;
    in_pricing_attribute36      (j) := p_pavv_tbl(i).pricing_attribute36;
    in_pricing_attribute37      (j) := p_pavv_tbl(i).pricing_attribute37;
    in_pricing_attribute38      (j) := p_pavv_tbl(i).pricing_attribute38;
    in_pricing_attribute39      (j) := p_pavv_tbl(i).pricing_attribute39;
    in_pricing_attribute40      (j) := p_pavv_tbl(i).pricing_attribute40;
    in_pricing_attribute41      (j) := p_pavv_tbl(i).pricing_attribute41;
    in_pricing_attribute42      (j) := p_pavv_tbl(i).pricing_attribute42;
    in_pricing_attribute43      (j) := p_pavv_tbl(i).pricing_attribute43;
    in_pricing_attribute44      (j) := p_pavv_tbl(i).pricing_attribute44;
    in_pricing_attribute45      (j) := p_pavv_tbl(i).pricing_attribute45;
    in_pricing_attribute46      (j) := p_pavv_tbl(i).pricing_attribute46;
    in_pricing_attribute47      (j) := p_pavv_tbl(i).pricing_attribute47;
    in_pricing_attribute48      (j) := p_pavv_tbl(i).pricing_attribute48;
    in_pricing_attribute49      (j) := p_pavv_tbl(i).pricing_attribute49;
    in_pricing_attribute50      (j) := p_pavv_tbl(i).pricing_attribute50;
    in_pricing_attribute51      (j) := p_pavv_tbl(i).pricing_attribute51;
    in_pricing_attribute52      (j) := p_pavv_tbl(i).pricing_attribute52;
    in_pricing_attribute53      (j) := p_pavv_tbl(i).pricing_attribute53;
    in_pricing_attribute54      (j) := p_pavv_tbl(i).pricing_attribute54;
    in_pricing_attribute55      (j) := p_pavv_tbl(i).pricing_attribute55;
    in_pricing_attribute56      (j) := p_pavv_tbl(i).pricing_attribute56;
    in_pricing_attribute57      (j) := p_pavv_tbl(i).pricing_attribute57;
    in_pricing_attribute58      (j) := p_pavv_tbl(i).pricing_attribute58;
    in_pricing_attribute59      (j) := p_pavv_tbl(i).pricing_attribute59;
    in_pricing_attribute60      (j) := p_pavv_tbl(i).pricing_attribute60;
    in_pricing_attribute61      (j) := p_pavv_tbl(i).pricing_attribute61;
    in_pricing_attribute62      (j) := p_pavv_tbl(i).pricing_attribute62;
    in_pricing_attribute63      (j) := p_pavv_tbl(i).pricing_attribute63;
    in_pricing_attribute64      (j) := p_pavv_tbl(i).pricing_attribute64;
    in_pricing_attribute65      (j) := p_pavv_tbl(i).pricing_attribute65;
    in_pricing_attribute66      (j) := p_pavv_tbl(i).pricing_attribute66;
    in_pricing_attribute67      (j) := p_pavv_tbl(i).pricing_attribute67;
    in_pricing_attribute68      (j) := p_pavv_tbl(i).pricing_attribute68;
    in_pricing_attribute69      (j) := p_pavv_tbl(i).pricing_attribute69;
    in_pricing_attribute70      (j) := p_pavv_tbl(i).pricing_attribute70;
    in_pricing_attribute71      (j) := p_pavv_tbl(i).pricing_attribute71;
    in_pricing_attribute72      (j) := p_pavv_tbl(i).pricing_attribute72;
    in_pricing_attribute73      (j) := p_pavv_tbl(i).pricing_attribute73;
    in_pricing_attribute74      (j) := p_pavv_tbl(i).pricing_attribute74;
    in_pricing_attribute75      (j) := p_pavv_tbl(i).pricing_attribute75;
    in_pricing_attribute76      (j) := p_pavv_tbl(i).pricing_attribute76;
    in_pricing_attribute77      (j) := p_pavv_tbl(i).pricing_attribute77;
    in_pricing_attribute78      (j) := p_pavv_tbl(i).pricing_attribute78;
    in_pricing_attribute79      (j) := p_pavv_tbl(i).pricing_attribute79;
    in_pricing_attribute80      (j) := p_pavv_tbl(i).pricing_attribute80;
    in_pricing_attribute81      (j) := p_pavv_tbl(i).pricing_attribute81;
    in_pricing_attribute82      (j) := p_pavv_tbl(i).pricing_attribute82;
    in_pricing_attribute83      (j) := p_pavv_tbl(i).pricing_attribute83;
    in_pricing_attribute84      (j) := p_pavv_tbl(i).pricing_attribute84;
    in_pricing_attribute85      (j) := p_pavv_tbl(i).pricing_attribute85;
    in_pricing_attribute86      (j) := p_pavv_tbl(i).pricing_attribute86;
    in_pricing_attribute87      (j) := p_pavv_tbl(i).pricing_attribute87;
    in_pricing_attribute88      (j) := p_pavv_tbl(i).pricing_attribute88;
    in_pricing_attribute89      (j) := p_pavv_tbl(i).pricing_attribute89;
    in_pricing_attribute90      (j) := p_pavv_tbl(i).pricing_attribute90;
    in_pricing_attribute91      (j) := p_pavv_tbl(i).pricing_attribute91;
    in_pricing_attribute92      (j) := p_pavv_tbl(i).pricing_attribute92;
    in_pricing_attribute93      (j) := p_pavv_tbl(i).pricing_attribute93;
    in_pricing_attribute94      (j) := p_pavv_tbl(i).pricing_attribute94;
    in_pricing_attribute95      (j) := p_pavv_tbl(i).pricing_attribute95;
    in_pricing_attribute96      (j) := p_pavv_tbl(i).pricing_attribute96;
    in_pricing_attribute97      (j) := p_pavv_tbl(i).pricing_attribute97;
    in_pricing_attribute98      (j) := p_pavv_tbl(i).pricing_attribute98;
    in_pricing_attribute99      (j) := p_pavv_tbl(i).pricing_attribute99;
    in_pricing_attribute100     (j) := p_pavv_tbl(i).pricing_attribute100;
    in_qualifier_context        (j) := p_pavv_tbl(i).qualifier_context;
    in_qualifier_attribute1     (j) := p_pavv_tbl(i).qualifier_attribute1;
    in_qualifier_attribute2     (j) := p_pavv_tbl(i).qualifier_attribute2;
    in_qualifier_attribute3     (j) := p_pavv_tbl(i).qualifier_attribute3;
    in_qualifier_attribute4     (j) := p_pavv_tbl(i).qualifier_attribute4;
    in_qualifier_attribute5     (j) := p_pavv_tbl(i).qualifier_attribute5;
    in_qualifier_attribute6     (j) := p_pavv_tbl(i).qualifier_attribute6;
    in_qualifier_attribute7     (j) := p_pavv_tbl(i).qualifier_attribute7;
    in_qualifier_attribute8     (j) := p_pavv_tbl(i).qualifier_attribute8;
    in_qualifier_attribute9     (j) := p_pavv_tbl(i).qualifier_attribute9;
    in_qualifier_attribute10    (j) := p_pavv_tbl(i).qualifier_attribute10;
    in_qualifier_attribute11    (j) := p_pavv_tbl(i).qualifier_attribute11;
    in_qualifier_attribute12    (j) := p_pavv_tbl(i).qualifier_attribute12;
    in_qualifier_attribute13    (j) := p_pavv_tbl(i).qualifier_attribute13;
    in_qualifier_attribute14    (j) := p_pavv_tbl(i).qualifier_attribute14;
    in_qualifier_attribute15    (j) := p_pavv_tbl(i).qualifier_attribute15;
    in_qualifier_attribute16    (j) := p_pavv_tbl(i).qualifier_attribute16;
    in_qualifier_attribute17    (j) := p_pavv_tbl(i).qualifier_attribute17;
    in_qualifier_attribute18    (j) := p_pavv_tbl(i).qualifier_attribute18;
    in_qualifier_attribute19    (j) := p_pavv_tbl(i).qualifier_attribute19;
    in_qualifier_attribute20    (j) := p_pavv_tbl(i).qualifier_attribute20;
    in_qualifier_attribute21    (j) := p_pavv_tbl(i).qualifier_attribute21;
    in_qualifier_attribute22    (j) := p_pavv_tbl(i).qualifier_attribute22;
    in_qualifier_attribute23    (j) := p_pavv_tbl(i).qualifier_attribute23;
    in_qualifier_attribute24    (j) := p_pavv_tbl(i).qualifier_attribute24;
    in_qualifier_attribute25    (j) := p_pavv_tbl(i).qualifier_attribute25;
    in_qualifier_attribute26    (j) := p_pavv_tbl(i).qualifier_attribute26;
    in_qualifier_attribute27    (j) := p_pavv_tbl(i).qualifier_attribute27;
    in_qualifier_attribute28    (j) := p_pavv_tbl(i).qualifier_attribute28;
    in_qualifier_attribute29    (j) := p_pavv_tbl(i).qualifier_attribute29;
    in_qualifier_attribute30    (j) := p_pavv_tbl(i).qualifier_attribute30;
    in_qualifier_attribute31    (j) := p_pavv_tbl(i).qualifier_attribute31;
    in_qualifier_attribute32    (j) := p_pavv_tbl(i).qualifier_attribute32;
    in_qualifier_attribute33    (j) := p_pavv_tbl(i).qualifier_attribute33;
    in_qualifier_attribute34    (j) := p_pavv_tbl(i).qualifier_attribute34;
    in_qualifier_attribute35    (j) := p_pavv_tbl(i).qualifier_attribute35;
    in_qualifier_attribute36    (j) := p_pavv_tbl(i).qualifier_attribute36;
    in_qualifier_attribute37    (j) := p_pavv_tbl(i).qualifier_attribute37;
    in_qualifier_attribute38    (j) := p_pavv_tbl(i).qualifier_attribute38;
    in_qualifier_attribute39    (j) := p_pavv_tbl(i).qualifier_attribute39;
    in_qualifier_attribute40    (j) := p_pavv_tbl(i).qualifier_attribute40;
    in_qualifier_attribute41    (j) := p_pavv_tbl(i).qualifier_attribute41;
    in_qualifier_attribute42    (j) := p_pavv_tbl(i).qualifier_attribute42;
    in_qualifier_attribute43    (j) := p_pavv_tbl(i).qualifier_attribute43;
    in_qualifier_attribute44    (j) := p_pavv_tbl(i).qualifier_attribute44;
    in_qualifier_attribute45    (j) := p_pavv_tbl(i).qualifier_attribute45;
    in_qualifier_attribute46    (j) := p_pavv_tbl(i).qualifier_attribute46;
    in_qualifier_attribute47    (j) := p_pavv_tbl(i).qualifier_attribute47;
    in_qualifier_attribute48    (j) := p_pavv_tbl(i).qualifier_attribute48;
    in_qualifier_attribute49    (j) := p_pavv_tbl(i).qualifier_attribute49;
    in_qualifier_attribute50    (j) := p_pavv_tbl(i).qualifier_attribute50;
    in_qualifier_attribute51    (j) := p_pavv_tbl(i).qualifier_attribute51;
    in_qualifier_attribute52    (j) := p_pavv_tbl(i).qualifier_attribute52;
    in_qualifier_attribute53    (j) := p_pavv_tbl(i).qualifier_attribute53;
    in_qualifier_attribute54    (j) := p_pavv_tbl(i).qualifier_attribute54;
    in_qualifier_attribute55    (j) := p_pavv_tbl(i).qualifier_attribute55;
    in_qualifier_attribute56    (j) := p_pavv_tbl(i).qualifier_attribute56;
    in_qualifier_attribute57    (j) := p_pavv_tbl(i).qualifier_attribute57;
    in_qualifier_attribute58    (j) := p_pavv_tbl(i).qualifier_attribute58;
    in_qualifier_attribute59    (j) := p_pavv_tbl(i).qualifier_attribute59;
    in_qualifier_attribute60    (j) := p_pavv_tbl(i).qualifier_attribute60;
    in_qualifier_attribute61    (j) := p_pavv_tbl(i).qualifier_attribute61;
    in_qualifier_attribute62    (j) := p_pavv_tbl(i).qualifier_attribute62;
    in_qualifier_attribute63    (j) := p_pavv_tbl(i).qualifier_attribute63;
    in_qualifier_attribute64    (j) := p_pavv_tbl(i).qualifier_attribute64;
    in_qualifier_attribute65    (j) := p_pavv_tbl(i).qualifier_attribute65;
    in_qualifier_attribute66    (j) := p_pavv_tbl(i).qualifier_attribute66;
    in_qualifier_attribute67    (j) := p_pavv_tbl(i).qualifier_attribute67;
    in_qualifier_attribute68    (j) := p_pavv_tbl(i).qualifier_attribute68;
    in_qualifier_attribute69    (j) := p_pavv_tbl(i).qualifier_attribute69;
    in_qualifier_attribute70    (j) := p_pavv_tbl(i).qualifier_attribute70;
    in_qualifier_attribute71    (j) := p_pavv_tbl(i).qualifier_attribute71;
    in_qualifier_attribute72    (j) := p_pavv_tbl(i).qualifier_attribute72;
    in_qualifier_attribute73    (j) := p_pavv_tbl(i).qualifier_attribute73;
    in_qualifier_attribute74    (j) := p_pavv_tbl(i).qualifier_attribute74;
    in_qualifier_attribute75    (j) := p_pavv_tbl(i).qualifier_attribute75;
    in_qualifier_attribute76    (j) := p_pavv_tbl(i).qualifier_attribute76;
    in_qualifier_attribute77    (j) := p_pavv_tbl(i).qualifier_attribute77;
    in_qualifier_attribute78    (j) := p_pavv_tbl(i).qualifier_attribute78;
    in_qualifier_attribute79    (j) := p_pavv_tbl(i).qualifier_attribute79;
    in_qualifier_attribute80    (j) := p_pavv_tbl(i).qualifier_attribute80;
    in_qualifier_attribute81    (j) := p_pavv_tbl(i).qualifier_attribute81;
    in_qualifier_attribute82    (j) := p_pavv_tbl(i).qualifier_attribute82;
    in_qualifier_attribute83    (j) := p_pavv_tbl(i).qualifier_attribute83;
    in_qualifier_attribute84    (j) := p_pavv_tbl(i).qualifier_attribute84;
    in_qualifier_attribute85    (j) := p_pavv_tbl(i).qualifier_attribute85;
    in_qualifier_attribute86    (j) := p_pavv_tbl(i).qualifier_attribute86;
    in_qualifier_attribute87    (j) := p_pavv_tbl(i).qualifier_attribute87;
    in_qualifier_attribute88    (j) := p_pavv_tbl(i).qualifier_attribute88;
    in_qualifier_attribute89    (j) := p_pavv_tbl(i).qualifier_attribute89;
    in_qualifier_attribute90    (j) := p_pavv_tbl(i).qualifier_attribute90;
    in_qualifier_attribute91    (j) := p_pavv_tbl(i).qualifier_attribute91;
    in_qualifier_attribute92    (j) := p_pavv_tbl(i).qualifier_attribute92;
    in_qualifier_attribute93    (j) := p_pavv_tbl(i).qualifier_attribute93;
    in_qualifier_attribute94    (j) := p_pavv_tbl(i).qualifier_attribute94;
    in_qualifier_attribute95    (j) := p_pavv_tbl(i).qualifier_attribute95;
    in_qualifier_attribute96    (j) := p_pavv_tbl(i).qualifier_attribute96;
    in_qualifier_attribute97    (j) := p_pavv_tbl(i).qualifier_attribute97;
    in_qualifier_attribute98    (j) := p_pavv_tbl(i).qualifier_attribute98;
    in_qualifier_attribute99    (j) := p_pavv_tbl(i).qualifier_attribute99;
    in_qualifier_attribute100   (j) := p_pavv_tbl(i).qualifier_attribute100;
    in_created_by               (j) := p_pavv_tbl(i).created_by;
    in_creation_date            (j) := p_pavv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_pavv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_pavv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_pavv_tbl(i).last_update_login;
    in_program_application_id     (j) := p_pavv_tbl(i).program_application_id;
    in_program_id                  (j) := p_pavv_tbl(i).program_id;
    in_program_update_date        (j) := p_pavv_tbl(i).program_update_date;
    in_request_id             (j) := p_pavv_tbl(i).request_id;
    in_object_version_number        (j) := p_pavv_tbl(i).object_version_number;
    i:=p_pavv_tbl.next(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_PRICE_ATT_VALUES
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
        object_version_number)
     VALUES (
        in_id(i),
        in_flex_title(i),
        in_pricing_context(i),
        in_pricing_attribute1(i),
        in_chr_id(i),
        in_pricing_attribute2(i),
        in_cle_id(i),
        in_pricing_attribute3(i),
        in_pricing_attribute4(i),
        in_pricing_attribute5(i),
        in_pricing_attribute6(i),
        in_pricing_attribute7(i),
        in_pricing_attribute8(i),
        in_pricing_attribute9(i),
        in_pricing_attribute10(i),
        in_pricing_attribute11(i),
        in_pricing_attribute12(i),
        in_pricing_attribute13(i),
        in_pricing_attribute14(i),
        in_pricing_attribute15(i),
        in_pricing_attribute16(i),
        in_pricing_attribute17(i),
        in_pricing_attribute18(i),
        in_pricing_attribute19(i),
        in_pricing_attribute20(i),
        in_pricing_attribute21(i),
        in_pricing_attribute22(i),
        in_pricing_attribute23(i),
        in_pricing_attribute24(i),
        in_pricing_attribute25(i),
        in_pricing_attribute26(i),
        in_pricing_attribute27(i),
        in_pricing_attribute28(i),
        in_pricing_attribute29(i),
        in_pricing_attribute30(i),
        in_pricing_attribute31(i),
        in_pricing_attribute32(i),
        in_pricing_attribute33(i),
        in_pricing_attribute34(i),
        in_pricing_attribute35(i),
        in_pricing_attribute36(i),
        in_pricing_attribute37(i),
        in_pricing_attribute38(i),
        in_pricing_attribute39(i),
        in_pricing_attribute40(i),
        in_pricing_attribute41(i),
        in_pricing_attribute42(i),
        in_pricing_attribute43(i),
        in_pricing_attribute44(i),
        in_pricing_attribute45(i),
        in_pricing_attribute46(i),
        in_pricing_attribute47(i),
        in_pricing_attribute48(i),
        in_pricing_attribute49(i),
        in_pricing_attribute50(i),
        in_pricing_attribute51(i),
        in_pricing_attribute52(i),
        in_pricing_attribute53(i),
        in_pricing_attribute54(i),
        in_pricing_attribute55(i),
        in_pricing_attribute56(i),
        in_pricing_attribute57(i),
        in_pricing_attribute58(i),
        in_pricing_attribute59(i),
        in_pricing_attribute60(i),
        in_pricing_attribute61(i),
        in_pricing_attribute62(i),
        in_pricing_attribute63(i),
        in_pricing_attribute64(i),
        in_pricing_attribute65(i),
        in_pricing_attribute66(i),
        in_pricing_attribute67(i),
        in_pricing_attribute68(i),
        in_pricing_attribute69(i),
        in_pricing_attribute70(i),
        in_pricing_attribute71(i),
        in_pricing_attribute72(i),
        in_pricing_attribute73(i),
        in_pricing_attribute74(i),
        in_pricing_attribute75(i),
        in_pricing_attribute76(i),
        in_pricing_attribute77(i),
        in_pricing_attribute78(i),
        in_pricing_attribute79(i),
        in_pricing_attribute80(i),
        in_pricing_attribute81(i),
        in_pricing_attribute82(i),
        in_pricing_attribute83(i),
        in_pricing_attribute84(i),
        in_pricing_attribute85(i),
        in_pricing_attribute86(i),
        in_pricing_attribute87(i),
        in_pricing_attribute88(i),
        in_pricing_attribute89(i),
        in_pricing_attribute90(i),
        in_pricing_attribute91(i),
        in_pricing_attribute92(i),
        in_pricing_attribute93(i),
        in_pricing_attribute94(i),
        in_pricing_attribute95(i),
        in_pricing_attribute96(i),
        in_pricing_attribute97(i),
        in_pricing_attribute98(i),
        in_pricing_attribute99(i),
        in_pricing_attribute100(i),
        in_qualifier_context(i),
        in_qualifier_attribute1(i),
        in_qualifier_attribute2(i),
        in_created_by(i),
        in_qualifier_attribute3(i),
        in_creation_date(i),
        in_qualifier_attribute4(i),
        in_qualifier_attribute5(i),
        in_last_updated_by(i),
        in_qualifier_attribute6(i),
        in_last_update_date(i),
        in_qualifier_attribute7(i),
        in_qualifier_attribute8(i),
        in_qualifier_attribute9(i),
        in_qualifier_attribute10(i),
        in_qualifier_attribute11(i),
        in_qualifier_attribute12(i),
        in_qualifier_attribute13(i),
        in_qualifier_attribute14(i),
        in_qualifier_attribute15(i),
        in_qualifier_attribute16(i),
        in_qualifier_attribute17(i),
        in_qualifier_attribute18(i),
        in_qualifier_attribute19(i),
        in_qualifier_attribute20(i),
        in_qualifier_attribute21(i),
        in_qualifier_attribute22(i),
        in_qualifier_attribute23(i),
        in_qualifier_attribute24(i),
        in_qualifier_attribute25(i),
        in_qualifier_attribute26(i),
        in_qualifier_attribute27(i),
        in_qualifier_attribute28(i),
        in_qualifier_attribute29(i),
        in_qualifier_attribute30(i),
        in_qualifier_attribute31(i),
        in_qualifier_attribute32(i),
        in_qualifier_attribute33(i),
        in_qualifier_attribute34(i),
        in_qualifier_attribute35(i),
        in_qualifier_attribute36(i),
        in_qualifier_attribute37(i),
        in_qualifier_attribute38(i),
        in_qualifier_attribute39(i),
        in_qualifier_attribute40(i),
        in_qualifier_attribute41(i),
        in_qualifier_attribute42(i),
        in_qualifier_attribute43(i),
        in_qualifier_attribute44(i),
        in_qualifier_attribute45(i),
        in_qualifier_attribute46(i),
        in_qualifier_attribute47(i),
        in_qualifier_attribute48(i),
        in_qualifier_attribute49(i),
        in_qualifier_attribute50(i),
        in_qualifier_attribute51(i),
        in_qualifier_attribute52(i),
        in_qualifier_attribute53(i),
        in_qualifier_attribute54(i),
        in_qualifier_attribute55(i),
        in_qualifier_attribute56(i),
        in_qualifier_attribute57(i),
        in_qualifier_attribute58(i),
        in_qualifier_attribute59(i),
        in_qualifier_attribute60(i),
        in_qualifier_attribute61(i),
        in_qualifier_attribute62(i),
        in_qualifier_attribute63(i),
        in_qualifier_attribute64(i),
        in_qualifier_attribute65(i),
        in_qualifier_attribute66(i),
        in_qualifier_attribute67(i),
        in_qualifier_attribute68(i),
        in_qualifier_attribute69(i),
        in_qualifier_attribute70(i),
        in_qualifier_attribute71(i),
        in_qualifier_attribute72(i),
        in_qualifier_attribute73(i),
        in_qualifier_attribute74(i),
        in_qualifier_attribute75(i),
        in_qualifier_attribute76(i),
        in_qualifier_attribute77(i),
        in_qualifier_attribute78(i),
        in_qualifier_attribute79(i),
        in_qualifier_attribute80(i),
        in_qualifier_attribute81(i),
        in_qualifier_attribute82(i),
        in_qualifier_attribute83(i),
        in_qualifier_attribute84(i),
        in_qualifier_attribute85(i),
        in_qualifier_attribute86(i),
        in_qualifier_attribute87(i),
        in_qualifier_attribute88(i),
        in_qualifier_attribute89(i),
        in_qualifier_attribute90(i),
        in_qualifier_attribute91(i),
        in_qualifier_attribute92(i),
        in_qualifier_attribute93(i),
        in_qualifier_attribute94(i),
        in_qualifier_attribute95(i),
        in_qualifier_attribute96(i),
        in_qualifier_attribute97(i),
        in_qualifier_attribute98(i),
        in_qualifier_attribute99(i),
        in_qualifier_attribute100(i),
        in_last_update_login(i),
        in_program_application_id(i),
     in_program_id(i),
     in_program_update_date(i),
      in_request_id(i),
      in_object_version_number(i)
 );

EXCEPTION
  WHEN OTHERS THEN
  -- store SQL error message on message stack
     OKC_API.SET_MESSAGE(
        p_app_name        => G_APP_NAME,
        p_msg_name        => G_UNEXPECTED_ERROR,
        p_token1          => G_SQLCODE_TOKEN,
        p_token1_value    => SQLCODE,
        p_token2          => G_SQLERRM_TOKEN,
        p_token2_value    => SQLERRM);
     -- notify caller of an error as UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    RAISE;
END INSERT_ROW_UPG;

END OKC_SPLIT2_PAV_PVT;

/
