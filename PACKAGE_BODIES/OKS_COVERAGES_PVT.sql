--------------------------------------------------------
--  DDL for Package Body OKS_COVERAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_COVERAGES_PVT" AS
/* $Header: OKSRMCVB.pls 120.19.12010000.2 2008/11/17 09:24:49 cgopinee ship $*/

   ---------------------------------------------------------------------------
  -- PROCEDURE Validate_svc_line_id
  ---------------------------------------------------------------------------

  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


  PROCEDURE Validate_svc_cle_id(
    p_ac_rec            IN ac_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_ac_rec.Svc_Cle_id = OKC_API.G_MISS_NUM OR
       p_ac_rec.Svc_Cle_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Svc_Cle_id');

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
  END validate_svc_Cle_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Line_id
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Line_id(
    p_line_id          IN NUMBER,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_Count   NUMBER;
    CURSOR Cur_Line(P_Line_Id IN NUMBER) IS
    SELECT COUNT(*) FROM OKC_K_LINES_V
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
  PROCEDURE Validate_tmp_cle_id(
    p_ac_rec          IN ac_rec_type,
    x_template_yn       OUT NOCOPY VARCHAR2,
    x_return_status 	OUT NOCOPY VARCHAR2) IS

    CURSOR check_cov_tmpl(p_cov_id IN Number) IS
    SELECT count(*) FROM OKC_K_LINES_B
    WHERE id = p_cov_id
    AND lse_id in (2,15,20)
    and dnz_chr_id < 0;

    l_Count Number :=0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_ac_rec.tmp_cle_id = OKC_API.G_MISS_NUM OR
       p_ac_rec.tmp_cle_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Tmp_cle_Id');

      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    OPEN check_cov_tmpl(p_ac_rec.tmp_cle_id);
    FETCH check_cov_tmpl INTO l_Count;
    CLOSE check_cov_tmpl;
    IF l_Count > 0
    THEN
    x_template_yn := 'Y';
    Else
    x_template_yn := 'N';
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
  END Validate_tmp_cle_id;

PROCEDURE Init_Clev(P_Clev_Tbl_In_Out IN OUT NOCOPY OKC_Contract_Pub.Clev_Tbl_type) IS

BEGIN
IF NOT P_Clev_Tbl_In_Out.COUNT=0
THEN
FOR v_Index IN P_Clev_Tbl_in_Out.FIRST .. P_Clev_Tbl_in_Out.LAST
LOOP
p_clev_tbl_IN_out(v_Index).line_number	:=NULL;
p_clev_tbl_IN_out(v_Index).chr_id		:=NULL;
p_clev_tbl_IN_out(v_Index).cle_id       	:=NULL;
p_clev_tbl_IN_out(v_Index).lse_id       	:=NULL;
p_clev_tbl_IN_out(v_Index).display_sequence	:=NULL;
p_clev_tbl_IN_out(v_Index).sts_code		:=NULL;
p_clev_tbl_IN_out(v_Index).trn_code		:=NULL;
p_clev_tbl_IN_out(v_Index).dnz_chr_id		:=NULL;
p_clev_tbl_IN_out(v_Index).exception_yn	:=NULL;
p_clev_tbl_IN_out(v_Index).object_version_number:=NULL;
p_clev_tbl_IN_out(v_Index).created_by		:=NULL;
p_clev_tbl_IN_out(v_Index).creation_date	:=NULL;
p_clev_tbl_IN_out(v_Index).last_updated_by	:=NULL;
p_clev_tbl_IN_out(v_Index).last_update_date	:=NULL;
p_clev_tbl_IN_out(v_Index).hidden_ind		:=NULL;
p_clev_tbl_IN_out(v_Index).price_negotiated	:=NULL;
p_clev_tbl_IN_out(v_Index).price_level_ind	:=NULL;
p_clev_tbl_IN_out(v_Index).invoice_line_level_ind:=NULL;
p_clev_tbl_IN_out(v_Index).dpas_rating	:=NULL;
p_clev_tbl_IN_out(v_Index).template_used	:='Y';
p_clev_tbl_IN_out(v_Index).price_type		:=NULL;
p_clev_tbl_IN_out(v_Index).currency_code	:=NULL;
p_clev_tbl_IN_out(v_Index).last_update_login	:=NULL;
p_clev_tbl_IN_out(v_Index).date_terminated	:=NULL;
p_clev_tbl_IN_out(v_Index).start_date		:=NULL;
p_clev_tbl_IN_out(v_Index).end_date 		:=NULL;
p_clev_tbl_IN_out(v_Index).attribute_category	:=NULL;
p_clev_tbl_IN_out(v_Index).attribute1		:=NULL;
p_clev_tbl_IN_out(v_Index).attribute2		:=NULL;
p_clev_tbl_IN_out(v_Index).attribute3		:=NULL;
p_clev_tbl_IN_out(v_Index).attribute4		:=NULL;
p_clev_tbl_IN_out(v_Index).attribute5		:=NULL;
p_clev_tbl_IN_out(v_Index).attribute6		:=NULL;
p_clev_tbl_IN_out(v_Index).attribute7		:=NULL;
p_clev_tbl_IN_out(v_Index).attribute8		:=NULL;
p_clev_tbl_IN_out(v_Index).attribute9		:=NULL;
p_clev_tbl_IN_out(v_Index).attribute10	:=NULL;
p_clev_tbl_IN_out(v_Index).attribute11	:=NULL;
p_clev_tbl_IN_out(v_Index).attribute12	:=NULL;
p_clev_tbl_IN_out(v_Index).attribute13	:=NULL;
p_clev_tbl_IN_out(v_Index).attribute14	:=NULL;
p_clev_tbl_IN_out(v_Index).attribute15	:=NULL;
END LOOP;
END IF;
END INIT_CLEV;

PROCEDURE Init_RGPV(P_RGPV_tbl_in_Out IN OUT NOCOPY okc_Rule_Pub.Rgpv_tbl_type)
IS

BEGIN
IF NOT P_Rgpv_Tbl_In_Out.COUNT=0
THEN
FOR v_Index IN P_Rgpv_Tbl_in_Out.FIRST .. P_Rgpv_Tbl_in_Out.LAST
LOOP
p_rgpv_tbl_IN_out(v_Index).id    :=NULL;
p_rgpv_tbl_IN_out(v_Index).rgd_code:=NULL;
p_rgpv_tbl_IN_out(v_Index).chr_id  :=NULL;
p_rgpv_tbl_IN_out(v_Index).cle_id  :=NULL;
p_rgpv_tbl_IN_out(v_Index).dnz_chr_id :=NULL;
p_rgpv_tbl_IN_out(v_Index).parent_rgp_id  :=NULL;
p_rgpv_tbl_IN_out(v_Index).object_version_number:=NULL;
p_rgpv_tbl_IN_out(v_Index).created_by           :=NULL;
p_rgpv_tbl_IN_out(v_Index).creation_date        :=NULL;
p_rgpv_tbl_IN_out(v_Index).last_updated_by      :=NULL;
p_rgpv_tbl_IN_out(v_Index).last_update_date     :=NULL;
p_rgpv_tbl_IN_out(v_Index).last_update_login    :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute_category   :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute1           :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute2           :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute3           :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute4           :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute5           :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute6           :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute7           :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute8           :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute9           :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute10          :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute11          :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute12          :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute13          :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute14          :=NULL;
p_rgpv_tbl_IN_out(v_Index).attribute15          :=NULL;
p_rgpv_tbl_IN_out(v_Index).rgp_type             :=NULL;
END LOOP;
END IF;
END INIT_RGPV;
PROCEDURE Init_RGPV(P_RGPV_rec_in_Out IN OUT NOCOPY okc_Rule_Pub.Rgpv_rec_type)
IS

BEGIN
p_rgpv_rec_IN_out.id    :=NULL;
p_rgpv_rec_IN_out.rgd_code:=NULL;
p_rgpv_rec_IN_out.chr_id  :=NULL;
p_rgpv_rec_IN_out.cle_id  :=NULL;
p_rgpv_rec_IN_out.dnz_chr_id :=NULL;
p_rgpv_rec_IN_out.parent_rgp_id  :=NULL;
p_rgpv_rec_IN_out.object_version_number:=NULL;
p_rgpv_rec_IN_out.created_by           :=NULL;
p_rgpv_rec_IN_out.creation_date        :=NULL;
p_rgpv_rec_IN_out.last_updated_by      :=NULL;
p_rgpv_rec_IN_out.last_update_date     :=NULL;
p_rgpv_rec_IN_out.last_update_login    :=NULL;
p_rgpv_rec_IN_out.attribute_category   :=NULL;
p_rgpv_rec_IN_out.attribute1           :=NULL;
p_rgpv_rec_IN_out.attribute2           :=NULL;
p_rgpv_rec_IN_out.attribute3           :=NULL;
p_rgpv_rec_IN_out.attribute4           :=NULL;
p_rgpv_rec_IN_out.attribute5           :=NULL;
p_rgpv_rec_IN_out.attribute6           :=NULL;
p_rgpv_rec_IN_out.attribute7           :=NULL;
p_rgpv_rec_IN_out.attribute8           :=NULL;
p_rgpv_rec_IN_out.attribute9           :=NULL;
p_rgpv_rec_IN_out.attribute10          :=NULL;
p_rgpv_rec_IN_out.attribute11          :=NULL;
p_rgpv_rec_IN_out.attribute12          :=NULL;
p_rgpv_rec_IN_out.attribute13          :=NULL;
p_rgpv_rec_IN_out.attribute14          :=NULL;
p_rgpv_rec_IN_out.attribute15          :=NULL;
p_rgpv_rec_IN_out.rgp_type             :=NULL;
END INIT_RGPV;



PROCEDURE Init_RULV(P_RULV_tbl_in_Out IN OUT NOCOPY okc_Rule_Pub.Rulv_tbl_type)
IS

BEGIN
IF NOT P_RULV_tbl_in_Out.COUNT=0
THEN
FOR v_Index IN P_RULV_tbl_in_Out.FIRST .. P_RULV_tbl_in_Out.LAST
LOOP
p_rulv_tbl_IN_out(v_Index).id:=NULL;
p_rulv_tbl_IN_out(v_Index).rgp_id :=NULL;
p_rulv_tbl_IN_out(v_Index).object1_id1 :=NULL;
p_rulv_tbl_IN_out(v_Index).object2_id1 :=NULL;
p_rulv_tbl_IN_out(v_Index).object3_id1 :=NULL;
p_rulv_tbl_IN_out(v_Index).object1_id2 :=NULL;
p_rulv_tbl_IN_out(v_Index).object2_id2 :=NULL;
p_rulv_tbl_IN_out(v_Index).object3_id2 :=NULL;
p_rulv_tbl_IN_out(v_Index).jtot_object1_Code:=NULL;
p_rulv_tbl_IN_out(v_Index).jtot_object2_Code:=NULL;
p_rulv_tbl_IN_out(v_Index).jtot_object3_Code:=NULL;
p_rulv_tbl_IN_out(v_Index).dnz_chr_id:=NULL;
p_rulv_tbl_IN_out(v_Index).std_template_yn:=NULL;
p_rulv_tbl_IN_out(v_Index).warn_yn:=NULL;
p_rulv_tbl_IN_out(v_Index).priority:=NULL;
p_rulv_tbl_IN_out(v_Index).object_version_number:=NULL;
p_rulv_tbl_IN_out(v_Index).created_by:=NULL;
p_rulv_tbl_IN_out(v_Index).creation_date:=NULL;
p_rulv_tbl_IN_out(v_Index).last_updated_by:=NULL;
p_rulv_tbl_IN_out(v_Index).last_update_date:=NULL;
p_rulv_tbl_IN_out(v_Index).last_update_login:=NULL;
p_rulv_tbl_IN_out(v_Index).attribute_category:=NULL;
p_rulv_tbl_IN_out(v_Index).attribute1    :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute2    :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute3    :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute4    :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute5    :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute6    :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute7    :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute8    :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute9    :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute10   :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute11   :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute12   :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute13   :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute14   :=NULL;
p_rulv_tbl_IN_out(v_Index).attribute15   :=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information_category:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information1:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information2:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information3:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information4:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information5:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information6:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information7:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information8:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information9:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information10:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information11:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information12:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information13:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information14:=NULL;
p_rulv_tbl_IN_out(v_Index).Rule_Information15:=NULL;
END LOOP;
END IF;
END INIT_RULV;



PROCEDURE Init_CTCV(P_CTCV_tbl_In_Out IN OUT NOCOPY okc_contract_party_pub.Ctcv_tbl_type) IS
BEGIN
IF P_CTCV_tbl_In_Out.COUNT > 0 THEN
    FOR v_Index IN  P_CTCV_tbl_In_Out.FIRST .. P_CTCV_tbl_In_Out.LAST LOOP
		P_CTCV_tbl_In_Out(v_Index).ID  := NULL;
		P_CTCV_tbl_In_Out(v_Index).OBJECT_VERSION_NUMBER := NULL;
		P_CTCV_tbl_In_Out(v_Index).CPL_ID  := NULL;
		P_CTCV_tbl_In_Out(v_Index).CRO_CODE  := NULL;
		P_CTCV_tbl_In_Out(v_Index).DNZ_CHR_ID  := NULL;
		P_CTCV_tbl_In_Out(v_Index).CONTACT_SEQUENCE  := NULL;
		P_CTCV_tbl_In_Out(v_Index).OBJECT1_ID1 := NULL;
		P_CTCV_tbl_In_Out(v_Index).OBJECT1_ID2 := NULL;
		P_CTCV_tbl_In_Out(v_Index).JTOT_OBJECT1_CODE := NULL;
		--P_CTCV_tbl_In_Out(v_Index).ROLE  := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE_CATEGORY  := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE1  := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE2  := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE3  := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE4  := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE5  := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE6  := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE7  := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE8  := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE9  := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE10 := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE11 := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE12 := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE13 := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE14 := NULL;
		P_CTCV_tbl_In_Out(v_Index).ATTRIBUTE15 := NULL;
		P_CTCV_tbl_In_Out(v_Index).CREATED_BY  := NULL;
		P_CTCV_tbl_In_Out(v_Index).CREATION_DATE := NULL;
		P_CTCV_tbl_In_Out(v_Index).LAST_UPDATED_BY := NULL;
		P_CTCV_tbl_In_Out(v_Index).LAST_UPDATE_DATE  := NULL;
		P_CTCV_tbl_In_Out(v_Index).LAST_UPDATE_LOGIN := NULL;
		P_CTCV_tbl_In_Out(v_Index).START_DATE  := NULL;
		P_CTCV_tbl_In_Out(v_Index).END_DATE  := NULL;
		P_CTCV_tbl_In_Out(v_Index).PRIMARY_YN  := NULL;
		P_CTCV_tbl_In_Out(v_Index).RESOURCE_CLASS  := NULL;
		P_CTCV_tbl_In_Out(v_Index).SALES_GROUP_ID := NULL;

    END LOOP;
END IF;
END;

PROCEDURE Init_CIMV(P_CIMV_tbl_In_Out IN OUT NOCOPY okc_contract_item_pub.Cimv_tbl_type) IS

BEGIN
IF P_CIMV_tbl_In_Out.COUNT > 0 THEN
    FOR v_Index IN P_CIMV_tbl_In_Out.FIRST .. P_CIMV_tbl_In_Out.LAST LOOP

		 P_CIMV_tbl_In_Out(v_Index).ID  := NULL;
		 P_CIMV_tbl_In_Out(v_Index).CLE_ID  := NULL;
		 P_CIMV_tbl_In_Out(v_Index).CHR_ID  := NULL;
		 P_CIMV_tbl_In_Out(v_Index).CLE_ID_FOR  := NULL;
		 P_CIMV_tbl_In_Out(v_Index).DNZ_CHR_ID  := NULL;
		 P_CIMV_tbl_In_Out(v_Index).OBJECT1_ID1 := NULL;
		 P_CIMV_tbl_In_Out(v_Index).OBJECT1_ID2 := NULL;
		 P_CIMV_tbl_In_Out(v_Index).JTOT_OBJECT1_CODE := NULL;
		 P_CIMV_tbl_In_Out(v_Index).UOM_CODE  := NULL;
		 P_CIMV_tbl_In_Out(v_Index).EXCEPTION_YN  := NULL;
		 P_CIMV_tbl_In_Out(v_Index).NUMBER_OF_ITEMS := NULL;
		 P_CIMV_tbl_In_Out(v_Index).PRICED_ITEM_YN  := NULL;
		 P_CIMV_tbl_In_Out(v_Index).OBJECT_VERSION_NUMBER := NULL;
		 P_CIMV_tbl_In_Out(v_Index).CREATED_BY  := NULL;
		 P_CIMV_tbl_In_Out(v_Index).CREATION_DATE := NULL;
		 P_CIMV_tbl_In_Out(v_Index).LAST_UPDATED_BY := NULL;
		 P_CIMV_tbl_In_Out(v_Index).LAST_UPDATE_DATE  := NULL;
		 P_CIMV_tbl_In_Out(v_Index).LAST_UPDATE_LOGIN := NULL;
		 --P_CIMV_tbl_In_Out(v_Index).SECURITY_GROUP_ID := NULL;
		 P_CIMV_tbl_In_Out(v_Index).UPG_ORIG_SYSTEM_REF := NULL;
		 P_CIMV_tbl_In_Out(v_Index).UPG_ORIG_SYSTEM_REF_ID  := NULL;
		 P_CIMV_tbl_In_Out(v_Index).PROGRAM_APPLICATION_ID  := NULL;
		 P_CIMV_tbl_In_Out(v_Index).PROGRAM_ID  := NULL;
		 P_CIMV_tbl_In_Out(v_Index).PROGRAM_UPDATE_DATE := NULL;
		 P_CIMV_tbl_In_Out(v_Index).REQUEST_ID  := NULL;

    END LOOP;
END IF;
END;



-- ******************************************************************************************

PROCEDURE CREATE_ACTUAL_COVERAGE(
    p_api_version     IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ac_rec_in             IN  ac_rec_type,
    p_restricted_update     IN VARCHAR2 DEFAULT 'F',
    x_Actual_coverage_id    OUT NOCOPY NUMBER) IS

  CURSOR Cur_LineDet (P_Line_Id IN NUMBER) IS
  SELECT SFWT_FLAG,
         CHR_ID,
         START_DATE,
         END_DATE,
         LSE_ID,
         LINE_NUMBER,
         DISPLAY_SEQUENCE,
         NAME,
         ITEM_DESCRIPTION,
         EXCEPTION_YN,
         PRICE_LIST_ID,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15
  FROM OKC_K_LINES_v
  WHERE ID= P_Line_Id;
  --------------------------
  CURSOR Cur_LineDet3 (P_Line_Id IN NUMBER) IS
  SELECT SFWT_FLAG,
         CHR_ID,
         START_DATE,
         END_DATE,
         LSE_ID,
         LINE_NUMBER,
         DISPLAY_SEQUENCE,
         NAME,
         ITEM_DESCRIPTION,
         EXCEPTION_YN,
         PRICE_LIST_ID,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15
   FROM OKC_K_LINES_v
  WHERE ID= P_Line_Id;
  --------------------------
  LineDet_Rec3 Cur_LineDet3%ROWTYPE;
  LineDet_Rec Cur_LineDet%ROWTYPE;
  LineDet_Rec1 Cur_LineDet%ROWTYPE;
  LineDet_Rec2 Cur_LineDet%ROWTYPE;


  CURSOR Cur_childline(P_cle_Id IN NUMBER,
                     P_lse_Id IN NUMBER) IS
  SELECT ID
  FROM OKC_K_LINES_B
  WHERE  cle_Id=P_cle_Id
  AND    lse_Id=P_lse_Id;
  -------------------------------------

  CURSOR Cur_childline_br(P_cle_Id IN NUMBER,
                     P_lse_Id IN NUMBER) IS
  SELECT ID,
         EXCEPTION_YN,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15
  FROM OKC_K_LINES_B
  WHERE  cle_Id=P_cle_Id
  AND    lse_Id=P_lse_Id;
  ---------------------------------------

  CURSOR Cur_childline_bt(P_cle_Id IN NUMBER,
                     P_lse_Id IN NUMBER) IS
  SELECT ID
  FROM OKC_K_LINES_B
  WHERE  cle_Id=P_cle_Id
  AND    lse_Id=P_lse_Id;
  ----------------------------------------

  CURSOR Cur_childline1(P_cle_Id IN NUMBER,
                     P_lse_Id IN NUMBER) IS
  SELECT ID
  FROM OKC_K_LINES_B
  WHERE  cle_Id=P_cle_Id
  AND    lse_Id=P_lse_Id;
  -----------------------------------------


  CURSOR Cur_PTRLDet(P_Cle_Id IN NUMBER,
                   P_role_Code IN varchar2) IS
  SELECT
    	pr.ID,
    	pr.SFWT_FLAG,
	pr.OBJECT1_ID1,
	pr.OBJECT1_ID2,
	pr.JTOT_OBJECT1_CODE,
	pr.CODE,
	pr.FACILITY,
	pr.MINORITY_GROUP_LOOKUP_CODE,
	pr.SMALL_BUSINESS_FLAG,
	pr.WOMEN_OWNED_FLAG
  FROM  OKC_K_Party_Roles_V pr,
	   OKC_K_LINES_B lv
  WHERE pr.cle_ID=p_cle_Id
  AND   pr.Rle_Code=P_Role_Code
  AND   pr.cle_id = lv.id
  AND   pr.dnz_chr_id = lv.dnz_chr_id ;
  PtrlDet_Rec     Cur_PTRLDet%ROWTYPE;
  ------------------------------------------

  CURSOR Cur_contactDet(P_cpl_id IN NUMBER) IS
  SELECT
	CRO_CODE,
    	CONTACT_SEQUENCE,
	OBJECT1_ID1,
	OBJECT1_ID2,
	JTOT_OBJECT1_CODE,
    resource_class
  FROM OKC_CONTACTS_V
  WHERE cpl_id=P_cpl_Id;
  --------------------------------------------

  CURSOR CUR_ItemDet(P_Id IN NUMBER) IS
  SELECT object1_id1,
	 object1_id2,
	 JTOT_OBJECT1_CODE,
	 number_of_items,
	 exception_yn
  FROM OKC_K_ITEMS_V
  WHERE cle_Id=P_Id;

  --------------------------------------------------

  CURSOR CUR_GET_BILLRATE_SCHEDULES(p_cle_id IN NUMBER) IS
  SELECT ID,
         CLE_ID,
         BT_CLE_ID,
         DNZ_CHR_ID,
         START_HOUR,
         START_MINUTE,
         END_HOUR,
         END_MINUTE,
         MONDAY_FLAG,
         TUESDAY_FLAG,
         WEDNESDAY_FLAG,
         THURSDAY_FLAG,
         FRIDAY_FLAG,
         SATURDAY_FLAG,
         SUNDAY_FLAG,
         OBJECT1_ID1,
         OBJECT1_ID2,
         JTOT_OBJECT1_CODE,
         BILL_RATE_CODE,
         FLAT_RATE,
         UOM,
         HOLIDAY_YN,
         PERCENT_OVER_LIST_PRICE,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
         REQUEST_ID,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         SECURITY_GROUP_ID,
         object_version_number --Added
  FROM OKS_BILLRATE_SCHEDULES
  WHERE CLE_ID = p_cle_id ;

  -------------------------------------------------

   CURSOR CUR_GET_OKS_LINE(p_cle_id IN NUMBER) IS
   SELECT
     id
    ,cle_id
    ,dnz_chr_id
    ,discount_list
    ,coverage_type
    ,exception_cov_id
    ,limit_uom_quantified
    ,discount_amount
    ,discount_percent
    ,offset_duration
    ,offset_period
    ,incident_severity_id
    ,pdf_id
    ,work_thru_yn
    ,react_active_yn
    ,transfer_option
    ,prod_upgrade_yn
    ,inheritance_type
    ,pm_program_id
    ,pm_conf_req_yn
    ,pm_sch_exists_yn
    ,allow_bt_discount
    ,apply_default_timezone
    ,sync_date_install
    ,sfwt_flag
    ,react_time_name
    ,object_version_number
    ,security_group_id
    ,request_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
  FROM OKS_K_LINES_V
  WHERE cle_id = p_cle_id;

  -------------------------------------------------

  -- FOR NOTES BARORA 07/31/03

  CURSOR CUR_GET_NOTES(p_source_object_id IN NUMBER) IS
  SELECT jtf_note_id,
         parent_note_id,
         source_object_code,
         source_number,
         notes,  --
         notes_detail,
         note_status,
         source_object_meaning,
         note_type,
         note_type_meaning,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         note_status_meaning,
         decoded_source_code,
         decoded_source_meaning,
         context
  FROM JTF_NOTES_VL
  WHERE source_object_id = p_source_object_id
  AND   source_object_code = 'OKS_COVTMPL_NOTE'
  AND   note_status <> 'P';
-------------------------------------------------------------------------------
  -- get the pm_program_id associated with the service line added by jvorugan for R12 bug:4610449
   CURSOR CUR_GET_PROGRAM_ID(p_contract_line_id IN NUMBER) IS
    SELECT PM_PROGRAM_ID
    FROM OKS_K_LINES_B
    WHERE cle_id =p_contract_line_id;

-------------------------------------------------------------------------------
CURSOR Get_cov_timezones(p_cle_id IN Number) IS
SELECT
     ID
    ,CLE_ID
    ,DEFAULT_YN
    ,TIMEZONE_ID
FROM oks_coverage_timezones
WHERE cle_id = p_cle_id;
-------------------------------------------------------------------------------
CURSOR Get_cov_times(p_cov_tz_id IN Number) IS
SELECT
ID
,COV_TZE_LINE_ID
,DNZ_CHR_ID
,START_HOUR
,START_MINUTE
,END_HOUR
,END_MINUTE
,MONDAY_YN
,TUESDAY_YN
,WEDNESDAY_YN
,THURSDAY_YN
,FRIDAY_YN
,SATURDAY_YN
,SUNDAY_YN
FROM oks_coverage_times
WHERE  COV_TZE_LINE_ID = p_cov_tz_id;
-------------------------------------------------------------------------------


CURSOR CUR_GET_ACTION_TYPES(p_cle_id IN NUMBER) IS
SELECT ID,
      ACTION_TYPE_CODE
FROM OKS_ACTION_TIME_TYPES
WHERE cle_id = p_cle_id ;


CURSOR CUR_GET_ACTION_TIMES(p_cov_act_type_id IN NUMBER) IS
SELECT ID,
       UOM_CODE,
       SUN_DURATION,
       MON_DURATION,
       TUE_DURATION,
       WED_DURATION,
       THU_DURATION,
       FRI_DURATION,
       SAT_DURATION
FROM OKS_ACTION_TIMES
WHERE cov_action_type_id = p_cov_act_type_id ;
-------------------------------------------------------------------------------
-- Fix for Bug:4703431. Modified by jvorugan
CURSOR CUR_GET_ORG_ID(p_contract_id IN NUMBER) is
SELECT ORG_ID
FROM okc_k_headers_all_b
WHERE id=p_contract_id;


  l_jtf_note_id             NUMBER;
  l_Notes_detail            VARCHAR2(32767);
  l_pm_program_id           NUMBER;
  l_object_id               NUMBER;


  g_start_date 	DATE;
  g_End_date	DATE;
  l_clev_rec            okc_contract_pub.clev_rec_type;
  l_clev_tbl_in         okc_contract_pub.clev_tbl_type;
  l_clev_tbl_out        okc_contract_pub.clev_tbl_type;
  l_lsl_id          NUMBER;
  c_cle_id		    NUMBER;
  txg_cle_id		NUMBER;
  crt_cle_id		NUMBER;
  bt_cle_id		    NUMBER;
  br_cle_id		    NUMBER;
  tmp_txg_cle_id	NUMBER;
  tmp_crt_cle_id	NUMBER;
  tmp_bt_cle_id		NUMBER;
  tmp_br_cle_id		NUMBER;
  g_Chr_Id          NUMBER;
  l_ctiv_tbl_in		okc_rule_pub.ctiv_tbl_type;
  l_ctiv_tbl_out	okc_rule_pub.ctiv_tbl_type;
  l_contact_Id          Number;
  l_bill_rate_tbl_in   OKS_BRS_PVT.OKSBILLRATESCHEDULESVTBLTYPE;
  x_bill_rate_tbl_out  OKS_BRS_PVT.OKSBILLRATESCHEDULESVTBLTYPE;
  --
  l_api_version		    CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	    CONSTANT	VARCHAR2(1):= 'F';
  l_return_status	    VARCHAR2(1);
  l_msg_count		    NUMBER;
  l_msg_data		    VARCHAR2(2000):=null;
  l_msg_index_out       NUMBER;
  l_Service_line_Id	    NUMBER;
  l_Template_Line_Id    NUMBER;
  l_Actual_coverage_id  NUMBER;
  l_api_name            CONSTANT VARCHAR2(30) := 'Create_Actual_Coverage';
   --
  --l_catv_rec_in		okc_k_article_pub.catv_rec_type;
  --l_catv_rec_out	okc_k_article_pub.catv_rec_type;
  --l_article_id        NUMBER;
  --v_clob              CLOB;
  --v_Text              varchar2(2000);
  --v_Length            BINARY_INTEGER;
  --

  --
  l_cimv_tbl_in         okc_Contract_Item_Pub.cimv_tbl_TYPE;
  l_cimv_tbl_out        okc_Contract_Item_Pub.cimv_tbl_TYPE;
  --
  l_ctcv_tbl_in		okc_contract_party_pub.ctcv_tbl_type;
  l_ctcv_tbl_out	okc_contract_party_pub.ctcv_tbl_type;
  l_cplv_tbl_in		okc_contract_party_pub.cplv_tbl_type;
  l_cplv_tbl_out	okc_contract_party_pub.cplv_tbl_type;
  l_cpl_id		    NUMBER;
  tmp_cpl_id        NUMBER;
  l_Parent_lse_Id   NUMBER;
  tmp_lse_id        NUMBER;
  l_bt_lse_Id       NUMBER;
  l_br_lse_Id       NUMBER;
  l_rle_code        VARCHAR2(30);


      l_klnv_tbl_in            oks_kln_pvt.klnv_tbl_type;
      l_klnv_tbl_out           oks_kln_pvt.klnv_tbl_type;

      l_covtz_tbl_in            oks_ctz_pvt.OksCoverageTimezonesVTblType;
      l_covtz_tbl_out           oks_ctz_pvt.OksCoverageTimezonesVTblType;

      l_covtz_rec_in            oks_ctz_pvt.OksCoverageTimezonesVRecType;
      l_covtz_rec_out           oks_ctz_pvt.OksCoverageTimezonesVRecType;

      l_covtim_tbl_in           oks_cvt_pvt.oks_coverage_times_v_tbl_type;
      l_covtim_tbl_out          oks_cvt_pvt.oks_coverage_times_v_tbl_type;

      l_act_type_tbl_in         OKS_ACT_PVT.OksActionTimeTypesVTblType;
      l_act_type_tbl_out        OKS_ACT_PVT.OksActionTimeTypesVTblType;

      l_act_time_tbl_in        OKS_ACM_PVT.oks_action_times_v_tbl_type;
      l_act_time_tbl_out       OKS_ACM_PVT.oks_action_times_v_tbl_type;

      covtim_ctr   NUMBER := 0;
      acttim_ctr   NUMBER := 0;
      l_cov_templ_yn VARCHAR2(1) := 'Y';

      l_rt_cle_id            NUMBER := 0;
      l_act_type_line_id     NUMBER := 0;
      l_cov_act_type_line_id NUMBER := 0;
      act_time_ctr           NUMBER := 0;

     l_Exists		    Number;
     l_start_date		Date;
     l_Currency        VARCHAR2(15) := NULL;
     l_type_msmtch     CONSTANT varchar2(200) := 'OKS_COV_TYPE_MSMTCH';
 -----------------------------------
 CURSOR Check_Cur(P_Line_Id IN NUMBER) IS
 SELECT COUNT(1) FROM OKC_K_LINES_B
 WHERE  cle_Id=P_Line_Id
 AND    lse_Id IN (2,15,20);

 ------------------------------------
 FUNCTION GetCurrency (P_ID IN NUMBER)
 RETURN Varchar2
 IS
   CURSOR Currency_Cur IS
   SELECT Currency_Code FROM OKC_K_LINES_B
   WHERE ID=P_Id;

 BEGIN
	OPEN Currency_Cur;
	FETCH Currency_Cur INTO l_Currency;
	CLOSE Currency_Cur;
	RETURN l_Currency;
	END GetCurrency;
	FUNCTION GetStatus (P_ID IN NUMBER)
	RETURN Varchar2 IS
		l_sts   OKC_K_LINES_B.sts_Code%Type:= NULL;
	   CURSOR sts_Cur IS
	   SELECT sts_Code FROM OKC_K_LINES_B
	   WHERE ID=P_Id;
	BEGIN
	OPEN sts_Cur;
	FETCH sts_Cur INTO l_sts;
	CLOSE sts_Cur;
	RETURN l_sts;
END GetStatus;
-----------------------------------------
BEGIN

IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.Set_Indentation('Create_Actual_Coverage');
		okc_debug.log('Entered Create_Actual_Coverage', 2);
END IF;

  l_Service_Line_Id:=P_Ac_Rec_In.SVc_Cle_Id;
  l_Template_Line_Id:=P_Ac_Rec_In.Tmp_Cle_Id;
  l_rle_code:= NVL(P_AC_REC_IN.RLE_CODE,'VENDOR');

  Validate_svc_cle_id(
    p_ac_rec            =>  P_ac_rec_in,
    x_return_status 	=>  l_return_status);

  IF NOT l_Return_status = OKC_API.G_RET_STS_SUCCESS
  THEN
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Error in Service Line Validation');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  Validate_Tmp_cle_id(
    p_ac_rec            =>  P_ac_rec_in,
    x_template_yn       => l_cov_templ_yn,
    x_return_status 	=>  l_return_status);

  IF NOT l_Return_status = OKC_API.G_RET_STS_SUCCESS
  THEN
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Error in Coverage Template Line Validation');
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  IF NOT (sysdate BETWEEN LineDet_Rec.Start_Date AND
                          LineDet_Rec.End_Date)
  THEN

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Coverage Template_dates');
         x_return_status := OKC_API.G_RET_STS_ERROR;
    RETURN;
  END IF;


  OPEN  Check_Cur(l_service_Line_Id);
  FETCH Check_Cur INTO l_Exists;
  CLOSE Check_Cur;

  IF NOT l_Exists=0
  THEN  l_Msg_data:='Coverage already Exists';
    OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Coverage Exists');
     x_return_status := OKC_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Contract Line for the Service Line
  OPEN Cur_LineDet(l_Service_line_Id);
  FETCH Cur_LineDet INTO LineDet_Rec;
  IF Cur_LineDet%FOUND
  THEN
    l_Parent_lse_Id:=LineDet_Rec.lse_Id;
    g_chr_Id:=LineDet_Rec.chr_Id;
  ELSE
    OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Given Service or Warranty does not exist');
    CLOSE Cur_LineDet;
    l_return_status := OKC_API.G_RET_STS_ERROR;
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
  CLOSE Cur_LineDet;

  -- Coverage for that Service Line

  OPEN Cur_LineDet(l_Template_line_Id);
  FETCH Cur_LineDet INTO LineDet_Rec;
  IF Cur_LineDet%FOUND
  THEN
     tmp_lse_id:=LineDet_Rec.lse_Id;
  ELSE
    OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Coverage Template does not exist');
    CLOSE Cur_LineDet;
    l_return_status := OKC_API.G_RET_STS_ERROR;
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
  CLOSE Cur_LineDet;

 -- commented for NEW  ER ; warranty to be opened up for bill types and bill rates
 -- added additional check tmp_lse_id NOT IN (2,20) for bug # 3378148

  IF (l_Parent_lse_id in (1,19)) THEN
     IF (tmp_lse_id NOT IN (2,20)) THEN
        OKC_API.set_message(G_APP_NAME, l_type_msmtch);
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
  ELSIF (l_Parent_lse_id = 14) THEN
     IF (tmp_lse_id <> 15) THEN
        OKC_API.set_message(G_APP_NAME, l_type_msmtch);
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
 -- commented on 15-Jan-2004 SMOHAPAT
 /*  ELSIF (l_Parent_lse_id = 19) THEN
     IF (tmp_lse_id <> 20) THEN
        OKC_API.set_message(G_APP_NAME, l_type_msmtch);
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
  */
  END IF;


   -- Create Coverage line
  Init_Clev(l_clev_tbl_in);

  l_clev_tbl_in(1).chr_id 	            := Null;
  l_clev_tbl_in(1).cle_id 	            := l_Service_Line_Id;
  l_clev_tbl_in(1).dnz_chr_id           := g_chr_id;
  l_clev_tbl_in(1).sfwt_flag	        := LineDet_Rec.sfwt_flag;
  l_clev_tbl_in(1).lse_id	            := l_Parent_lse_Id+1; --LineDet_Rec.lse_id
  l_clev_tbl_in(1).sts_code	            := GetStatus( l_Service_Line_Id);
  l_clev_tbl_in(1).Currency_code        := GetCurrency( l_Service_Line_Id);
  l_clev_tbl_in(1).display_sequence     := LineDet_Rec.Display_Sequence;
  l_clev_tbl_in(1).line_number          := nvl(LineDet_Rec.Line_Number,1);
  l_clev_tbl_in(1).exception_yn         := nvl(LineDet_Rec.exception_yn,'N');
  l_clev_tbl_in(1).item_description     := LineDet_Rec.item_description;
  l_clev_tbl_in(1).name		            := LineDet_Rec.name;
  l_clev_tbl_in(1).start_date	        := P_ac_rec_in.start_date;
  l_clev_tbl_in(1).end_date	            := P_ac_rec_in.end_date;
  l_clev_tbl_in(1).attribute_category   := LineDet_Rec.attribute_category;
  l_clev_tbl_in(1).attribute1           := LineDet_Rec.attribute1;
  l_clev_tbl_in(1).attribute2           := LineDet_Rec.attribute2;
  l_clev_tbl_in(1).attribute3           := LineDet_Rec.attribute3;
  l_clev_tbl_in(1).attribute4           := LineDet_Rec.attribute4;
  l_clev_tbl_in(1).attribute5           := LineDet_Rec.attribute5;
  l_clev_tbl_in(1).attribute6           := LineDet_Rec.attribute6;
  l_clev_tbl_in(1).attribute7           := LineDet_Rec.attribute7;
  l_clev_tbl_in(1).attribute8           := LineDet_Rec.attribute8;
  l_clev_tbl_in(1).attribute9           := LineDet_Rec.attribute9;
  l_clev_tbl_in(1).attribute10          := LineDet_Rec.attribute10;
  l_clev_tbl_in(1).attribute11          := LineDet_Rec.attribute11;
  l_clev_tbl_in(1).attribute12          := LineDet_Rec.attribute12;
  l_clev_tbl_in(1).attribute13          := LineDet_Rec.attribute13;
  l_clev_tbl_in(1).attribute14          := LineDet_Rec.attribute14;
  l_clev_tbl_in(1).attribute15          := LineDet_Rec.attribute15;



  okc_contract_pub.create_contract_line (
   	  p_api_version			=> l_api_version,
  	  p_init_msg_list		=> l_init_msg_list,
  	  x_return_status		=> l_return_status,
      x_msg_count			=> l_msg_count,
      x_msg_data			=> l_msg_data,
      p_restricted_update           => p_restricted_update,
      p_clev_tbl			=> l_clev_tbl_in,
  	  x_clev_tbl			=> l_clev_tbl_out
      );


  IF (G_DEBUG_ENABLED = 'Y') THEN
      okc_debug.log('After okc_contract_pub create_contract_line', 2);
  END IF;

  IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
  ELSE
      c_cle_id := l_clev_tbl_out(1).Id;
  END IF;

-- Create record in OKS_K_LINES (new for 11.5.10)

FOR oks_cov_rec IN CUR_GET_OKS_LINE(l_Template_Line_Id)
LOOP

INIT_OKS_K_LINE(l_klnv_tbl_in);

    l_klnv_tbl_in(1).cle_id                         := c_cle_id ;
    l_klnv_tbl_in(1).dnz_chr_id                     := g_chr_id;
    l_klnv_tbl_in(1).coverage_type                  := oks_cov_rec.coverage_type;
    l_klnv_tbl_in(1).exception_cov_id               := oks_cov_rec.exception_cov_id;
    l_klnv_tbl_in(1).transfer_option                := oks_cov_rec.transfer_option;
    l_klnv_tbl_in(1).prod_upgrade_yn                := oks_cov_rec.prod_upgrade_yn;
    l_klnv_tbl_in(1).inheritance_type               := oks_cov_rec.inheritance_type;
   /* Commented by Jvorugan for R12. Bugno:4610449  l_klnv_tbl_in(1).pm_program_id := oks_cov_rec.pm_program_id;
    l_klnv_tbl_in(1).pm_conf_req_yn                 := oks_cov_rec.pm_conf_req_yn;
    l_klnv_tbl_in(1).pm_sch_exists_yn               := oks_cov_rec.pm_sch_exists_yn;  */
    l_klnv_tbl_in(1).sync_date_install              := oks_cov_rec.sync_date_install;
    l_klnv_tbl_in(1).sfwt_flag                      := oks_cov_rec.sfwt_flag;
    l_klnv_tbl_in(1).object_version_number          := 1; --oks_cov_rec.object_version_number;
    l_klnv_tbl_in(1).security_group_id              := oks_cov_rec.security_group_id;

                          OKS_CONTRACT_LINE_PUB.CREATE_LINE(p_api_version    => l_api_version,
                                                        	p_init_msg_list	 => l_init_msg_list,
                                                            x_return_status	 => l_return_status,
                                                            x_msg_count	     => l_msg_count,
                                                            x_msg_data		 => l_msg_data,
                                                            p_klnv_tbl       => l_klnv_tbl_in,
                                                            x_klnv_tbl       => l_klnv_tbl_out,
                                                            p_validate_yn    => 'N');



  IF (G_DEBUG_ENABLED = 'Y') THEN
      okc_debug.log('After OKS_CONTRACT_LINE_PUB.CREATE_LINE', 2);
  END IF;


  IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
END LOOP;


/* Commented by jvorugan. Since notes and pm creation will be done by create_k_coverage_ext
   during renual consolidation,it should not be created.
--Create Notes and PM schedule only if it is invoked from CREATE_ADJUSTED_COVERAGE based on 12.0 design
IF l_cov_templ_yn = 'N' then
  -- create notes for actual coverage from the template
  FOR notes_rec IN CUR_GET_NOTES(l_Template_Line_Id) LOOP

      JTF_NOTES_PUB.writeLobToData(notes_rec.JTF_NOTE_ID,L_Notes_detail);

      JTF_NOTES_PUB.CREATE_NOTE(p_parent_note_id        => notes_rec.parent_note_id ,
                                p_api_version           => l_api_version,
                                p_init_msg_list         =>  l_init_msg_list,
                                p_commit                => 'F',
                                p_validation_level      => 100,
                                x_return_status         => l_return_status ,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data ,
                                p_org_id                =>  NULL,
                                p_source_object_id      => l_Service_Line_Id,
                                p_source_object_code    => 'OKS_COV_NOTE',
                                p_notes                 =>notes_rec.notes,
                                p_notes_detail          => L_Notes_detail,
                                p_note_status           =>  notes_rec.note_status,
                                p_entered_by            =>  FND_GLOBAL.USER_ID,
                                p_entered_date          => SYSDATE ,
                                x_jtf_note_id           => l_jtf_note_id,
                                p_last_update_date      => sysdate,
                                p_last_updated_by       => FND_GLOBAL.USER_ID,
                                p_creation_date         => SYSDATE,
                                p_created_by            => FND_GLOBAL.USER_ID,
                                p_last_update_login     => FND_GLOBAL.LOGIN_ID,
                                p_attribute1            => notes_rec.ATTRIBUTE1,
                                p_attribute2            => notes_rec.ATTRIBUTE2,
                                p_attribute3            => notes_rec.ATTRIBUTE3,
                                p_attribute4            => notes_rec.ATTRIBUTE4,
                                p_attribute5            => notes_rec.ATTRIBUTE5,
                                p_attribute6            => notes_rec.ATTRIBUTE6,
                                p_attribute7            => notes_rec.ATTRIBUTE7,
                                p_attribute8            => notes_rec.ATTRIBUTE8,
                                p_attribute9            => notes_rec.ATTRIBUTE9,
                                p_attribute10           => notes_rec.ATTRIBUTE10,
                                p_attribute11           => notes_rec.ATTRIBUTE11,
                                p_attribute12           => notes_rec.ATTRIBUTE12,
                                p_attribute13           => notes_rec.ATTRIBUTE13,
                                p_attribute14           => notes_rec.ATTRIBUTE14,
                                p_attribute15           => notes_rec.ATTRIBUTE15,
                                p_context               => notes_rec.CONTEXT,
                                p_note_type             => notes_rec.NOTE_TYPE);

        IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
   END LOOP;

  OPEN  CUR_GET_PROGRAM_ID(l_Service_Line_Id);
  FETCH CUR_GET_PROGRAM_ID INTO l_pm_program_id;
  CLOSE CUR_GET_PROGRAM_ID;

-- Commented by Jvorugan for R12 bugno:4610449
--IF l_klnv_tbl_in(1).pm_program_id IS NOT NULL then -- No need to call PM schedule instantiation if there is no program id
  IF l_pm_program_id IS NOT NULL then

 OKS_PM_PROGRAMS_PVT. CREATE_PM_PROGRAM_SCHEDULE(
    p_api_version        => l_api_version,
    p_init_msg_list      => l_init_msg_list,
    x_return_status      => l_return_status,
    x_msg_count          => l_msg_count,
    x_msg_data           => l_msg_data,
    p_template_cle_id    => l_Template_Line_Id,
    p_cle_id             => l_Service_Line_Id, --c_cle_id, --instantiated cle id
    p_cov_start_date     => P_ac_rec_in.start_date,
    p_cov_end_date       => P_ac_rec_in.end_date);



  IF (G_DEBUG_ENABLED = 'Y') THEN
      okc_debug.log('After OKS_PM_PROGRAMS_PVT. CREATE_PM_PROGRAM_SCHEDULE'||l_return_status, 2);
  END IF;


  IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
 END IF;
END IF; -- end of IF condition if l_cov_templ_yn = N

*/ -- End of changes by Jvorugan
         l_klnv_tbl_in.delete;
  -- FOR THE BUSINESS PROCESSES UNDER COVERAGE TEMPLATE


  FOR Childline_Rec1 IN Cur_Childline(l_template_line_id,tmp_lse_id+1)
  LOOP                                                                --L1
    tmp_txg_cle_id:=ChildLine_rec1.Id;

    -- FOR ALL THE LINES UNDER BUSINESS PROCESS

    FOR LineDet_Rec1 IN Cur_LineDet(tmp_txg_cle_Id)
    LOOP

       FOR oks_bp_rec IN CUR_GET_OKS_LINE(tmp_txg_cle_id)
       LOOP
        -- Offset Period Logic for Start date and End date
      IF oks_bp_rec.offset_duration IS NOT NULL
      AND oks_bp_rec.offset_period IS NOT NULL
      THEN

        l_start_date:=OKC_Time_Util_Pub.get_enddate
                        (P_ac_Rec_In.Start_date,
                        oks_bp_rec.offset_period,
                        oks_bp_rec.offset_Duration);

        IF oks_bp_rec.offset_duration > 0
        THEN
          l_start_date := l_start_date + 1;
        END IF;

        IF NOT l_start_date>P_Ac_Rec_In.End_Date
        THEN
          g_start_date:=l_start_date;
          g_end_date:= P_Ac_Rec_In.End_Date;
        ELSE
          g_start_date:= P_Ac_Rec_In.End_Date;
          g_end_date:= P_Ac_Rec_In.End_Date;
        END IF;
     ELSE
          g_start_date:= P_Ac_Rec_In.Start_Date;
          g_end_date:= P_Ac_Rec_In.End_Date;
     END IF;

      -- Create Contract Line for the (Business Process) of Actual Coverage
      Init_Clev(l_clev_tbl_in);
      l_clev_tbl_in(1).dnz_chr_id	        := g_chr_id;
      l_clev_tbl_in(1).cle_id		        := c_cle_id;
      l_clev_tbl_in(1).chr_id               := Null;
      l_clev_tbl_in(1).sfwt_flag	        := LineDet_Rec1.sfwt_flag;
      l_clev_tbl_in(1).lse_id		        := l_Parent_lse_Id+2; -- LineDet_Rec1.lse_id;
      l_clev_tbl_in(1).display_sequence     := LineDet_Rec1.Display_Sequence;
      l_clev_tbl_in(1).Name		            := LineDet_Rec1.Name;
      l_clev_tbl_in(1).exception_yn	        := LineDet_Rec1.exception_yn;
      l_clev_tbl_in(1).start_date	        := g_start_date;
      l_clev_tbl_in(1).end_date	            := g_end_date;
      l_clev_tbl_in(1).sts_code	            := GetStatus( l_Service_Line_Id);
      l_clev_tbl_in(1).Currency_code	    := GetCurrency( l_Service_Line_Id);
      l_clev_tbl_in(1).attribute_category   := LineDet_Rec1.attribute_category;
      l_clev_tbl_in(1).attribute1           := LineDet_Rec1.attribute1;
      l_clev_tbl_in(1).attribute2           := LineDet_Rec1.attribute2;
      l_clev_tbl_in(1).attribute3           := LineDet_Rec1.attribute3;
      l_clev_tbl_in(1).attribute4           := LineDet_Rec1.attribute4;
      l_clev_tbl_in(1).attribute5           := LineDet_Rec1.attribute5;
      l_clev_tbl_in(1).attribute6           := LineDet_Rec1.attribute6;
      l_clev_tbl_in(1).attribute7           := LineDet_Rec1.attribute7;
      l_clev_tbl_in(1).attribute8           := LineDet_Rec1.attribute8;
      l_clev_tbl_in(1).attribute9           := LineDet_Rec1.attribute9;
      l_clev_tbl_in(1).attribute10          := LineDet_Rec1.attribute10;
      l_clev_tbl_in(1).attribute11          := LineDet_Rec1.attribute11;
      l_clev_tbl_in(1).attribute12          := LineDet_Rec1.attribute12;
      l_clev_tbl_in(1).attribute13          := LineDet_Rec1.attribute13;
      l_clev_tbl_in(1).attribute14          := LineDet_Rec1.attribute14;
      l_clev_tbl_in(1).attribute15          := LineDet_Rec1.attribute15;
      l_clev_tbl_in(1).price_list_id        := LineDet_Rec1.price_list_id;

           okc_contract_pub.create_contract_line(p_api_version			=> l_api_version,
                                           	     p_init_msg_list		=> l_init_msg_list,
     	                                         x_return_status		=> l_return_status,
                                                 x_msg_count			=> l_msg_count,
                                                 x_msg_data			    => l_msg_data,
                                                 p_restricted_update    => p_restricted_update,
                                                 p_clev_tbl			    => l_clev_tbl_in,
    	                                         x_clev_tbl			    => l_clev_tbl_out);




      IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
     	txg_cle_Id:=l_clev_tbl_out(1).ID;
      END IF;

      FOR ItemDet_Rec IN CUR_ItemDet(tmp_txg_cle_Id)
      LOOP                                                    --L3
        --  Create a Contract ITEM FOR BUSINESS PROCESS (ACTUAL COVERAGE)
        Init_Cimv(l_cimv_tbl_in);
	l_cimv_tbl_in(1).cle_id		        := txg_cle_Id;
	l_cimv_tbl_in(1).chr_id		        := null;
	l_cimv_tbl_in(1).cle_id_for	        := Null;
	l_cimv_tbl_in(1).object1_id1	    := ItemDet_Rec.object1_id1;
  	l_cimv_tbl_in(1).object1_id2	    := ItemDet_Rec.object1_id2;
	l_cimv_tbl_in(1).JTOT_OBJECT1_CODE  := ItemDet_Rec.JTOT_OBJECT1_CODE;
	l_cimv_tbl_in(1).exception_yn	    := ItemDet_Rec.exception_yn;
	l_cimv_tbl_in(1).number_of_items    := ItemDet_Rec.number_of_items;
	l_cimv_tbl_in(1).dnz_chr_id	        := g_chr_id;

        okc_contract_item_pub.create_contract_item (
   	  p_api_version			=> l_api_version,
  	  p_init_msg_list		=> l_init_msg_list,
  	  x_return_status		=> l_return_status,
      x_msg_count			=> l_msg_count,
      x_msg_data			=> l_msg_data,
      p_cimv_tbl			=> l_cimv_tbl_in,
  	  x_cimv_tbl			=> l_cimv_tbl_out);

      IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END LOOP;

       -- Create record in OKS_K_LINES

   INIT_OKS_K_LINE(l_klnv_tbl_in);

    l_klnv_tbl_in(1).cle_id                         := txg_cle_id ;
    l_klnv_tbl_in(1).dnz_chr_id                     := g_chr_id;
    l_klnv_tbl_in(1).discount_list                  := oks_bp_rec.discount_list;
    l_klnv_tbl_in(1).offset_duration                := oks_bp_rec.offset_duration;
    l_klnv_tbl_in(1).offset_period                  := oks_bp_rec.offset_period;
    l_klnv_tbl_in(1).allow_bt_discount              := oks_bp_rec.allow_bt_discount;
    l_klnv_tbl_in(1).apply_default_timezone         := oks_bp_rec.apply_default_timezone;
    l_klnv_tbl_in(1).sfwt_flag                      := oks_bp_rec.sfwt_flag;
    l_klnv_tbl_in(1).object_version_number          := 1; --oks_cov_rec.object_version_number;
    l_klnv_tbl_in(1).security_group_id              := oks_bp_rec.security_group_id;

           OKS_CONTRACT_LINE_PUB.CREATE_LINE(p_api_version   => l_api_version,
                                           	 p_init_msg_list => l_init_msg_list,
                                             x_return_status => l_return_status,
                                             x_msg_count	 => l_msg_count,
                                             x_msg_data		 => l_msg_data,
                                             p_klnv_tbl      => l_klnv_tbl_in,
                                             x_klnv_tbl      => l_klnv_tbl_out,
                                             p_validate_yn   => 'N');

                IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                      RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
           l_klnv_tbl_in.delete;
   -- Create Cover Time Rule For BUS PROC FOR ACTUAL COVERAGE

   FOR cov_tz_rec IN Get_cov_timezones(tmp_txg_cle_Id)
   LOOP

    INIT_OKS_TIMEZONE_LINE(l_covtz_tbl_in);

      l_covtz_tbl_in(1).cle_id                         := txg_cle_id;
      l_covtz_tbl_in(1).default_yn                     := cov_tz_rec.default_yn;
      l_covtz_tbl_in(1).timezone_id                    := cov_tz_rec.timezone_id;
      l_covtz_tbl_in(1).dnz_chr_id                     := g_chr_id;
               OKS_CTZ_PVT.insert_row(
                                      p_api_version      => l_api_version,
                                      p_init_msg_list	 => l_init_msg_list,
                                      x_return_status	 => l_return_status,
                                      x_msg_count	     => l_msg_count,
                                      x_msg_data		 => l_msg_data,
                                      p_oks_coverage_timezones_v_tbl => l_covtz_tbl_in,
                                      x_oks_coverage_timezones_v_tbl => l_covtz_tbl_out);


       IF (G_DEBUG_ENABLED = 'Y') THEN
           okc_debug.log('After OKS_CTZ_PVT insert_row'||l_return_status, 2);
       END IF;


      IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;


    covtim_ctr := 0;

    INIT_OKS_COVER_TIME_LINE(l_covtim_tbl_in);

   FOR cov_times_rec IN Get_cov_times(cov_tz_rec.id)
   LOOP
       covtim_ctr := covtim_ctr + 1;
    l_covtim_tbl_in(covtim_ctr).dnz_chr_id                     := g_chr_id;
    l_covtim_tbl_in(covtim_ctr).cov_tze_line_id                := l_covtz_tbl_out(1).id;
    l_covtim_tbl_in(covtim_ctr).start_hour                     := cov_times_rec.start_hour;
    l_covtim_tbl_in(covtim_ctr).start_minute                   := cov_times_rec.start_minute;
    l_covtim_tbl_in(covtim_ctr).end_hour                       := cov_times_rec.end_hour;
    l_covtim_tbl_in(covtim_ctr).end_minute                     := cov_times_rec.end_minute;
    l_covtim_tbl_in(covtim_ctr).monday_yn                      := cov_times_rec.monday_yn;
    l_covtim_tbl_in(covtim_ctr).tuesday_yn                     := cov_times_rec.tuesday_yn;
    l_covtim_tbl_in(covtim_ctr).wednesday_yn                   := cov_times_rec.wednesday_yn;
    l_covtim_tbl_in(covtim_ctr).thursday_yn                    := cov_times_rec.thursday_yn;
    l_covtim_tbl_in(covtim_ctr).friday_yn                      := cov_times_rec.friday_yn;
    l_covtim_tbl_in(covtim_ctr).saturday_yn                    := cov_times_rec.saturday_yn;
    l_covtim_tbl_in(covtim_ctr).sunday_yn                      := cov_times_rec.sunday_yn;
    l_covtim_tbl_in(covtim_ctr).security_group_id              := oks_bp_rec.security_group_id;
    l_covtim_tbl_in(covtim_ctr).program_application_id         := NULL;
    l_covtim_tbl_in(covtim_ctr).program_id                     := NULL;
    l_covtim_tbl_in(covtim_ctr).program_update_date            := NULL;
    l_covtim_tbl_in(covtim_ctr).request_id                     := NULL;
   END LOOP;

      OKS_CVT_PVT.insert_row(
                p_api_version    => l_api_version,
                p_init_msg_list	 => l_init_msg_list,
                x_return_status	 => l_return_status,
                x_msg_count	     => l_msg_count,
                x_msg_data		 => l_msg_data,
                p_oks_coverage_times_v_tbl  => l_covtim_tbl_in,
                x_oks_coverage_times_v_tbl  => l_covtim_tbl_out);
     END LOOP;


       IF (G_DEBUG_ENABLED = 'Y') THEN
           okc_debug.log('After OKS_CVT_PVT insert_row'||l_return_status, 2);
       END IF;


      IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
   END LOOP;  -- End loop for OKS_BP_REC

   -- Done Business Process

   -- For all Reaction Times in Template
      FOR tmp_crt_rec IN Cur_ChildLine1(tmp_txg_cle_Id,(tmp_lse_Id+2))
      LOOP
      tmp_crt_cle_id:=tmp_crt_rec.ID;

       OPEN Cur_Linedet3(tmp_crt_cle_id);
       FETCH Cur_Linedet3 INTO LineDet_Rec3;
       CLOSE Cur_LineDet3;

     -- Create same for Actual Coverage
     Init_clev(l_clev_tbl_in);
     l_clev_tbl_in(1).cle_id       	       := txg_cle_id;
     l_clev_tbl_in(1).chr_id       	       := null;
     l_clev_tbl_in(1).dnz_chr_id   	       := g_chr_id;
     l_clev_tbl_in(1).sfwt_flag	           := LineDet_Rec3.sfwt_flag;
     l_clev_tbl_in(1).lse_id	           := l_Parent_lse_Id+3; -- LineDet_Rec3.lse_id;
     l_clev_tbl_in(1).start_date	       := g_start_date;
     l_clev_tbl_in(1).end_date	           := g_end_date;
     l_clev_tbl_in(1).sts_code	           := GetStatus( l_Service_Line_Id);
     l_clev_tbl_in(1).Currency_code	       := GetCurrency( l_Service_Line_Id);
     l_clev_tbl_in(1).display_sequence     := LineDet_Rec3.Display_Sequence;
     l_clev_tbl_in(1).item_description     := LineDet_Rec3.Item_Description;
     l_clev_tbl_in(1).Name	               := LineDet_Rec3.Name;
     l_clev_tbl_in(1).exception_yn	       := LineDet_Rec3.exception_yn;
     l_clev_tbl_in(1).attribute_category   := LineDet_Rec3.attribute_category;
     l_clev_tbl_in(1).attribute1           := LineDet_Rec3.attribute1;
     l_clev_tbl_in(1).attribute2           := LineDet_Rec3.attribute2;
     l_clev_tbl_in(1).attribute3           := LineDet_Rec3.attribute3;
     l_clev_tbl_in(1).attribute4           := LineDet_Rec3.attribute4;
     l_clev_tbl_in(1).attribute5           := LineDet_Rec3.attribute5;
     l_clev_tbl_in(1).attribute6           := LineDet_Rec3.attribute6;
     l_clev_tbl_in(1).attribute7           := LineDet_Rec3.attribute7;
     l_clev_tbl_in(1).attribute8           := LineDet_Rec3.attribute8;
     l_clev_tbl_in(1).attribute9           := LineDet_Rec3.attribute9;
     l_clev_tbl_in(1).attribute10          := LineDet_Rec3.attribute10;
     l_clev_tbl_in(1).attribute11          := LineDet_Rec3.attribute11;
     l_clev_tbl_in(1).attribute12          := LineDet_Rec3.attribute12;
     l_clev_tbl_in(1).attribute13          := LineDet_Rec3.attribute13;
     l_clev_tbl_in(1).attribute14          := LineDet_Rec3.attribute14;
     l_clev_tbl_in(1).attribute15          := LineDet_Rec3.attribute15;

     okc_contract_pub.create_contract_line (
                                       	   p_api_version	    => l_api_version,
                                   	       p_init_msg_list		=> l_init_msg_list,
                                           x_return_status		=> l_return_status,
                                           x_msg_count			=> l_msg_count,
                                           x_msg_data			=> l_msg_data,
                                           p_restricted_update  => p_restricted_update,
                                           p_clev_tbl			=> l_clev_tbl_in,
                                       	   x_clev_tbl			=> l_clev_tbl_out);

     IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
     ELSE
          crt_cle_id:=l_clev_tbl_out(1).ID;
     END IF;

    -- Create record in OKS_K_LINES



         FOR oks_react_rec IN CUR_GET_OKS_LINE(tmp_crt_cle_id)
         LOOP

              INIT_OKS_K_LINE(l_klnv_tbl_in) ;

                l_klnv_tbl_in(1).cle_id                         := crt_cle_id ;
                l_klnv_tbl_in(1).dnz_chr_id                     := g_chr_id;
                l_klnv_tbl_in(1).react_time_name                := oks_react_rec.react_time_name;
                l_klnv_tbl_in(1).incident_severity_id           := oks_react_rec.incident_severity_id;
                l_klnv_tbl_in(1).pdf_id                         := oks_react_rec.pdf_id;
                l_klnv_tbl_in(1).work_thru_yn                   := oks_react_rec.work_thru_yn;
                l_klnv_tbl_in(1).react_active_yn                := oks_react_rec.react_active_yn;
                l_klnv_tbl_in(1).sfwt_flag                      := oks_react_rec.sfwt_flag;
                l_klnv_tbl_in(1).object_version_number          := 1; --oks_cov_rec.object_version_number;
                l_klnv_tbl_in(1).security_group_id              := oks_react_rec.security_group_id;

                       OKS_CONTRACT_LINE_PUB.create_line(
                                            p_api_version     => l_api_version,
                                            p_init_msg_list	  => l_init_msg_list,
                                            x_return_status	  => l_return_status,
                                            x_msg_count	      => l_msg_count,
                                            x_msg_data	      => l_msg_data,
                                            p_klnv_tbl        => l_klnv_tbl_in,
                                            x_klnv_tbl        => l_klnv_tbl_out,
                                            p_validate_yn     => 'N');

                 IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;
                    l_rt_cle_id := l_klnv_tbl_out(1).id ;
          END LOOP;  -- end loop for oks_react_rec


  FOR act_type_rec IN CUR_GET_ACTION_TYPES(tmp_crt_cle_id)
  LOOP

  INIT_OKS_ACT_TYPE(l_act_type_tbl_in);

  l_act_type_line_id := act_type_rec.id ;

  l_act_type_tbl_in(1).cle_id           := crt_cle_id; --l_rt_cle_id ;
  l_act_type_tbl_in(1).dnz_chr_id       := g_chr_id;
  l_act_type_tbl_in(1).action_type_code := act_type_rec.action_type_code;

   OKS_ACT_PVT.INSERT_ROW(p_api_version   => l_api_version,
                          p_init_msg_list => l_init_msg_list,
                          x_return_status => l_return_status,
                          x_msg_count     => l_msg_count,
                          x_msg_data      => l_msg_data,
                          p_oks_action_time_types_v_tbl => l_act_type_tbl_in,
                          x_oks_action_time_types_v_tbl => l_act_type_tbl_out);

       IF (G_DEBUG_ENABLED = 'Y') THEN
           okc_debug.log('After OKS_ACT_PVT INSERT_ROW'||l_return_status, 2);
       END IF;



    IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
            l_cov_act_type_line_id := l_act_type_tbl_out(1).id ;

            act_time_ctr:= 0;

      FOR act_time_rec IN CUR_GET_ACTION_TIMES(l_act_type_line_id)
      LOOP
       act_time_ctr := act_time_ctr + 1 ;

      INIT_OKS_ACT_TIME(l_act_time_tbl_in);
      l_act_time_tbl_in(act_time_ctr).cov_action_type_id  := l_cov_act_type_line_id ;
      l_act_time_tbl_in(act_time_ctr).cle_id              := crt_cle_id; --l_rt_cle_id;
      l_act_time_tbl_in(act_time_ctr).dnz_chr_id          := g_chr_id;
      l_act_time_tbl_in(act_time_ctr).uom_code            := act_time_rec.uom_code;
      l_act_time_tbl_in(act_time_ctr).sun_duration        := act_time_rec.sun_duration;
      l_act_time_tbl_in(act_time_ctr).mon_duration        := act_time_rec.mon_duration;
      l_act_time_tbl_in(act_time_ctr).tue_duration        := act_time_rec.tue_duration;
      l_act_time_tbl_in(act_time_ctr).wed_duration        := act_time_rec.wed_duration;
      l_act_time_tbl_in(act_time_ctr).thu_duration        := act_time_rec.thu_duration;
      l_act_time_tbl_in(act_time_ctr).fri_duration        := act_time_rec.fri_duration;
      l_act_time_tbl_in(act_time_ctr).sat_duration        := act_time_rec.sat_duration;
    END LOOP ; -- END LOOP FOR ACT_TIME_REC

                           OKS_ACM_PVT.insert_row(p_api_version     => l_api_version,
                                                 p_init_msg_list   =>  l_init_msg_list,
                                                 x_return_status   => l_return_status,
                                                 x_msg_count       => l_msg_count,
                                                 x_msg_data        => l_msg_data,
                                                 p_oks_action_times_v_tbl => l_act_time_tbl_in,
                                                 x_oks_action_times_v_tbl => l_act_time_tbl_out);

       IF (G_DEBUG_ENABLED = 'Y') THEN
           okc_debug.log('After OKS_ACM_PVT insert_row'||l_return_status, 2);
       END IF;

       IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END LOOP ;  -- END LOOP FOR ACT_TYPE_REC
   END LOOP;

  -- Preferred Engineers

  OPEN Cur_PTRLDet(Tmp_txg_cle_Id,'VENDOR');
  FETCH Cur_PTRLDet INTO PTRLDet_Rec;
  IF NOT Cur_PTRLDet%FOUND
  THEN
    tmp_cpl_id:=NULL;
  ELSE
    tmp_cpl_id:=PtrlDet_Rec.Id;
  END IF;
  CLOSE Cur_PTRLDet;

  -- If it's there in Template, create it for Actual Coverage
  IF NOT tmp_cpl_id IS NULL
  THEN
    --Init_Cplv(l_cplv_tbl_in);
    l_cplv_tbl_in(1).sfwt_flag		:='N';
    l_cplv_tbl_in(1).cle_id		:= txg_cle_id;
    l_cplv_tbl_in(1).dnz_chr_id	:= g_chr_id;
    l_cplv_tbl_in(1).rle_code          := l_rle_code ; --'VENDOR';
   -- l_cplv_tbl_in(1).object1_id1       :=PtrlDet_Rec.object1_id1;
   --  l_cplv_tbl_in(1).object1_id2       :=PtrlDet_Rec.object1_id2;
   --  l_cplv_tbl_in(1).jtot_object1_code :=PtrlDet_Rec.jtot_object1_code;

-- Fix for Bug:4703431. Modified by Jvorugan
      open CUR_GET_ORG_ID(g_chr_id);
      fetch CUR_GET_ORG_ID INTO l_object_id;
      close CUR_GET_ORG_ID;

       l_cplv_tbl_in(1).object1_id1       :=l_object_id;
       l_cplv_tbl_in(1).object1_id2       := '#';
       l_cplv_tbl_in(1).jtot_object1_code :='OKX_OPERUNIT';
 -- End of changes for  Bug:4703431.


    OKC_CONTRACT_PARTY_PUB.Create_k_Party_Role(
	p_api_version			=> l_api_version,
	p_init_msg_list			=> l_init_msg_list,
	x_return_status			=> l_return_status,
	x_msg_count			=> l_msg_count,
	x_msg_data			=> l_msg_data,
	p_cplv_tbl			=> l_cplv_tbl_in,
	x_cplv_tbl			=> l_cplv_tbl_out);

    IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      l_cpl_id	:=l_cplv_tbl_out(1).Id;
    END IF;

    FOR ContactDet_Rec IN Cur_ContactDet(tmp_cpl_Id)
    LOOP
      -- To Create Contact
      Init_CTCV(l_ctcv_tbl_in);
      l_ctcv_tbl_in(1).cpl_id		 := l_cpl_id;
      l_ctcv_tbl_in(1).cro_code		 := ContactDet_rec.cro_code;
      l_ctcv_tbl_in(1).dnz_chr_id	 := g_chr_id;
      l_ctcv_tbl_in(1).contact_sequence  :=ContactDet_rec.contact_sequence;
      l_ctcv_tbl_in(1).object1_id1	 := ContactDet_Rec.Object1_id1;
      l_ctcv_tbl_in(1).object1_id2	 := ContactDet_Rec.Object1_id2;
      l_ctcv_tbl_in(1).JTOT_OBJECT1_CODE := ContactDet_Rec.JTOT_OBJECT1_CODE;
      l_ctcv_tbl_in(1).resource_class        := ContactDet_Rec.resource_class;

      OKC_CONTRACT_PARTY_PUB.Create_Contact(
	   p_api_version		=> l_api_version,
	   p_init_msg_list		=> l_init_msg_list,
	   x_return_status		=> l_return_status,
	   x_msg_count			=> l_msg_count,
	   x_msg_data			=> l_msg_data,
	   p_ctcv_tbl			=> l_ctcv_tbl_in,
	   x_ctcv_tbl			=> l_ctcv_tbl_out);


      IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_contact_id	:=l_ctcv_tbl_out(1).Id;
      END IF;
    END LOOP;
  END IF;
  -- Done Preferred Engineer

  -- For all the Bill Types in Template, create the same for ACTUAL COVERAGE

  IF l_Parent_Lse_Id =14
    THEN
      l_bt_lse_Id:=59;
  ELSE
      l_bt_lse_Id:=tmp_lse_id+3;
  END IF;


 -- FOR tmp_bt_Rec IN Cur_ChildLine_bt(tmp_txg_cle_Id,tmp_lse_id+3)
  FOR tmp_bt_Rec IN Cur_ChildLine_bt(tmp_txg_cle_Id,l_bt_lse_Id)
  LOOP
    tmp_bt_cle_id:=tmp_bt_Rec.Id;

    -- For Warranty
    -- commented for NEW  ER ; warranty to be opened up for bill types and bill rates
/*
    IF l_Parent_Lse_Id =14
    THEN
      tmp_bt_cle_Id:=NULL;
    END IF;
*/

    IF NOT tmp_bt_cle_id IS NULL
    THEN
      OPEN Cur_Linedet3(tmp_bt_cle_id);
      FETCH Cur_Linedet3 INTO LineDet_Rec3;
      CLOSE Cur_LineDet3;

      Init_Clev(l_clev_tbl_in);
      l_clev_tbl_in(1).cle_id       	    := txg_cle_id;
      l_clev_tbl_in(1).chr_id       	    := null;
      l_clev_tbl_in(1).dnz_chr_id   	    := g_chr_id;
      l_clev_tbl_in(1).sfwt_flag	    :=LineDet_Rec3.sfwt_flag;

-- changed for NEW  ER ; warranty to be opened up for bill types and bill rates

      IF l_Parent_Lse_Id in (1,19) THEN
        l_clev_tbl_in(1).lse_id		    :=l_Parent_lse_Id+4;--LineDet_Rec3.lse_id ;
      ELSIF l_Parent_Lse_Id in (14) THEN
        l_clev_tbl_in(1).lse_id		    := 59; --l_Parent_lse_Id+4;--LineDet_Rec3.lse_id ;
      END IF;

      l_clev_tbl_in(1).start_date	    := g_start_date;
      l_clev_tbl_in(1).end_date	            := g_end_date;
      l_clev_tbl_in(1).sts_code	            := GetStatus( l_Service_Line_Id);
      l_clev_tbl_in(1).Currency_code	    := GetCurrency( l_Service_Line_Id);
      l_clev_tbl_in(1).display_sequence     := LineDet_Rec3.Display_sequence;
      l_clev_tbl_in(1).item_description     := LineDet_Rec3.Item_Description;
      l_clev_tbl_in(1).Name		    := LineDet_Rec3.Name;
      l_clev_tbl_in(1).exception_yn	    := LineDet_Rec3.exception_yn;
      l_clev_tbl_in(1).attribute_category   := LineDet_Rec3.attribute_category;
      l_clev_tbl_in(1).attribute1           := LineDet_Rec3.attribute1;
      l_clev_tbl_in(1).attribute2           := LineDet_Rec3.attribute2;
      l_clev_tbl_in(1).attribute3           := LineDet_Rec3.attribute3;
      l_clev_tbl_in(1).attribute4           := LineDet_Rec3.attribute4;
      l_clev_tbl_in(1).attribute5           := LineDet_Rec3.attribute5;
      l_clev_tbl_in(1).attribute6           := LineDet_Rec3.attribute6;
      l_clev_tbl_in(1).attribute7           := LineDet_Rec3.attribute7;
      l_clev_tbl_in(1).attribute8           := LineDet_Rec3.attribute8;
      l_clev_tbl_in(1).attribute9           := LineDet_Rec3.attribute9;
      l_clev_tbl_in(1).attribute10          := LineDet_Rec3.attribute10;
      l_clev_tbl_in(1).attribute11          := LineDet_Rec3.attribute11;
      l_clev_tbl_in(1).attribute12          := LineDet_Rec3.attribute12;
      l_clev_tbl_in(1).attribute13          := LineDet_Rec3.attribute13;
      l_clev_tbl_in(1).attribute14          := LineDet_Rec3.attribute14;
      l_clev_tbl_in(1).attribute15          := LineDet_Rec3.attribute15;


      okc_contract_pub.create_contract_line (
   	p_api_version			=> l_api_version,
  	p_init_msg_list			=> l_init_msg_list,
     	x_return_status			=> l_return_status,
        x_msg_count			=> l_msg_count,
        x_msg_data			=> l_msg_data,
        p_restricted_update             => p_restricted_update,
        p_clev_tbl			=> l_clev_tbl_in,
    	x_clev_tbl			=> l_clev_tbl_out);


      IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        bt_cle_id:=l_clev_tbl_out(1).ID;
      END IF;
    -- Create record in OKS_K_LINES
 FOR oks_bt_rec IN CUR_GET_OKS_LINE(tmp_bt_cle_id)
 LOOP
 INIT_OKS_K_LINE(l_klnv_tbl_in);
    l_klnv_tbl_in(1).cle_id                         := bt_cle_id ;
    l_klnv_tbl_in(1).dnz_chr_id                     := g_chr_id;
    l_klnv_tbl_in(1).limit_uom_quantified           := oks_bt_rec.limit_uom_quantified;
    l_klnv_tbl_in(1).discount_amount                := oks_bt_rec.discount_amount;
    l_klnv_tbl_in(1).discount_percent               := oks_bt_rec.discount_percent;
    l_klnv_tbl_in(1).work_thru_yn                   := oks_bt_rec.work_thru_yn;
    l_klnv_tbl_in(1).react_active_yn                := oks_bt_rec.react_active_yn;
    l_klnv_tbl_in(1).sfwt_flag                      := oks_bt_rec.sfwt_flag;
    l_klnv_tbl_in(1).object_version_number          := 1; --oks_cov_rec.object_version_number;
    l_klnv_tbl_in(1).security_group_id              := oks_bt_rec.security_group_id;

 OKS_CONTRACT_LINE_PUB.CREATE_LINE(p_api_version    => l_api_version,
                                                        	p_init_msg_list	 => l_init_msg_list,
                                                            x_return_status	 => l_return_status,
                                                            x_msg_count	     => l_msg_count,
                                                            x_msg_data		 => l_msg_data,
                                                            p_klnv_tbl       => l_klnv_tbl_in,
                                                            x_klnv_tbl       => l_klnv_tbl_out,
                                                            p_validate_yn    => 'N');


  IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
  END LOOP;
      -- For all the Contract Item for BILL TYPE in TEMPLATE, create the same for Actual Coverage
      FOR ItemDet_Rec IN CUR_ItemDet(tmp_bt_cle_Id)
      LOOP                                                    --L3
        INIT_CIMV(l_cimv_tbl_in);
	l_cimv_tbl_in(1).cle_id		    := bt_cle_Id;
	l_cimv_tbl_in(1).chr_id		    := null;
	l_cimv_tbl_in(1).cle_id_for	    := Null;
	l_cimv_tbl_in(1).object1_id1	    := ItemDet_Rec.object1_id1;
  	l_cimv_tbl_in(1).object1_id2	    := ItemDet_Rec.object1_id2;
	l_cimv_tbl_in(1).JTOT_OBJECT1_CODE  := ItemDet_Rec.JTOT_OBJECT1_CODE;
	l_cimv_tbl_in(1).exception_yn	    := ItemDet_Rec.exception_yn;
	l_cimv_tbl_in(1).number_of_items    := ItemDet_Rec.number_of_items;
	l_cimv_tbl_in(1).dnz_chr_id	    := g_chr_id;

        okc_contract_item_pub.create_contract_item (
   	  p_api_version			=> l_api_version,
  	  p_init_msg_list		=> l_init_msg_list,
     	  x_return_status		=> l_return_status,
          x_msg_count			=> l_msg_count,
          x_msg_data			=> l_msg_data,
          p_cimv_tbl			=> l_cimv_tbl_in,
    	  x_cimv_tbl			=> l_cimv_tbl_out);

       IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END LOOP;

      -- For all the Bill Rate in Template, create the same in Actual

      IF l_Parent_Lse_Id =14
        THEN
          l_br_lse_Id:=60;
      ELSE
          l_br_lse_Id:=tmp_lse_id+4;
      END IF;

--      FOR tmp_br_Rec IN Cur_ChildLine_br(tmp_bt_cle_id,tmp_lse_id+4)
      FOR tmp_br_Rec IN Cur_ChildLine_br(tmp_bt_cle_id,l_br_lse_Id)
      LOOP
         tmp_br_cle_id:=tmp_br_Rec.Id;
        IF NOT tmp_br_cle_id IS NULL
        THEN
          Init_clev(l_clev_tbl_in);
          l_clev_tbl_in(1).cle_id               := bt_cle_id;
          l_clev_tbl_in(1).chr_id               := null;
          l_clev_tbl_in(1).dnz_chr_id           := g_chr_id;
    	  l_clev_tbl_in(1).sfwt_flag	        := LineDet_Rec.sfwt_flag;

      -- changed for NEW  ER ; warranty to be opened up for bill types and bill rates

      IF l_Parent_Lse_Id in (1,19) THEN
        l_clev_tbl_in(1).lse_id		    :=l_Parent_lse_Id+5;-- tmp_br_rec.lse_id;
      ELSIF l_Parent_Lse_Id in (14) THEN
        l_clev_tbl_in(1).lse_id		    := 60; -- tmp_br_rec.lse_id;
      END IF;

	  l_clev_tbl_in(1).start_date	        := g_start_date;
   	  l_clev_tbl_in(1).end_date	            := g_end_date;
	  l_clev_tbl_in(1).sts_code	            := GetStatus( l_Service_Line_Id);
      l_clev_tbl_in(1).Currency_code        := GetCurrency( l_Service_Line_Id);
	  l_clev_tbl_in(1).display_sequence     := LineDet_Rec.Display_Sequence;
	  l_clev_tbl_in(1).item_description     := LineDet_Rec.Item_Description;
	  l_clev_tbl_in(1).Name		            := LineDet_Rec.Name;
	  l_clev_tbl_in(1).exception_yn	        := tmp_br_Rec.exception_yn;
	  l_clev_tbl_in(1).attribute_category   := tmp_br_Rec.attribute_category;
      l_clev_tbl_in(1).attribute1           := tmp_br_Rec.attribute1;
      l_clev_tbl_in(1).attribute2           := tmp_br_Rec.attribute2;
      l_clev_tbl_in(1).attribute3           := tmp_br_Rec.attribute3;
      l_clev_tbl_in(1).attribute4           := tmp_br_Rec.attribute4;
      l_clev_tbl_in(1).attribute5           := tmp_br_Rec.attribute5;
      l_clev_tbl_in(1).attribute6           := tmp_br_Rec.attribute6;
      l_clev_tbl_in(1).attribute7           := tmp_br_Rec.attribute7;
      l_clev_tbl_in(1).attribute8           := tmp_br_Rec.attribute8;
      l_clev_tbl_in(1).attribute9           := tmp_br_Rec.attribute9;
      l_clev_tbl_in(1).attribute10          := tmp_br_Rec.attribute10;
      l_clev_tbl_in(1).attribute11          := tmp_br_Rec.attribute11;
      l_clev_tbl_in(1).attribute12          := tmp_br_Rec.attribute12;
      l_clev_tbl_in(1).attribute13          := tmp_br_Rec.attribute13;
      l_clev_tbl_in(1).attribute14          := tmp_br_Rec.attribute14;
      l_clev_tbl_in(1).attribute15          := tmp_br_Rec.attribute15;


          okc_contract_pub.create_contract_line (
	                                              p_api_version			=> l_api_version,
  	                                              p_init_msg_list		=> l_init_msg_list,
     	                                          x_return_status	    => l_return_status,
                                                  x_msg_count			=> l_msg_count,
                                                  x_msg_data			=> l_msg_data,
                                                  p_restricted_update   => p_restricted_update,
                                                  p_clev_tbl			=> l_clev_tbl_in,
    	                                          x_clev_tbl			=> l_clev_tbl_out);

          IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            br_cle_id:=l_clev_tbl_out(1).ID;
          END IF;

           FOR brs_rec IN CUR_GET_BILLRATE_SCHEDULES(tmp_br_cle_id)
           LOOP

              INIT_BILL_RATE_LINE(l_bill_rate_tbl_in);

            l_bill_rate_tbl_in(1).cle_id              := br_cle_id;
            l_bill_rate_tbl_in(1).bt_cle_id           := bt_cle_id ;
            l_bill_rate_tbl_in(1).dnz_chr_id          := g_chr_id ;
            l_bill_rate_tbl_in(1).start_hour          := brs_rec.start_hour;
            l_bill_rate_tbl_in(1).start_minute        := brs_rec.start_minute;
            l_bill_rate_tbl_in(1).end_hour            := brs_rec.end_hour;
            l_bill_rate_tbl_in(1).end_minute          := brs_rec.end_minute;
            l_bill_rate_tbl_in(1).monday_flag         := brs_rec.monday_flag;
            l_bill_rate_tbl_in(1).tuesday_flag        := brs_rec.tuesday_flag;
            l_bill_rate_tbl_in(1).wednesday_flag      := brs_rec.wednesday_flag;
            l_bill_rate_tbl_in(1).thursday_flag       := brs_rec.thursday_flag;
            l_bill_rate_tbl_in(1).friday_flag         := brs_rec.friday_flag;
            l_bill_rate_tbl_in(1).saturday_flag       := brs_rec.saturday_flag;
            l_bill_rate_tbl_in(1).sunday_flag         := brs_rec.sunday_flag;
            l_bill_rate_tbl_in(1).object1_id1         := brs_rec.object1_id1;
            l_bill_rate_tbl_in(1).object1_id2         := brs_rec.object1_id2;
            l_bill_rate_tbl_in(1).bill_rate_code      := brs_rec.bill_rate_code;
            l_bill_rate_tbl_in(1).flat_rate           := brs_rec.flat_rate;
            l_bill_rate_tbl_in(1).uom                 := brs_rec.uom;
            l_bill_rate_tbl_in(1).holiday_yn                 := brs_rec.holiday_yn;
            l_bill_rate_tbl_in(1).percent_over_list_price    := brs_rec.percent_over_list_price;
            l_bill_rate_tbl_in(1).program_application_id := brs_rec.program_application_id;
            l_bill_rate_tbl_in(1).program_id   := brs_rec.program_id;
            l_bill_rate_tbl_in(1).program_update_date := brs_rec.program_update_date;
            l_bill_rate_tbl_in(1).request_id := brs_rec.request_id ;
            l_bill_rate_tbl_in(1).created_by             := NULL;
            l_bill_rate_tbl_in(1).creation_date          := NULL;
            l_bill_rate_tbl_in(1).last_updated_by        := NULL;
            l_bill_rate_tbl_in(1).last_update_date       := NULL;
            l_bill_rate_tbl_in(1).last_update_login      := NULL;
            l_bill_rate_tbl_in(1).security_group_id      := brs_rec.security_group_id;
            l_bill_rate_tbl_in(1).object_version_number      := brs_rec.object_version_number;

            OKS_BRS_PVT.INSERT_ROW(p_api_version      => l_api_version,
                        p_init_msg_list    => l_init_msg_list,
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data,
                        p_oks_billrate_schedules_v_tbl => l_bill_rate_tbl_in,
                        x_oks_billrate_schedules_v_tbl => x_bill_rate_tbl_out);

IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.log('Exiting Create_Actual_Coverage', 2);
		okc_debug.Reset_Indentation;
END IF;

                        IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                            RAISE G_EXCEPTION_HALT_VALIDATION;
                       END IF ;
                END LOOP ;
             END IF;
      END LOOP;
    END IF;
  END LOOP;
END LOOP;

END LOOP;

IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.log('Exiting Create_Actual_Coverage', 2);
		okc_debug.Reset_Indentation;
END IF;

  x_actual_coverage_id :=c_cle_id;
  x_return_status := l_return_status ;
  x_msg_count :=l_msg_count;
  x_msg_data:=l_msg_data;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
        x_return_status := l_return_status ;
  /*    x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Create_actual_coverage',
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Create_actual_coverage',
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Create_actual_coverage',
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */

IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.log('Exiting Create_Actual_Coverage'||l_return_Status, 2);
		okc_debug.Reset_Indentation;
END IF;


    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1	        => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
       -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count :=l_msg_count;

IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.log('Exiting Create_Actual_Coverage'||SQLERRM, 2);
		okc_debug.Reset_Indentation;
END IF;

         END create_actual_coverage;

-- ******************************************************************************************
PROCEDURE Undo_Header(
    p_api_version	    IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Header_id    	    IN NUMBER) IS

CURSOR Cur_Line (P_Chr_Id IN NUMBER) IS
SELECT ID FROM OKC_K_Lines_v
WHERE chr_ID=p_chr_Id;

CURSOR Cur_gov (P_chr_Id IN NUMBER) IS
SELECT ID FROM OKC_Governances_v
WHERE dnz_chr_ID=p_chr_Id
And   cle_id Is Null;

  l_chrv_rec         okc_contract_pub.chrv_rec_type;
  l_Line_Id              NUMBER;
  --
  l_api_version		CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	CONSTANT	VARCHAR2(1):= 'T';
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000):=null;
  l_msg_index_out       Number;
  l_api_name            CONSTANT VARCHAR2(30) := 'UNDO Header';
   --
  l_gvev_tbl_in     okc_contract_pub.gvev_tbl_type;
  e_error               Exception;
  n     NUMBER;
  m     NUMBER;
  v_Index   NUMBER;
TYPE line_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_Line_tbl line_tbl_Type;
BEGIN

IF P_Header_Id IS NULL
THEN l_msg_data:= 'Header_id Can not be Null';
     l_return_status := OKC_API.G_RET_STS_ERROR;
    RAISE e_Error;
END IF;
 l_chrv_rec.id 	:= P_Header_Id;

n:=1;
FOR Line_Rec IN Cur_Line(P_Header_Id)
LOOP
l_line_tbl(n):=Line_Rec.Id;
n:=n+1;
END LOOP;

n:=1;
FOR Gov_Rec IN Cur_gov(P_header_Id)
LOOP
l_gvev_tbl_in(n).Id:=Gov_Rec.Id;
n:=n+1;
END LOOP;

IF NOT l_gvev_tbl_In.COUNT=0
THEN
  okc_Contract_pub.delete_governance(
   	p_api_version			=> l_api_version,
  	p_init_msg_list			=> l_init_msg_list,
     	x_return_status			=> l_return_status,
        x_msg_count			=> l_msg_count,
        x_msg_data			=> l_msg_data,
        p_gvev_tbl			=> l_gvev_tbl_in);
  if not (l_return_status = OKC_API.G_RET_STS_SUCCESS) then
	l_msg_data:= 'Error while deleting governance -'||l_msg_data;
      return;
  end if;
END IF;
IF NOT l_line_tbl.COUNT=0
THEN
v_Index:=l_line_tbl.COUNT;
FOR v_Index IN l_line_tbl.FIRST .. l_line_tbl.LAST
LOOP
l_Line_Id:=l_line_tbl(v_Index);
  Undo_Counters( P_KLine_Id     => l_Line_Id,
     	x_return_status			=> l_return_status,
        x_msg_data			=> l_msg_data);
  if not (l_return_status = OKC_API.G_RET_STS_SUCCESS) then
	l_msg_data:= 'Error while deleting Counters -'||l_msg_data;
      return;
  end if;
END LOOP;
END IF;
OKC_DELETE_CONTRACT_PUB.delete_contract(
	p_api_version 		=>l_api_version,
	p_init_msg_list 	=>l_init_msg_list,
	x_return_status	    =>l_return_status,
	x_msg_count		    =>l_msg_count,
	x_msg_data		    =>l_msg_data,
     p_chrv_rec         =>l_chrv_rec);
  if not (l_return_status = OKC_API.G_RET_STS_SUCCESS) then
	l_msg_data:= 'Error while deleting Header -'||l_msg_data;
      return;
  end if;
x_return_status:=l_return_status;
EXCEPTION
    WHEN e_Error THEN
  x_msg_count :=l_msg_count;
x_msg_data:=l_msg_data;
x_return_status:=l_return_status;

      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Undo_Header',
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
x_msg_count :=l_msg_count;
x_msg_data:=l_msg_data;

      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Undo_Header',
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
x_msg_count :=l_msg_count;
x_msg_data:=l_msg_data;
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Undo_Header',
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN

    OKC_API.SET_MESSAGE(
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_Error,
      p_token1	        => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
x_msg_count :=l_msg_count;
END Undo_Header;

PROCEDURE Undo_Line(
    p_api_version     IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Line_Id               IN NUMBER) IS

   l_Cov_cle_Id NUMBER;
   l_Item_id     NUMBER;
   l_contact_Id NUMBER;
   l_RGP_Id     NUMBER;
   l_Rule_Id    NUMBER;
   l_cle_Id     NUMBER;
   v_Index   Binary_Integer;

    G_APP_NAME                              CONSTANT VARCHAR2(3)   :=OKC_API.G_APP_NAME;
    G_REQUIRED_VALUE                        CONSTANT VARCHAR2(200) :=OKC_API.G_REQUIRED_VALUE;
    G_COL_NAME_TOKEN                        CONSTANT VARCHAR2(200) :=OKC_API.G_COL_NAME_TOKEN;
    G_UNEXPECTED_ERROR                      CONSTANT VARCHAR2(200) :='OKS_UNEXP_ERROR';
    G_SQLERRM_TOKEN                         CONSTANT VARCHAR2(200) :='SQLerrm';
    G_SQLCODE_TOKEN                         CONSTANT VARCHAR2(200) :='SQLcode';


 CURSOR line_det_Cur(P_cle_Id IN NUMBER)
 IS SELECT id, start_date, lse_id
 FROM   Okc_K_Lines_b
 WHERE  Id=P_cle_Id;

 CURSOR Child_Cur(P_cle_Id IN NUMBER)
 IS SELECT DNZ_CHR_ID, ID
 FROM   Okc_K_Lines_b
 WHERE  cle_Id=P_cle_Id;

 CURSOR Child_Cur1(P_Parent_Id IN NUMBER)
 IS SELECT ID,DNZ_CHR_ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;

 CURSOR Child_Cur2(P_Parent_Id IN NUMBER)
 IS SELECT ID,DNZ_CHR_ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;
 CURSOR Child_Cur3(P_Parent_Id IN NUMBER)
 IS SELECT ID,DNZ_CHR_ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;
 CURSOR Child_Cur4(P_Parent_Id IN NUMBER)
 IS SELECT ID,DNZ_CHR_ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;
 CURSOR Child_Cur5(P_Parent_Id IN NUMBER)
 IS SELECT ID,DNZ_CHR_ID
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
 SELECT pr.ID FROM OKC_K_PARTY_ROLES_B pr
   ,OKC_K_LINES_V lv
 WHERE  pr.cle_Id=P_cle_Id
 And    pr.cle_id = lv.id
 And    pr.dnz_chr_id = lv.dnz_chr_id;

 CURSOR Contact_Cur(P_cpl_Id IN NUMBER) IS
 SELECT ID FROM OKC_CONTACTS
 WHERE  cpl_Id=P_cpl_Id;

/*
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
*/

 CURSOR  Relobj_Cur(P_Cle_Id IN NUMBER) IS
  SELECT Id FROM OKC_K_REL_OBJS_V
  WHERE  cle_Id = P_cle_Id;

 CURSOR  OrderDetails_Cur(P_CHR_ID IN NUMBER,P_Cle_Id IN NUMBER) IS
  SELECT Id FROM OKS_K_ORDER_DETAILS_V
  WHERE chr_id = p_chr_id
  AND   cle_Id = P_cle_Id;

 CURSOR  SalesCredits_Cur(P_Cle_Id IN NUMBER) IS
  SELECT Id FROM OKS_K_SALES_CREDITS_V
  WHERE  cle_Id = P_cle_Id;

 CURSOR  OrderContacts_Cur(P_Cod_Id IN NUMBER) IS
  SELECT Id FROM OKS_K_Order_Contacts_V
  WHERE  cod_Id = P_cod_Id;

--03/16/04 chkrishn removed for rules rearchitecture
/*    CURSOR CUR_GET_SCH(p_cov_id IN NUMBER) IS
    SELECT ID FROM OKS_PM_SCHEDULES
    WHERE CLE_ID = p_cov_id;

   l_pm_schedules_v_tbl  OKS_PMS_PVT.oks_pm_schedules_v_tbl_type ;
   l_sch_index NUMBER := 0;*/

   CURSOR CUR_GET_BRS_ID(p_service_line_id IN NUMBER) IS
    SELECT  BRS.ID BRS_LINE_ID
    FROM    OKC_K_LINES_B LINES1,
            OKC_K_LINES_B LINES2,
            OKC_K_LINES_B LINES3,
            OKC_K_LINES_B LINES4,
            OKS_BILLRATE_SCHEDULES BRS
    WHERE   LINES1.CLE_ID = p_service_line_id
    AND     lines2.cle_id = lines1.id
    AND     lines3.cle_id = lines2.id
    AND     lines4.cle_id = lines3.id
    AND     lines1.lse_id in (2,15,20)
    AND     lines2.lse_id in (3,16,21)
    AND     lines3.lse_id in (5,23,59)
    AND     lines4.lse_id in (6,24,60)
    AND     brs.cle_id = lines4.id
    AND     brs.dnz_chr_id = lines1.dnz_chr_id ;

--05/17/04 chkrishn Added for deleting notes
-- Commented by Jvorugan
-- Bugno:4535339.
-- From R12, notes and PM will be deleted when the serviceline id is deleted and not with the coverage.
/*
    CURSOR Cur_Service_line(p_cle_id IN NUMBER) IS
    SELECT cle_id
    from okc_k_lines_b
    where id=p_cle_id
    and lse_id in (2,15,20);

    l_service_line_id NUMBER;

    CURSOR Cur_Get_notes(p_source_object_id IN Number) IS
      SELECT jtf_note_id
      FROM JTF_NOTES_VL
      WHERE source_object_id = p_source_object_id
      AND   source_object_code = 'OKS_COV_NOTE';
 */
-- End of Bug:4535339 by Jvorugan

    CURSOR k_line_cur(p_ID IN NUMBER,p_DNZ_CHR_ID IN NUMBER) IS
        SELECT ID,DNZ_CHR_ID
        FROM    oks_k_lines_b
        WHERE   cle_id = p_Id
        AND     dnz_chr_id = p_dnz_chr_id;

    CURSOR  Time_Zone_Csr (p_ID IN NUMBER,p_DNZ_CHR_ID IN NUMBER) IS
            SELECT  ID,CLE_ID,DNZ_CHR_ID
            FROM    oks_coverage_timezones
            WHERE   cle_id  =   p_iD
            AND     dnz_chr_id =p_dnz_chr_id;


    CURSOR Cov_Time_Csr (p_ID IN NUMBER,p_DNZ_CHR_ID IN NUMBER) IS
            SELECT ID,DNZ_CHR_ID
            FROM    OKS_COVERAGE_TIMES
            WHERE   COV_TZE_LINE_ID = p_id
            AND     dnz_chr_id =p_dnz_chr_id;

    CURSOR Action_type_Csr (p_ID IN NUMBER,p_DNZ_CHR_ID IN NUMBER) IS
            SELECT  ID,DNZ_CHR_ID
            FROM    OKS_ACTION_TIME_TYPES
            WHERE   cle_id  =   p_iD
            AND     dnz_chr_id =p_dnz_chr_id;

    CURSOR Action_times_Csr (p_ID IN NUMBER,p_DNZ_CHR_ID IN NUMBER) IS
            SELECT  ID,DNZ_CHR_ID
            FROM    OKS_ACTION_TIMES
            WHERE   COV_ACTION_TYPE_ID  = p_id
            AND     dnz_chr_id =p_dnz_chr_id;

    CURSOR  Bill_Rate_Csr (p_ID IN NUMBER,p_DNZ_CHR_ID IN NUMBER) IS
            SELECT  ID,DNZ_CHR_ID
            FROM    OKS_BILLRATE_SCHEDULES
            WHERE   CLE_ID  = p_id
            AND     dnz_chr_id =p_dnz_chr_id;

l_brs_tbl_in   OKS_BRS_PVT.OksBillrateSchedulesVTblType;

l_brs_id     NUMBER;
l_line_id    NUMBER;



  n NUMBER:=0;
  l_cov_id  NUMBER;
  line_det_rec          line_det_Cur%ROWTYPE;
  line_det_rec2          line_det_Cur%ROWTYPE;
  l_child_cur_rec       Child_cur%rowtype;
  l_clev_tbl_in         okc_contract_pub.clev_tbl_type;
  l_clev_tbl_tmp        okc_contract_pub.clev_tbl_type;

  l_cimv_tbl_in         okc_Contract_Item_Pub.cimv_tbl_TYPE;
  l_ctcv_tbl_in  okc_contract_party_pub.ctcv_tbl_type;
  l_cplv_tbl_in  okc_contract_party_pub.cplv_tbl_type;
  l_crjv_tbl_in  okc_k_rel_objs_pub.crjv_tbl_type;
  l_cocv_tbl_in         oks_Order_Contacts_Pub.cocv_tbl_TYPE;
  l_codv_tbl_in  oks_Order_Details_pub.codv_tbl_type;
  l_scrv_tbl_in  oks_Sales_Credit_pub.scrv_tbl_type;

  l_klev_tbl_in     oks_kln_pvt.klnv_tbl_type;
  l_tzev_tbl_in     OKS_CTZ_PVT.OksCoverageTimezonesVTblType;
  l_cvtv_tbl_in     OKS_CVT_PVT.oks_coverage_times_v_tbl_type;
  l_actv_tbl_in     OKS_ACT_PVT.OksActionTimeTypesVTblType;
  l_acmv_tbl_in     OKS_ACM_PVT.oks_action_times_v_tbl_type;
  l_brsv_tbl_in     OKS_BRS_PVT.OksBillrateSchedulesVTblType;


  l_api_version  CONSTANT NUMBER      := 1.0;
  l_init_msg_list CONSTANT VARCHAR2(1) := 'T';
  l_return_status VARCHAR2(1);
  l_msg_count  NUMBER;
  l_msg_data  VARCHAR2(2000):=null;
  l_msg_index_out       Number;
  l_api_name            CONSTANT VARCHAR2(30) := 'Undo Line';
  --l_catv_tbl_in  okc_k_article_pub.catv_tbl_type;
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
  c_cocv NUMBER:=1;
  c_codv NUMBER:=1;
  c_scrv NUMBER:=1;

  k_clev NUMBER:=1;
  l_tzev NUMBER:=1;
  l_cvtv NUMBER:=1;
  l_actv NUMBER:=1;
  l_acmv NUMBER:=1;
  l_brsv NUMBER:=1;
  l_id   NUMBER;
  l_pm_cle_id  NUMBER := NULL;

  l_dummy_terminate_date  DATE;
  l_line_type             NUMBER;

 FUNCTION Bp_Check(P_rgp_Id IN NUMBER)
 RETURN BOOLEAN  IS
   CURSOR GetLse_Cur IS
   SELECT kl.lse_ID
   from okc_k_Lines_v kl,
        okc_rule_groups_v rg
   where kl.id = rg.cle_id
   and   rg.id = P_rgp_Id;


 BEGIN

   OPEN GetLse_Cur;
   FETCH GetLse_Cur INTO l_Lse_Id;
    IF NOT GetLse_Cur%FOUND
    THEN l_Lse_Id:=NULL;
    END IF;
   CLOSE GetLse_Cur;
   IF l_lse_Id IN (3,16,21)
    THEN RETURN TRUE;
   ELSE RETURN FALSE;
   END IF;
 END Bp_Check;


BEGIN

IF (G_DEBUG_ENABLED = 'Y') THEN
         okc_debug.Set_Indentation('Undo_Line');
         okc_debug.log('Entered Undo_Line', 2);
END IF;



-- Commented by Jvorugan for Coverage Rearchitecture.
-- From R12, notes and PM will be deleted when the serviceline id is deleted and not with the coverage.
-- Bugno:4535339
/*    OPEN line_det_cur(p_line_id);
        FETCH line_det_cur INTO line_det_rec2;
            IF (line_det_rec2.lse_id = 2) OR (line_det_rec2.lse_id = 14)
            THEN
                l_pm_cle_id := line_det_rec2.ID;
            END IF;
    CLOSE line_det_cur;
 */
-- End of Bug:4535339 by Jvorugan

x_return_status:=OKC_API.G_Ret_Sts_Success;

OKS_COVERAGES_PVT.Validate_Line_id(p_line_id,l_return_status);
IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
-- IF NOT l_Return_Status ='S' THEN
     RETURN;
END IF;

l_clev_tbl_tmp(c_clev).ID:=P_Line_Id;


 l_line_id := p_line_id ;

--05/17/2004 chkrishn added for deleting notes
-- Commented by Jvorugan for Coverage Rearchitecture.
-- From R12, notes and PM will be deleted when the serviceline id is deleted and not with the coverage.
-- Bugno:4535339
/*
 OPEN Cur_Service_line(p_line_id);
 FETCH Cur_Service_line INTO l_service_line_id;
 CLOSE  Cur_Service_line;

 FOR note_rec IN Cur_Get_notes(l_service_line_id)
LOOP
JTF_NOTES_PUB.Secure_Delete_note
( p_api_version           => l_api_version,
  p_init_msg_list         =>  l_init_msg_list,   --         VARCHAR2 DEFAULT 'F'
  p_commit                => 'F',  --IN            VARCHAR2 DEFAULT 'F'
  p_validation_level     => 100, --IN            NUMBER   DEFAULT 100
  x_return_status        => l_return_status , -- OUT NOCOPY VARCHAR2
  x_msg_count            => l_msg_count, -- OUT NOCOPY NUMBER
  x_msg_data             => l_msg_data , --  OUT NOCOPY VARCHAR2
  p_jtf_note_id          => note_rec.jtf_note_id,
  p_use_AOL_security     => 'F' --IN            VARCHAR2 DEFAULT 'T'
);
IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
   RAISE e_Error;
END IF;
END LOOP;

*/

-- End of Bug:4535339 by Jvorugan

IF (G_DEBUG_ENABLED = 'Y') THEN
         okc_debug.log('Before BRS_REC', 2);
END IF;


FOR BRS_REC IN CUR_GET_BRS_ID(l_line_id) LOOP

OKS_COVERAGES_PVT.INIT_BILL_RATE_LINE(l_brs_tbl_in);
l_brs_id:= brs_rec.brs_line_id ;
l_brs_tbl_in(1).id := l_brs_id ;





OKS_BRS_PVT.delete_row(
    p_api_version                   => l_api_version,
    p_init_msg_list                 => l_init_msg_list,
    x_return_status                 => l_return_status,
    x_msg_count                     => l_msg_count,
    x_msg_data                      => l_msg_data,
    p_oks_billrate_schedules_v_tbl  => l_brs_tbl_in);

    if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)   then
        RAISE e_Error;
    end if;


END LOOP ;

IF (G_DEBUG_ENABLED = 'Y') THEN
         okc_debug.log('After OKS_BRS_PVT delete_row', 2);
END IF;

OPEN Child_Cur(P_line_id);

FETCH Child_Cur into l_child_cur_rec;
l_clev_tbl_tmp(c_clev).DNZ_CHR_ID := l_child_cur_rec.dnz_chr_id;
l_cov_id:= l_child_cur_rec.id ;

CLOSE Child_cur;

c_clev:=c_clev+1;
    FOR Child_Rec1 IN Child_Cur1(P_Line_Id) LOOP
        l_clev_tbl_tmp(c_clev).ID:=Child_Rec1.ID;
        l_clev_tbl_tmp(c_clev).DNZ_CHR_ID:=Child_Rec1.DNZ_CHR_ID;
        c_clev:=c_clev+1;
    FOR Child_Rec2 IN Child_Cur2(Child_Rec1.Id)  LOOP
         l_clev_tbl_tmp(c_clev).ID:=Child_Rec2.Id;
         l_clev_tbl_tmp(c_clev).DNZ_CHR_ID:=Child_Rec2.DNZ_CHR_ID;
         c_clev:=c_clev+1;
    FOR Child_Rec3 IN Child_Cur3(Child_Rec2.Id) LOOP
        l_clev_tbl_tmp(c_clev).ID:=Child_Rec3.Id;
        l_clev_tbl_tmp(c_clev).DNZ_CHR_ID:=Child_Rec3.DNZ_CHR_ID;
        c_clev:=c_clev+1;
    FOR Child_Rec4 IN Child_Cur4(Child_Rec3.Id)  LOOP
       l_clev_tbl_tmp(c_clev).ID:=Child_Rec4.Id;
       l_clev_tbl_tmp(c_clev).DNZ_CHR_ID:=Child_Rec4.DNZ_CHR_ID;
              c_clev:=c_clev+1;
    FOR Child_Rec5 IN Child_Cur5(Child_Rec4.Id)      LOOP
                l_clev_tbl_tmp(c_clev).ID:=Child_Rec5.Id;
                l_clev_tbl_tmp(c_clev).DNZ_CHR_ID:=Child_Rec5.DNZ_CHR_ID;
                c_clev:=c_clev+1;
    END LOOP;
    END LOOP;
    END LOOP;
    END LOOP;
END LOOP;
c_clev:=1;

FOR v_Index IN REVERSE l_clev_tbl_tmp.FIRST .. l_clev_tbl_tmp.LAST LOOP

    l_clev_tbl_in(c_clev).ID            :=  l_clev_tbl_tmp(v_Index).ID;
    l_clev_tbl_in(c_clev).DNZ_CHR_ID    :=  l_clev_tbl_tmp(v_Index).DNZ_CHR_ID;
    c_clev:=c_Clev+1;
END LOOP;

--==============================================================================

FOR k_index IN l_clev_tbl_in.FIRST .. l_clev_tbl_in.LAST LOOP

    FOR k_line_rec in k_line_cur(l_clev_tbl_in(k_index).ID,l_clev_tbl_in(k_index).DNZ_CHR_ID)
LOOP

        l_klev_tbl_in(k_clev).ID:= k_line_rec.ID;
        l_klev_tbl_in(k_clev).DNZ_CHR_ID:= k_line_rec.DNZ_CHR_ID;
        k_clev := k_clev + 1;

    END LOOP;


END LOOP;

FOR TZ_index IN l_clev_tbl_in.FIRST .. l_clev_tbl_in.LAST LOOP

    FOR Time_Zone_Rec IN Time_Zone_Csr
(l_clev_tbl_in(TZ_index).ID,l_clev_tbl_in(TZ_index).DNZ_CHR_ID)  LOOP

        l_tzev_tbl_in(l_tzev).ID            :=  Time_Zone_Rec.ID;
        l_tzev_tbl_in(l_tzev).DNZ_CHR_ID    :=  Time_Zone_Rec.DNZ_CHR_ID;

        l_tzev  := l_tzev + 1;
    END LOOP;
END LOOP;


IF l_tzev_tbl_in.COUNT > 0 THEN
    FOR TI_index IN l_tzev_tbl_in.FIRST .. l_tzev_tbl_in.LAST LOOP

        FOR Cov_Time_Rec IN Cov_Time_Csr(l_tzev_tbl_in(TI_index).Id,l_tzev_tbl_in(TI_index).DNZ_CHR_Id) LOOP
            l_cvtv_tbl_in(l_cvtv).ID            :=  Cov_Time_Rec.ID;
            l_cvtv_tbl_in(l_cvtv).DNZ_CHR_ID    :=  Cov_Time_Rec.DNZ_CHR_ID;
            l_cvtv := l_cvtv + 1;
        END LOOP;

    END LOOP;


END IF;



FOR Ac_index IN l_clev_tbl_in.FIRST .. l_clev_tbl_in.LAST LOOP

    FOR Action_type_Rec IN Action_type_Csr(l_clev_tbl_in(Ac_index).ID,l_clev_tbl_in(Ac_index).DNZ_CHR_ID)  LOOP

        l_actv_tbl_in(l_actv).ID            :=  Action_type_Rec.ID;
        l_actv_tbl_in(l_actv).DNZ_CHR_ID    :=  Action_type_Rec.DNZ_CHR_ID;

        l_actv   := l_actv  + 1;
    END LOOP;
END LOOP;

IF l_actv_tbl_in.COUNT > 0 THEN
    FOR At_index IN l_actv_tbl_in.FIRST .. l_actv_tbl_in.LAST LOOP
        FOR Action_times_Rec IN Action_times_Csr(l_actv_tbl_in(At_index).ID,l_actv_tbl_in(At_index).DNZ_CHR_ID)  LOOP

            l_acmv_tbl_in(l_acmv).ID            :=  Action_times_Rec.ID;
            l_acmv_tbl_in(l_acmv).DNZ_CHR_ID    :=  Action_times_Rec.DNZ_CHR_ID;

            l_acmv   := l_acmv  + 1;

        END LOOP;

    END LOOP;

END IF;



IF l_clev_tbl_in.COUNT > 0 THEN

    FOR Br_index IN l_clev_tbl_in.FIRST .. l_clev_tbl_in.LAST LOOP


        FOR Bill_Rate_Rec IN Bill_Rate_Csr
(l_clev_tbl_in(Br_index).Id,l_clev_tbl_in(Br_index).DNZ_CHR_Id) LOOP

      l_brsv_tbl_in(l_brsv).ID    :=  Bill_Rate_Rec.ID;
            l_brsv_tbl_in(l_brsv).DNZ_CHR_ID    :=
Bill_Rate_Rec.DNZ_CHR_ID;
            l_brsv := l_brsv + 1;

        END LOOP;

    END LOOP;


END IF;

-- Commented by Jvorugan for Coverage Rearchitecture.
-- From R12, notes and PM will be deleted when the serviceline id is deleted and not with the coverage.
-- Bugno:4535339

/*

IF (G_DEBUG_ENABLED = 'Y') THEN
        okc_debug.log('BEFORE OKS_PM_PROGRAMS_PVT UNDO_PM_LINE', 2);

END IF;




IF l_pm_cle_id IS NOT NULL THEN


        OKS_PM_PROGRAMS_PVT.UNDO_PM_LINE(
        p_api_version                   =>l_api_version,
        p_init_msg_list                 =>l_init_msg_list,
        x_return_status                 =>l_return_status,
        x_msg_count                     =>l_msg_count,
        x_msg_data                      =>l_msg_data,
        p_cle_id                        =>l_pm_cle_id);

--chkrishn 03/17/04 exception handling
    IF  NOT (l_return_status = OKC_API.G_RET_STS_SUCCESS)   then
      return;
    END IF;


END IF;

*/
-- End of Bug:4535339 by Jvorugan

IF l_brsv_tbl_in.COUNT > 0 THEN

        OKS_BRS_PVT.delete_row(
                p_api_version                   => l_api_version,
                p_init_msg_list                 => l_init_msg_list,
                x_return_status                 => l_return_status,
                x_msg_count                     => l_msg_count,
                x_msg_data                      => l_msg_data,
                p_oks_billrate_schedules_v_tbl  => l_brsv_tbl_in);



    IF  NOT (l_return_status = OKC_API.G_RET_STS_SUCCESS)   then
      return;
    END IF;

END IF;


IF l_klev_tbl_in.COUNT > 0 THEN

OKS_KLN_PVT.delete_row(
                    p_api_version   => l_api_version,
                    p_init_msg_list  => l_init_msg_list,
                    x_return_status  => l_return_status,
                    x_msg_count   => l_msg_count,
                    x_msg_data   => l_msg_data,
                    p_klnv_tbl      =>  l_klev_tbl_in);


    IF  NOT (l_return_status = OKC_API.G_RET_STS_SUCCESS)   then
      return;
    END IF;

END IF;

IF l_cvtv_tbl_in.COUNT > 0 THEN

    OKS_CVT_PVT.delete_row(
                p_api_version                   =>l_api_version,
                p_init_msg_list                 =>l_init_msg_list,
                x_return_status                 =>l_return_status,
                x_msg_count                     => l_msg_count,
                x_msg_data                      => l_msg_data,
                p_oks_coverage_times_v_tbl      =>l_cvtv_tbl_in);



    IF  NOT (l_return_status = OKC_API.G_RET_STS_SUCCESS)   then
      return;
    END IF;
END IF;

IF l_tzev_tbl_in.COUNT > 0 THEN
    OKS_CTZ_PVT.delete_row(
                p_api_version                   =>  l_api_version,
                p_init_msg_list                 =>  l_init_msg_list,
                x_return_status                 =>  l_return_status,
                x_msg_count                     =>  l_msg_count,
                x_msg_data                      =>  l_msg_data,
                p_oks_coverage_timezones_v_tbl  =>  l_tzev_tbl_in);


    IF  NOT (l_return_status = OKC_API.G_RET_STS_SUCCESS)   then
      return;
    END IF;

END IF;

IF (G_DEBUG_ENABLED = 'Y') THEN
        okc_debug.log('AFTER OKS_CTZ_PVT  delete_row', 2);

END IF;


IF l_acmv_tbl_in.COUNT > 0 THEN

        OKS_ACM_PVT.delete_row(
        p_api_version                   =>  l_api_version,
        p_init_msg_list                 =>  l_init_msg_list,
        x_return_status                 =>  l_return_status,
        x_msg_count                     =>  l_msg_count,
        x_msg_data                      =>  l_msg_data,
        p_oks_action_times_v_tbl        =>  l_acmv_tbl_in);


    IF  NOT (l_return_status = OKC_API.G_RET_STS_SUCCESS)   then
      return;
    END IF;
END IF;


IF (G_DEBUG_ENABLED = 'Y') THEN
        okc_debug.log('AFTER OKS_ACM_PVT  delete_row', 2);

END IF;

IF l_actv_tbl_in.COUNT > 0 THEN

        OKS_ACT_PVT.delete_row(
                p_api_version                   =>  l_api_version,
                p_init_msg_list                 =>  l_init_msg_list,
                x_return_status                 =>  l_return_status,
                x_msg_count                     =>  l_msg_count,
                x_msg_data                      =>  l_msg_data,
                p_oks_action_time_types_v_tbl   =>  l_actv_tbl_in);



    IF  NOT (l_return_status = OKC_API.G_RET_STS_SUCCESS)   then
      return;
    END IF;

IF (G_DEBUG_ENABLED = 'Y') THEN
        okc_debug.log('AFTER OKS_ACT_PVT  delete_row', 2);

END IF;

END IF;
--=============================================================================

-- Get Relational Objects Linked to the lines
FOR v_Index IN l_clev_tbl_in.FIRST .. l_clev_tbl_in.LAST
LOOP
  FOR RelObj_REC IN RelObj_Cur(l_clev_tbl_in(v_Index).ID)
  LOOP
      l_crjv_tbl_in(c_crjv).ID:= RelObj_Rec.Id;
      c_crjv:=c_crjv+1;
  END LOOP;

  FOR OrderDetails_REC IN
OrderDetails_Cur(l_clev_tbl_in(v_Index).DNZ_CHR_ID,l_clev_tbl_in(v_Index).ID)

  LOOP
      l_codv_tbl_in(c_codv).ID:= OrderDetails_Rec.Id;
      FOR OrderContacts_REC IN
OrderContacts_Cur(l_codv_tbl_in(c_codv).ID)
      LOOP
          l_cocv_tbl_in(c_cocv).ID:= OrderContacts_Rec.Id;
          c_cocv:=c_cocv+1;
      END LOOP;
      c_codv:=c_codv+1;
  END LOOP;
  FOR SalesCredits_REC IN SalesCredits_Cur(l_clev_tbl_in(v_Index).ID)
  LOOP
      l_scrv_tbl_in(c_scrv).ID:= SalesCredits_Rec.Id;
      c_scrv:=c_scrv+1;
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

IF NOT l_cocv_tbl_in.COUNT=0 THEN

OKS_ORDER_CONTACTS_PUB.Delete_Order_Contact(
      p_api_version   => l_api_version,
     p_init_msg_list  => l_init_msg_list,
        x_return_status  => l_return_status,
          x_msg_count   => l_msg_count,
          x_msg_data   => l_msg_data,
          p_cocv_tbl   => l_cocv_tbl_in);

   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      return;
   end if;
END IF;


IF (G_DEBUG_ENABLED = 'Y') THEN
        okc_debug.log('AFTER OKS_ORDER_CONTACTS_PUB  delete_order_contract', 2);

END IF;


IF NOT l_codv_tbl_in.COUNT=0
THEN

OKS_ORDER_DETAILS_PUB.Delete_Order_Detail(
      p_api_version   => l_api_version,
     p_init_msg_list  => l_init_msg_list,
        x_return_status  => l_return_status,
          x_msg_count   => l_msg_count,
          x_msg_data   => l_msg_data,
          p_codv_tbl   => l_codv_tbl_in);

   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      return;
   end if;
END IF;


IF (G_DEBUG_ENABLED = 'Y') THEN
        okc_debug.log('AFTER OKS_ORDER_DETAILS_PUB  delete_order_detail', 2);

END IF;


IF NOT l_scrv_tbl_in.COUNT=0
THEN

OKS_SALES_CREDIT_PUB.Delete_Sales_Credit(
      p_api_version   => l_api_version,
     p_init_msg_list  => l_init_msg_list,
        x_return_status  => l_return_status,
          x_msg_count   => l_msg_count,
          x_msg_data   => l_msg_data,
          p_scrv_tbl   => l_scrv_tbl_in);

   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      return;
   end if;
END IF;



IF (G_DEBUG_ENABLED = 'Y') THEN
        okc_debug.log('AFTER OKS_SALES_CREDIT_PUB Delete_Sales_Credit', 2);

END IF;


IF NOT l_crjv_tbl_in.COUNT=0
THEN

OKC_K_REL_OBJS_PUB.Delete_Row(
      p_api_version   => l_api_version,
     p_init_msg_list  => l_init_msg_list,
        x_return_status  => l_return_status,
          x_msg_count   => l_msg_count,
          x_msg_data   => l_msg_data,
          p_crjv_tbl   => l_crjv_tbl_in);

   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      return;
   end if;
END IF;

IF (G_DEBUG_ENABLED = 'Y') THEN
        okc_debug.log('AFTER OKC_K_REL_OBJS_PUB Delete_Row', 2);

END IF;



IF NOT l_ctcv_tbl_in.COUNT=0
THEN
OKC_CONTRACT_PARTY_PUB.Delete_Contact(
      p_api_version   => l_api_version,
     p_init_msg_list  => l_init_msg_list,
        x_return_status  => l_return_status,
          x_msg_count   => l_msg_count,
          x_msg_data   => l_msg_data,
          p_ctcv_tbl   => l_ctcv_tbl_in);

   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      return;
   end if;
END IF;
IF NOT l_cplv_tbl_in.COUNT=0
THEN
OKC_CONTRACT_PARTY_PUB.Delete_k_Party_Role(
      p_api_version   => l_api_version,
     p_init_msg_list  => l_init_msg_list,
        x_return_status  => l_return_status,
          x_msg_count   => l_msg_count,
          x_msg_data   => l_msg_data,
          p_cplv_tbl   => l_cplv_tbl_in);

   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      return;
   end if;
END IF;


--IF NOT l_rulv_tbl_in.COUNT=0 THEN
  -------delete level elements before deleting rules.

  OPEN line_det_cur(p_line_id);
  FETCH line_det_cur INTO line_det_rec;

  l_dummy_terminate_date := line_det_rec.start_date - 1;

  IF line_det_rec.lse_id = 1 OR line_det_rec.lse_id = 12 OR
line_det_rec.lse_id = 14
    OR line_det_rec.lse_id = 19 THEN

    l_line_type := 1;             --1 for TOP line
  ELSE

    l_line_type := 2;             --2 for covered level
  END IF;

  CLOSE line_det_cur;

  OKS_BILL_UTIL_PUB.pre_del_level_elements(
                            p_api_version       => l_api_version,
                            p_terminated_date   =>
l_dummy_terminate_date,
                            p_id                => P_line_id ,
                            p_flag              => l_line_type,
                            x_return_status     => l_return_status);

  IF NOT nvl(l_return_status,'S') = OKC_API.G_RET_STS_SUCCESS THEN
     x_return_status := OKC_API.G_RET_STS_ERROR;

OKC_API.Set_Message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ERROR
IN DELETING LEVEL_ELEMENTS');
     RETURN;
  END IF;


--03/16/04 chkrishn removed for rules rearchitecture. Replaced with call to oks_pm_programs_pvt.undo_pm_line
  -- call the schedule deletion API

/*
FOR C1 IN CUR_GET_SCH(l_cov_id)
 LOOP
  l_sch_index:= l_sch_index + 1 ;
  l_pm_schedules_v_tbl(l_sch_index).id:= C1.ID;
  END LOOP ;

IF l_pm_schedules_v_tbl.count  <> 0 then
  OKS_PMS_PVT.delete_row(
    p_api_version   => l_api_version,
    p_init_msg_list  => l_init_msg_list,
    x_return_status  => l_return_status,
    x_msg_count   => l_msg_count,
    x_msg_data   => l_msg_data,
    p_oks_pm_schedules_v_tbl    =>   l_pm_schedules_v_tbl);
END IF ;

  IF NOT nvl(l_return_status,'S') = OKC_API.G_RET_STS_SUCCESS THEN
     x_return_status := OKC_API.G_RET_STS_ERROR;

OKC_API.Set_Message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ERROR
IN DELETING PM_SCHEDULES');
     RETURN;
  END IF;
*/

IF NOT l_cimv_tbl_in.COUNT=0
THEN
  okc_contract_ITEM_pub.delete_Contract_ITEM (
      p_api_version   => l_api_version,
     p_init_msg_list  => l_init_msg_list,
        x_return_status  => l_return_status,
          x_msg_count   => l_msg_count,
          x_msg_data   => l_msg_data,
          p_cimv_tbl   => l_cimv_tbl_in);

IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
  RAISE e_Error;
END IF;
END IF;


IF (G_DEBUG_ENABLED = 'Y') THEN
        okc_debug.log('AFTER okc_contract_ITEM_pub.delete_Contract_ITEM', 2);

END IF;

IF NOT l_clev_tbl_in.COUNT=0
THEN
  okc_contract_pub.delete_contract_line (
      p_api_version   => l_api_version,
     p_init_msg_list  => l_init_msg_list,
        x_return_status  => l_return_status,
          x_msg_count   => l_msg_count,
          x_msg_data   => l_msg_data,
          p_clev_tbl   => l_clev_tbl_in);


            IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                RAISE e_Error;
            END IF;
END IF;


Oks_Coverages_Pvt.UNDO_EVENTS (P_line_Id ,
   l_Return_Status ,
   l_msg_data )  ;
   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)   then
      RAISE e_Error;
   end if;

Oks_Coverages_Pvt.UNDO_Counters (P_line_Id ,
   l_Return_Status ,
   l_msg_data )  ;
   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)   then
      RAISE e_Error;
   end if;
x_Return_status:=l_Return_status;

IF (G_DEBUG_ENABLED = 'Y') THEN
        okc_debug.log('End of  Undo Line', 2);
        okc_debug.Reset_Indentation;
END IF;



EXCEPTION
    WHEN e_Error THEN

       IF (G_DEBUG_ENABLED = 'Y') THEN
           okc_debug.log('Exception of  Undo Line  e_Error'||SQLERRM, 2);
           okc_debug.Reset_Indentation;
       END IF;


    x_msg_count :=l_msg_count;
x_msg_data:=l_msg_data;
x_Return_status:=l_Return_status;

    WHEN OTHERS THEN

       IF (G_DEBUG_ENABLED = 'Y') THEN
           okc_debug.log('Exception of  Undo Line  when_others'||SQLERRM, 2);
           okc_debug.Reset_Indentation;
       END IF;

x_msg_count :=l_msg_count;
    OKC_API.SET_MESSAGE(
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1         => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Undo_Line;



-- *************************************************************************************************
PROCEDURE UNDO_EVENTS	(P_Kline_Id 	IN 	NUMBER,
			x_Return_Status	OUT NOCOPY	VARCHAR2,
			x_msg_data	OUT NOCOPY	VARCHAR2)  IS
l_cnhv_tbl		okc_conditions_pub.cnhv_tbl_type;
l_cnlv_tbl		okc_conditions_pub.cnlv_tbl_type;
l_coev_tbl		okc_conditions_pub.coev_tbl_type;
l_aavv_tbl		okc_conditions_pub.aavv_tbl_type;
l_ocev_tbl		okc_outcome_pub.ocev_tbl_type;
l_oatv_tbl		okc_outcome_pub.oatv_tbl_type;
c_Cnhv		Number:=1;
c_Cnlv		Number:=1;
c_aavv		Number:=1;
c_Ocev		Number:=1;
c_Oatv		Number:=1;
c_Coev		Number:=1;
  l_api_version		CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	CONSTANT	VARCHAR2(1):= 'T';
  l_return_status	VARCHAR2(3);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000):=null;
  l_msg_index_out       Number;
  l_api_name            CONSTANT VARCHAR2(30) := 'UNDO EVENT';

CURSOR Cur_Cnh(P_KLine_Id IN NUMBER) IS
SELECT id FROM OKC_Condition_Headers_v where Object_Id=P_KLine_Id
				             and JTOT_Object_Code='OKC_K_LINE';
CURSOR Cur_Coe (P_Cnh_Id IN NUMBER) IS
SELECT id FROM  OKC_Condition_Occurs_v where Cnh_Id=P_Cnh_Id;
CURSOR Cur_aav (P_Coe_Id IN NUMBER) IS
SELECT aae_Id,coe_id FROM Okc_Action_att_vals_v  WHERE coe_id=P_Coe_Id;
CURSOR Cur_Cnl (P_Cnh_Id IN NUMBER) IS
SELECT id FROM OKC_Condition_Lines_v WHERE Cnh_Id = P_Cnh_Id;
CURSOR Cur_oce (P_Cnh_Id IN NUMBER) IS
SELECT id FROM OKC_OUTCOMES_V WHERE cnh_Id=P_Cnh_Id;
CURSOR Cur_oat (P_oce_Id IN NUMBER) IS
SELECT id FROM okc_outcome_arguments_v WHERE oce_id=P_Oce_Id;
BEGIN
x_Return_Status := OKC_API.G_RET_STS_SUCCESS;
FOR Cnh_Rec IN Cur_Cnh(P_KLine_Id)
LOOP
	l_cnhv_tbl(c_Cnhv).Id:= Cnh_Rec.Id;
	c_Cnhv		 := c_Cnhv+1;
	FOR Coe_Rec IN Cur_Coe(l_cnhv_tbl(c_Cnhv-1).Id)
	LOOP
		l_coev_tbl(c_Coev).Id:= Coe_Rec.Id;
		c_Coev:=c_Coev+1;
		FOR Aav_Rec IN Cur_Aav(l_coev_tbl(c_Coev-1).Id)
		LOOP
			l_aavv_tbl(c_Aavv).aae_Id:=Aav_Rec.Aae_Id;
			l_aavv_tbl(c_Aavv).coe_Id:=Aav_Rec.coe_Id;
			c_Aavv:=c_Aavv+1;
		END LOOP;
	END LOOP;
	FOR Cnl_Rec IN Cur_Cnl(l_cnhv_tbl(c_Cnhv-1).Id)
	LOOP
		l_cnlv_tbl(c_Cnlv).Id:=Cnl_Rec.Id;
		c_Cnlv:=c_Cnlv+1;
	END LOOP;
	FOR Oce_Rec IN Cur_Oce((l_cnhv_tbl(c_Cnhv-1).Id))
	LOOP
		l_ocev_tbl(c_Ocev).Id:=Oce_Rec.Id;
		c_Ocev:=c_Ocev+1;
		FOR Oat_Rec IN Cur_Oat(l_ocev_tbl(c_Ocev-1).Id)
		LOOP
			l_oatv_tbl(c_Oatv).Id:=Oat_Rec.Id;
			c_Oatv:=c_Oatv+1;
		END LOOP;
	END LOOP;
END LOOP;
IF NOT l_Oatv_tbl.COUNT=0
THEN
OKC_OUTCOME_PUB.delete_out_arg(
   	p_api_version		=> l_api_version,
  	p_init_msg_list		=> l_init_msg_list,
     	x_return_status		=> l_return_status,
          	x_msg_count		=> l_msg_count,
          	x_msg_data		=> l_msg_data,
    	p_oatv_tbl                     	=> l_Oatv_tbl);
   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then x_Return_Status:=l_Return_status;
      return;
   end if;
END IF;
IF NOT l_ocev_tbl.Count=0
THEN
OKC_OUTCOME_PUB. delete_outcome(
   	p_api_version		=> l_api_version,
  	p_init_msg_list		=> l_init_msg_list,
     	x_return_status		=> l_return_status,
          	x_msg_count		=> l_msg_count,
          	x_msg_data		=> l_msg_data,
    	p_ocev_tbl                     	=> l_Ocev_tbl);
   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then x_Return_Status:=l_Return_status;
      return;
   end if;
END IF;
IF NOT l_aavv_tbl.Count=0
THEN
OKC_CONDITIONS_PUB.delete_act_att_vals(
   	p_api_version		=> l_api_version,
  	p_init_msg_list		=> l_init_msg_list,
     	x_return_status		=> l_return_status,
          	x_msg_count		=> l_msg_count,
          	x_msg_data		=> l_msg_data,
    	p_aavv_tbl                     	=> l_aavv_tbl);
   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then x_Return_Status:=l_Return_status;
      return;
   end if;
END IF;
IF NOT l_Coev_tbl.Count=0
THEN
OKC_CONDITIONS_PUB. delete_cond_occurs(
   	p_api_version		=> l_api_version,
  	p_init_msg_list		=> l_init_msg_list,
     	x_return_status		=> l_return_status,
          	x_msg_count		=> l_msg_count,
          	x_msg_data		=> l_msg_data,
    	p_coev_tbl                     	=> l_Coev_tbl);
   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then x_Return_Status:=l_Return_status;
      return;
   end if;
END IF;
IF NOT l_cnlv_tbl.Count=0
THEN
OKC_CONDITIONS_PUB.delete_cond_lines(
   	p_api_version		=> l_api_version,
  	p_init_msg_list		=> l_init_msg_list,
    x_return_status		=> l_return_status,
    x_msg_count		    => l_msg_count,
    x_msg_data		    => l_msg_data,
    p_cnlv_tbl          => l_cnlv_tbl);
   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then x_Return_Status:=l_Return_status;
      return;
   end if;
END IF;
IF NOT l_cnhv_tbl.Count=0
THEN
OKC_CONDITIONS_PUB. delete_cond_hdrs(
   	p_api_version		=> l_api_version,
  	p_init_msg_list		=> l_init_msg_list,
     	x_return_status		=> l_return_status,
          	x_msg_count		=> l_msg_count,
          	x_msg_data		=> l_msg_data,
    	p_cnhv_tbl                     	=> l_cnhv_tbl);
   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then x_Return_Status:=l_Return_status;
      return;
   end if;
END IF;
x_Return_Status:=OKC_API.G_RET_STS_SUCCESS;
EXCEPTION
WHEN OTHERS
THEN x_Return_Status:=l_Return_status;
     x_msg_data:=sqlcode||'-'||sqlerrm;
END Undo_Events;
-- Temporary Fix for Undo Counters by updating end_date_active to sysdate
-- To be attended to later

-- *************************************************************************************************
PROCEDURE UNDO_COUNTERS(P_Kline_Id 	IN 	NUMBER,
			x_Return_Status	OUT NOCOPY	VARCHAR2,
			x_msg_data	OUT NOCOPY	VARCHAR2)  IS

CURSOR Cur_Cgp (P_KLine_Id IN NUMBER) IS
SELECT Counter_Group_id FROM OKX_Counter_Groups_V WHERE Source_Object_Id=P_KLine_Id

				and Source_Object_Code='CONTRACT_LINE';

CURSOR Cur_OVN (P_CtrGrp_Id IN NUMBER) IS
SELECT Object_Version_Number FROM Cs_Counter_Groups
WHERE Counter_group_Id=P_CtrGrp_Id;

TYPE t_IdTable IS TABLE OF NUMBER(35)
INDEX BY BINARY_Integer;
l_cgp_tbl		t_IdTable;
c_Cgp		Number:=1;
l_Ctr_grp_id          NUMBER;
x_Object_Version_Number     NUMBER;
l_Object_Version_Number     NUMBER;
  l_api_version		CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	CONSTANT	VARCHAR2(1):= 'T';
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000):=null;
  l_msg_index_out       Number;
  l_api_name            CONSTANT VARCHAR2(30) := 'UNDO COUNTERS';
  l_Commit          Varchar2(3) ;
  l_Ctr_Grp_Rec		CS_Counters_Pub.CtrGrp_Rec_Type;
  l_cascade_upd_to_instances Varchar2(1);
BEGIN
x_Return_Status := OKC_API.G_RET_STS_SUCCESS;
FOR Cgp_Rec IN Cur_Cgp(P_KLine_Id)
LOOP
    l_cgp_tbl(c_Cgp):=Cgp_Rec.counter_group_Id;
	c_Cgp:=c_Cgp+1;
	FOR i in 1 .. l_Cgp_tbl.COUNT
	LOOP
		l_Ctr_grp_Id:=l_Cgp_tbl(i);
		l_Ctr_Grp_Rec.end_date_active:=sysdate;
		OPEN Cur_OVN(l_ctr_Grp_Id);
		FETCH  Cur_OVN INTO l_Object_version_Number;
		CLOSE Cur_OVN;
		CS_Counters_PUB.Update_Ctr_Grp
(
	p_api_version		=>l_api_version,
	p_init_msg_list		=>l_init_msg_list,
	p_commit			=>l_commit,
	x_return_status		=>l_return_status,
	x_msg_count			=>l_msg_count,
	x_msg_data			=>l_msg_data,
	p_ctr_grp_id	      =>l_ctr_grp_id,
 	p_object_version_number	=>	l_object_version_number,
	p_ctr_grp_rec			=>l_ctr_grp_rec,
	p_cascade_upd_to_instances	=>l_cascade_upd_to_instances,
	x_object_version_number	=>	x_object_version_number
);
	END LOOP;
   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then x_Return_Status:=l_Return_status;
      return;
   end if;
END LOOP;
x_Return_Status:=OKC_API.G_RET_STS_SUCCESS;


EXCEPTION
WHEN OTHERS
THEN x_Return_Status:=l_Return_status;
     x_msg_data:=sqlerrm;

END Undo_Counters;

-- *************************************************************************************************


PROCEDURE Update_COVERAGE_Effectivity(
  p_api_version     IN NUMBER,
  p_init_msg_list   IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2,
  p_service_Line_Id IN  NUMBER,
  p_New_Start_Date  IN DATE,
  p_New_End_Date    IN DATE)  IS

  l_api_version	    CONSTANT	NUMBER     := 1.0;
  l_init_msg_list   CONSTANT	VARCHAR2(1):= 'T';
  l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_msg_count	    NUMBER;
  l_message			VARCHAR2(2000):=null;
  l_msg_data	    VARCHAR2(2000):=null;
  l_msg_index_out   Number;
  l_api_name        CONSTANT VARCHAR2(30) := 'Update_cov_eff';
  e_Error	    EXCEPTION;
  NO_COV_ERROR      EXCEPTION;
  g_chr_Id	    NUMBER;
  l_Clev_Tbl_In     OKC_CONTRACT_PUB.clev_tbl_type;
  l_Clev_Tbl_Out    OKC_CONTRACT_PUB.clev_tbl_type;
  l_Cov_Id	    NUMBER;
  l_Bp_Id	    NUMBER;
  l_Id		    NUMBER;
  i		    NUMBER:= 0;
  l_Start_Date	DATE;
  g_Start_Date	DATE;
  g_End_Date	DATE;
  l_lse_id      NUMBER;

   -- Cursor for Coverage
   CURSOR Linecov_Cur(P_ID IN NUMBER) IS
   SELECT ID,
         LSE_ID,
         START_DATE,
         END_DATE
    FROM OKC_K_LINES_V
   WHERE cle_ID= P_Id and lse_id in (2,14,15,20,13,19);

   Linecov_Rec Linecov_Cur%ROWTYPE;
   ----------------------------------------------
   -- Cursor for Business Process
   CURSOR Linedet_Cur(P_ID IN NUMBER) IS
   SELECT ID, START_DATE, END_DATE
   FROM OKC_K_LINES_V
   WHERE cle_ID= P_Id ;

   LineDet_Rec LineDet_Cur%ROWTYPE;

  -- Cursor for getting offset period for BP from OKS
  CURSOR cur_get_offset_bp(p_cle_id IN NUMBER) IS
  SELECT ID, OFFSET_DURATION, OFFSET_PERIOD
  FROM OKS_K_LINES_B
  WHERE CLE_ID = p_cle_id ;

  oks_offset_rec CUR_GET_OFFSET_BP%ROWTYPE;
   ------------------------------------------------
   -- Cursor for Bill Type/Reaction Time
   CURSOR LineDet1_Cur(P_ID IN NUMBER) IS
   SELECT ID FROM OKC_K_LINES_V
   WHERE cle_ID= P_Id;
   ------------------------------------------------
   --Cursor for Bill Rate
   CURSOR LineDet2_Cur(P_ID IN NUMBER) IS
   SELECT ID FROM OKC_K_LINES_V
   WHERE cle_ID= P_Id;
   ------------------------------------------------
   CURSOR dnz_Cur IS
   SELECT Chr_Id FROM OKC_K_LINES_V
   WHERE Id=P_Service_Line_ID;

   l_bp_offset_duration  NUMBER := NULL;
   l_bp_offset_period    VARCHAR2(3) := NULL;

BEGIN

DBMS_TRANSACTION.SAVEPOINT(l_api_name);

IF (G_DEBUG_ENABLED = 'Y') THEN
       okc_debug.Set_Indentation('Update Coverage Effectivity');
       okc_debug.log('Entered Update Coverage Effectivity', 2);
END IF;

  OPEN dnz_Cur;
     FETCH dnz_Cur INTO g_chr_Id;
  CLOSE dnz_Cur;

  -- Populate Line TBL for Coverage

           For Linecov_Rec in Linecov_Cur(P_Service_Line_Id)
           LOOP
                i:=i+1;
                l_Cov_Id                    :=Linecov_Rec.Id;
                l_Clev_tbl_In(i).Id         :=l_Cov_Id;
                l_Clev_tbl_In(i).Start_Date :=P_New_Start_Date;
                l_Clev_tbl_In(i).End_Date   :=P_New_End_Date;
                l_lse_id                    := linecov_rec.lse_id;
           END LOOP ;

  -- Effectivity for Business Process
   IF l_lse_id <> 13 Then

  FOR LineDet_Rec IN LineDet_Cur(l_Cov_Id)
  LOOP
   i:=i+1;
   l_Bp_Id:=LineDet_Rec.Id;

   -- Populate Line TBL for Business Process
   l_Clev_tbl_In(i).Id:=l_Bp_Id;

   -- fetch OFS rule for Business Process


           OPEN  CUR_GET_OFFSET_BP(l_bp_id);
           FETCH cur_get_offset_bp into oks_offset_rec;
           IF cur_get_offset_bp%found then
              l_bp_offset_period   := oks_offset_rec.offset_period;
              l_bp_offset_duration := oks_offset_rec.offset_duration;
          END IF ;
         CLOSE cur_get_offset_bp ;

    IF l_bp_offset_period IS NOT NULL
      AND l_bp_offset_duration IS NOT NULL
      THEN

        l_start_date:=OKC_Time_Util_Pub.get_enddate
                        (P_New_Start_date,
                        l_bp_offset_period,
                        l_bp_offset_duration);

        IF l_bp_offset_duration > 0
        THEN
          l_start_date := l_start_date + 1;
        END IF;

        IF l_start_date < P_New_End_date
        THEN
          g_start_date:=l_start_date;
          g_end_date:= P_New_End_date;
        ELSE
          g_start_date:= P_New_End_date;
          g_end_date  := P_New_End_date;
        END IF;
     ELSE
          g_start_date:= P_New_Start_date;
          g_end_date  := P_New_End_date;
     END IF;



   -- Calculate Line Start Date for Business Process
   /*
   l_start_date:=OKC_Time_Util_Pub.get_enddate
                                        (P_New_Start_date,
					                     l_bp_offset_period,
					                     l_bp_offset_duration);

              IF  l_bp_offset_duration IS NOT NULL
                  AND l_bp_offset_duration  > 0
              THEN
                 l_start_date := l_start_date + 1;
              END IF;

   -- IF Line Start Date is later that End Date
             IF l_start_date > P_New_End_Date
             THEN
                   l_return_status:=OKC_API.G_RET_STS_ERROR;
                   RAISE e_error;
             END IF;

   -- If there is no Offset, Coverage Start Date will be start date for Business Process
              IF l_start_date is NOT NULL
              THEN
                   g_start_date:=l_start_date;
              ELSE
                    g_start_date:=p_new_start_date;
             END IF;
                g_end_date:= P_New_End_Date;
*/

--   IF NOT l_start_date > P_New_End_Date
--   THEN

   -- Populate Line TBL for Business Process
   l_clev_tbl_In(i).start_Date:=g_Start_Date;
   l_clev_tbl_In(i).end_Date:=g_end_Date;

   -- Fetch Bill Types/ Reaction Times

   FOR LineDet_Rec1 IN LineDet1_CUR(l_bp_Id)
   LOOP
     -- Populate Line TBL for Bill Types /Reaction Times
     i:=i+1;
     l_Clev_tbl_In(i).Id:=LineDet_Rec1.Id;
     l_clev_tbl_In(i).start_Date:=g_Start_Date;
     l_clev_tbl_In(i).end_Date:=g_end_Date;

     -- Fetch Bill Rate
     FOR LineDet_Rec2 IN LineDet2_CUR(LineDet_Rec1.Id)
     LOOP
       -- Populate Line TBL for Bill Rate
       i:=i+1;
       l_Clev_tbl_In(i).Id:=LineDet_Rec2.Id;
       l_clev_tbl_In(i).start_Date:=g_Start_Date;
       l_clev_tbl_In(i).end_Date:=g_end_Date;
     END LOOP; -- Bill Rate
     END LOOP; -- Bill Type/Reaction Times
--     END IF ;
 END LOOP; -- Business process
 END IF ;

 -- Update Line with all the data for Coverage, Business process, React Times, Bill Types, Bill Rate

IF (G_DEBUG_ENABLED = 'Y') THEN
       okc_debug.log('Before  okc_contract_pub.Update_Contract_Line', 2);
END IF;
             IF  l_clev_tbl_in.COUNT > 0 Then

                 okc_contract_pub.Update_Contract_Line(
	                                                    p_api_version		=> l_api_version,
	                                                    p_init_msg_list		=> l_init_msg_list,
	                                                    x_return_status		=> l_return_status,
	                                                    x_msg_count			=> l_msg_count,
	                                                    x_msg_data			=> l_msg_data,
                                                        p_restricted_update => 'T',
	                                                    p_clev_tbl			=> l_clev_tbl_in,
	                                                    x_clev_tbl			=> l_clev_tbl_out);


              IF (G_DEBUG_ENABLED = 'Y') THEN
                         okc_debug.log('After  okc_contract_pub.Update_Contract_Line'||l_return_status, 2);
              END IF;

                      IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN

                            IF l_msg_count > 0      THEN
                                FOR i in 1..l_msg_count  LOOP
                                    fnd_msg_pub.get (p_msg_index     => -1,
                                         p_encoded       => 'T', -- OKC$APPLICATION.GET_FALSE,
                                         p_data          => l_message,
                                         p_msg_index_out => l_msg_index_out);

                                l_msg_data := l_msg_data ||'  '||l_message;

                               END LOOP;
                            END IF;


                         RAISE e_Error;
                     END IF;
        END IF;
  x_return_status := l_return_status;


  IF (G_DEBUG_ENABLED = 'Y') THEN
         okc_debug.log('End of Update_Coverage_Effectivity'||l_return_status, 2);
         okc_debug.Reset_Indentation;
  END IF;


EXCEPTION
  WHEN NO_COV_ERROR THEN

  IF (G_DEBUG_ENABLED = 'Y') THEN
         okc_debug.log('Exp of Update_Coverage_Effectivity'||SQLERRM, 2);
         okc_debug.Reset_Indentation;
  END IF;


    DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name );
    --ROLLBACK ;
    OKC_API.SET_MESSAGE(g_app_name,'OKSMIS_REQUIRED_FIELD','FIELD_NAME','Coverage to run effectivity adjustment');
    x_return_status := 'E';

  WHEN e_Error THEN

    IF (G_DEBUG_ENABLED = 'Y') THEN
         okc_debug.log('Exp of Update_Coverage_Effectivity e_Error'||SQLERRM, 2);
         okc_debug.Reset_Indentation;
    END IF;

    DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name );
    --ROLLBACK ;
      x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
    x_return_status := 'E';

  WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (G_DEBUG_ENABLED = 'Y') THEN
         okc_debug.log('Exp of Update_Coverage_Effectivity '||SQLERRM, 2);
         okc_debug.Reset_Indentation;
    END IF;
     DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name );
     --ROLLBACK ;
      x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
    x_return_status := 'E';


  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

    IF (G_DEBUG_ENABLED = 'Y') THEN
         okc_debug.log('Exp of Update_Coverage_Effectivity '||SQLERRM, 2);
         okc_debug.Reset_Indentation;
    END IF;
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name );
      --ROLLBACK ;
      x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
    x_return_status := 'E';

  WHEN OTHERS THEN

    IF (G_DEBUG_ENABLED = 'Y') THEN
         okc_debug.log('Exp of Update_Coverage_Effectivity '||SQLERRM, 2);
         okc_debug.Reset_Indentation;
    END IF;

      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name );
        --ROLLBACK ;
        OKC_API.SET_MESSAGE(
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	        => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count :=l_msg_count;

END Update_Coverage_Effectivity;


PROCEDURE Undo_Line(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_validate_status       IN VARCHAR2 DEFAULT 'N',
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Line_Id               IN NUMBER) IS

   l_Cov_cle_Id NUMBER;
   l_Item_id     NUMBER;
   l_contact_Id NUMBER;
   l_RGP_Id     NUMBER;
   l_Rule_Id    NUMBER;
   l_cle_Id     NUMBER;
   v_Index   Binary_Integer;


 CURSOR line_det_Cur(P_cle_Id IN NUMBER)
 IS SELECT id, start_date, lse_id
 FROM   Okc_K_Lines_b
 WHERE  Id=P_cle_Id;

 CURSOR Child_Cur(P_cle_Id IN NUMBER)
 IS SELECT DNZ_CHR_ID
 FROM   Okc_K_Lines_b
 WHERE  cle_Id=P_cle_Id;

 CURSOR Child_Cur1(P_Parent_Id IN NUMBER)
 IS SELECT ID,DNZ_CHR_ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;

 CURSOR Child_Cur2(P_Parent_Id IN NUMBER)
 IS SELECT ID,DNZ_CHR_ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;
 CURSOR Child_Cur3(P_Parent_Id IN NUMBER)
 IS SELECT ID,DNZ_CHR_ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;
 CURSOR Child_Cur4(P_Parent_Id IN NUMBER)
 IS SELECT ID,DNZ_CHR_ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;
 CURSOR Child_Cur5(P_Parent_Id IN NUMBER)
 IS SELECT ID,DNZ_CHR_ID
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
 SELECT pr.ID FROM OKC_K_PARTY_ROLES_B pr
			,OKC_K_LINES_V lv
 WHERE  pr.cle_Id=P_cle_Id
 And    pr.cle_id = lv.id
 And    pr.dnz_chr_id = lv.dnz_chr_id;

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
  SELECT Id FROM OKC_K_REL_OBJS_V
  WHERE  cle_Id = P_cle_Id;

 CURSOR  OrderDetails_Cur(P_CHR_ID IN NUMBER,P_Cle_Id IN NUMBER) IS
  SELECT Id FROM OKS_K_ORDER_DETAILS_V
  WHERE chr_id = p_chr_id
  AND   cle_Id = P_cle_Id;

 CURSOR  SalesCredits_Cur(P_Cle_Id IN NUMBER) IS
  SELECT Id FROM OKS_K_SALES_CREDITS_V
  WHERE  cle_Id = P_cle_Id;

 CURSOR  OrderContacts_Cur(P_Cod_Id IN NUMBER) IS
  SELECT Id FROM OKS_K_Order_Contacts_V
  WHERE  cod_Id = P_cod_Id;

  n NUMBER:=0;

  line_det_rec          line_det_Cur%ROWTYPE;
  l_child_cur_rec       Child_cur%rowtype;
  l_clev_tbl_in         okc_contract_pub.clev_tbl_type;
  l_clev_tbl_tmp        okc_contract_pub.clev_tbl_type;
  l_rgpv_tbl_in         okc_rule_pub.rgpv_tbl_type;
  l_rulv_tbl_in         okc_rule_pub.rulv_tbl_type;
  l_cimv_tbl_in         okc_Contract_Item_Pub.cimv_tbl_TYPE;
  l_ctcv_tbl_in		okc_contract_party_pub.ctcv_tbl_type;
  l_cplv_tbl_in		okc_contract_party_pub.cplv_tbl_type;
  l_crjv_tbl_in		okc_k_rel_objs_pub.crjv_tbl_type;
  l_cocv_tbl_in         oks_Order_Contacts_Pub.cocv_tbl_TYPE;
  l_codv_tbl_in		oks_Order_Details_pub.codv_tbl_type;
  l_scrv_tbl_in		oks_Sales_Credit_pub.scrv_tbl_type;

  l_api_version		CONSTANT	NUMBER     	:= 1.0;
  l_init_msg_list	CONSTANT	VARCHAR2(1) := 'T';
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000):=null;
  l_msg_index_out       Number;
  l_api_name            CONSTANT VARCHAR2(30) := 'Undo Line';
  --l_catv_tbl_in		okc_k_article_pub.catv_tbl_type;
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
  c_cocv NUMBER:=1;
  c_codv NUMBER:=1;
  c_scrv NUMBER:=1;
  l_dummy_terminate_date  DATE;
  l_line_type             NUMBER;

 FUNCTION Bp_Check(P_rgp_Id IN NUMBER)
 RETURN BOOLEAN  IS
   CURSOR GetLse_Cur IS
   SELECT kl.lse_ID
   from okc_k_Lines_v kl,
        okc_rule_groups_v rg
   where kl.id = rg.cle_id
   and   rg.id = P_rgp_Id;


 BEGIN

   OPEN GetLse_Cur;
   FETCH GetLse_Cur INTO l_Lse_Id;
    IF NOT GetLse_Cur%FOUND
    THEN l_Lse_Id:=NULL;
    END IF;
   CLOSE GetLse_Cur;
   IF l_lse_Id IN (3,16,21)
    THEN RETURN TRUE;
   ELSE RETURN FALSE;
   END IF;
 END Bp_Check;


BEGIN
x_return_status:=OKC_API.G_Ret_Sts_Success;

Validate_Line_id(p_line_id,l_return_status);
IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
-- IF NOT l_Return_Status ='S' THEN
     RETURN;
END IF;

l_clev_tbl_tmp(c_clev).ID:=P_Line_Id;

OPEN Child_Cur(P_line_id);
FETCH Child_Cur into l_child_cur_rec;
l_clev_tbl_tmp(c_clev).DNZ_CHR_ID := l_child_cur_rec.dnz_chr_id;

CLOSE Child_cur;

c_clev:=c_clev+1;
FOR Child_Rec1 IN Child_Cur1(P_Line_Id)
LOOP
l_clev_tbl_tmp(c_clev).ID:=Child_Rec1.ID;
l_clev_tbl_tmp(c_clev).DNZ_CHR_ID:=Child_Rec1.DNZ_CHR_ID;
c_clev:=c_clev+1;
  FOR Child_Rec2 IN Child_Cur2(Child_Rec1.Id)
  LOOP
	l_clev_tbl_tmp(c_clev).ID:=Child_Rec2.Id;
	l_clev_tbl_tmp(c_clev).DNZ_CHR_ID:=Child_Rec2.DNZ_CHR_ID;
        c_clev:=c_clev+1;
     FOR Child_Rec3 IN Child_Cur3(Child_Rec2.Id)
     LOOP
	   l_clev_tbl_tmp(c_clev).ID:=Child_Rec3.Id;
	   l_clev_tbl_tmp(c_clev).DNZ_CHR_ID:=Child_Rec3.DNZ_CHR_ID;
           c_clev:=c_clev+1;
	 FOR Child_Rec4 IN Child_Cur4(Child_Rec3.Id)
	 LOOP
	      l_clev_tbl_tmp(c_clev).ID:=Child_Rec4.Id;
	      l_clev_tbl_tmp(c_clev).DNZ_CHR_ID:=Child_Rec4.DNZ_CHR_ID;
              c_clev:=c_clev+1;
             FOR Child_Rec5 IN Child_Cur5(Child_Rec4.Id)
	     LOOP
	  	l_clev_tbl_tmp(c_clev).ID:=Child_Rec5.Id;
	  	l_clev_tbl_tmp(c_clev).DNZ_CHR_ID:=Child_Rec5.DNZ_CHR_ID;
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
l_clev_tbl_in(c_clev).DNZ_CHR_ID:= l_clev_tbl_tmp(v_Index).DNZ_CHR_ID;
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

  FOR OrderDetails_REC IN OrderDetails_Cur(l_clev_tbl_in(v_Index).DNZ_CHR_ID,l_clev_tbl_in(v_Index).ID)
  LOOP
      l_codv_tbl_in(c_codv).ID:= OrderDetails_Rec.Id;
      FOR OrderContacts_REC IN OrderContacts_Cur(l_codv_tbl_in(c_codv).ID)
      LOOP
          l_cocv_tbl_in(c_cocv).ID:= OrderContacts_Rec.Id;
          c_cocv:=c_cocv+1;
      END LOOP;
      c_codv:=c_codv+1;
  END LOOP;
  FOR SalesCredits_REC IN SalesCredits_Cur(l_clev_tbl_in(v_Index).ID)
  LOOP
      l_scrv_tbl_in(c_scrv).ID:= SalesCredits_Rec.Id;
      c_scrv:=c_scrv+1;
  END LOOP;

END LOOP;

-- Get Rule Groups and Rules
FOR v_index IN l_clev_tbl_in.FIRST .. l_clev_tbl_In.LAST
LOOP
OPEN Rgp_Cur(l_clev_tbl_in(v_index).id);
FETCH Rgp_Cur INTO l_Rgp_Id;
IF Rgp_Cur%NOTFOUND
THEN l_rgp_Id:=Null;
END IF;
IF NOT l_Rgp_Id IS NULL
THEN
  l_rgpv_tbl_in(c_rgpv).Id:=l_Rgp_Id;
  c_rgpv:=c_Rgpv+1;
    FOR Rl_Rec IN Rl_Cur(l_Rgp_Id)
    LOOP
    l_Rulv_tbl_in(c_rulv).ID:=Rl_Rec.ID;
    c_rulv:=c_rulv+1;
    END LOOP;
END IF;
IF Rgp_Cur%ISOPEN
THEN
CLOSE Rgp_Cur;
END IF;
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

IF NOT l_cocv_tbl_in.COUNT=0 THEN

OKS_ORDER_CONTACTS_PUB.Delete_Order_Contact(
   	  p_api_version			=> l_api_version,
  	  p_init_msg_list		=> l_init_msg_list,
     	  x_return_status		=> l_return_status,
          x_msg_count			=> l_msg_count,
          x_msg_data			=> l_msg_data,
          p_cocv_tbl			=> l_cocv_tbl_in);

   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      return;
   end if;
END IF;

IF NOT l_codv_tbl_in.COUNT=0
THEN

OKS_ORDER_DETAILS_PUB.Delete_Order_Detail(
   	  p_api_version			=> l_api_version,
  	  p_init_msg_list		=> l_init_msg_list,
     	  x_return_status		=> l_return_status,
          x_msg_count			=> l_msg_count,
          x_msg_data			=> l_msg_data,
          p_codv_tbl			=> l_codv_tbl_in);

   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      return;
   end if;
END IF;

IF NOT l_scrv_tbl_in.COUNT=0
THEN

OKS_SALES_CREDIT_PUB.Delete_Sales_Credit(
   	  p_api_version			=> l_api_version,
  	  p_init_msg_list		=> l_init_msg_list,
     	  x_return_status		=> l_return_status,
          x_msg_count			=> l_msg_count,
          x_msg_data			=> l_msg_data,
          p_scrv_tbl			=> l_scrv_tbl_in);

   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      return;
   end if;
END IF;

IF NOT l_crjv_tbl_in.COUNT=0
THEN

OKC_K_REL_OBJS_PUB.Delete_Row(
   	  p_api_version			=> l_api_version,
  	  p_init_msg_list		=> l_init_msg_list,
     	  x_return_status		=> l_return_status,
          x_msg_count			=> l_msg_count,
          x_msg_data			=> l_msg_data,
          p_crjv_tbl			=> l_crjv_tbl_in);

   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      return;
   end if;
END IF;
IF NOT l_ctcv_tbl_in.COUNT=0
THEN
OKC_CONTRACT_PARTY_PUB.Delete_Contact(
   	  p_api_version			=> l_api_version,
  	  p_init_msg_list		=> l_init_msg_list,
     	  x_return_status		=> l_return_status,
          x_msg_count			=> l_msg_count,
          x_msg_data			=> l_msg_data,
          p_ctcv_tbl			=> l_ctcv_tbl_in);

   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      return;
   end if;
END IF;
IF NOT l_cplv_tbl_in.COUNT=0
THEN
OKC_CONTRACT_PARTY_PUB.Delete_k_Party_Role(
   	  p_api_version			=> l_api_version,
  	  p_init_msg_list		=> l_init_msg_list,
     	  x_return_status		=> l_return_status,
          x_msg_count			=> l_msg_count,
          x_msg_data			=> l_msg_data,
          p_cplv_tbl			=> l_cplv_tbl_in);

   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      return;
   end if;
END IF;
/*
IF NOT l_rulv_tbl_in.COUNT=0 THEN
  -------delete level elements before deleting rules.

  OPEN line_det_cur(p_line_id);
  FETCH line_det_cur INTO line_det_rec;

  l_dummy_terminate_date := line_det_rec.start_date - 1;

  IF line_det_rec.lse_id = 1 OR line_det_rec.lse_id = 12 OR line_det_rec.lse_id = 14
    OR line_det_rec.lse_id = 19 THEN

    l_line_type := 1;             --1 for TOP line
  ELSE

    l_line_type := 2;             --2 for covered level
  END IF;

  CLOSE line_det_cur;

  ------ERROROUT_AD('l_line_lse_id = ' || TO_CHAR(line_det_rec.lse_id));
  ------ERROROUT_AD('l_line_type = ' || TO_CHAR(l_line_type));
  ------ERROROUT_AD('l_dummy_terminate_date = ' || TO_CHAR(l_dummy_terminate_date));
  ------ERROROUT_AD('P_line_id = '|| TO_CHAR(P_line_id));
  ------ERROROUT_AD('CALLING pre_del_level_elements');

  OKS_BILL_UTIL_PUB.pre_del_level_elements(
                            p_api_version       => l_api_version,
                            p_terminated_date   => l_dummy_terminate_date,
                            p_id                => P_line_id ,
                            p_flag              => l_line_type,
                            x_return_status     => l_return_status);

  IF NOT nvl(l_return_status,'S') = OKC_API.G_RET_STS_SUCCESS THEN
     x_return_status := OKC_API.G_RET_STS_ERROR;
     OKC_API.Set_Message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ERROR IN DELETING LEVEL_ELEMENTS');
     RETURN;
  END IF;

  okc_Rule_pub.delete_Rule (
   	  p_api_version			=> l_api_version,
  	  p_init_msg_list		=> l_init_msg_list,
     	  x_return_status		=> l_return_status,
          x_msg_count			=> l_msg_count,
          x_msg_data			=> l_msg_data,
          p_rulv_tbl			=> l_rulv_tbl_in);
/---if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
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
      END IF;---/
IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
   RAISE e_Error;
END IF;
END IF;

IF NOT l_rgpv_tbl_in.COUNT=0
THEN
  okc_Rule_pub.delete_Rule_group (
   	  p_api_version			=> l_api_version,
  	  p_init_msg_list		=> l_init_msg_list,
     	  x_return_status		=> l_return_status,
          x_msg_count			=> l_msg_count,
          x_msg_data			=> l_msg_data,
          p_rgpv_tbl			=> l_rgpv_tbl_in);

   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      return;
   end if;
END IF;
*/
IF NOT l_cimv_tbl_in.COUNT=0
THEN
  okc_contract_ITEM_pub.delete_Contract_ITEM (
   	  p_api_version			=> l_api_version,
  	  p_init_msg_list		=> l_init_msg_list,
     	  x_return_status		=> l_return_status,
          x_msg_count			=> l_msg_count,
          x_msg_data			=> l_msg_data,
          p_cimv_tbl			=> l_cimv_tbl_in);
/* IF nvl(l_return_status,'*') <> 'S'
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
      RAISE e_Error; */
IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
  RAISE e_Error;
END IF;
END IF;

IF NOT l_clev_tbl_in.COUNT=0
THEN
if (p_validate_status = 'Y') then
  okc_contract_pub.delete_contract_line (
   	  p_api_version			=> l_api_version,
  	  p_init_msg_list		=> l_init_msg_list,
     	  x_return_status		=> l_return_status,
          x_msg_count			=> l_msg_count,
          x_msg_data			=> l_msg_data,
          p_clev_tbl			=> l_clev_tbl_in);
else
    for i in l_clev_tbl_in.first .. l_clev_tbl_in.last
    loop
	BEGIN
        delete okc_k_lines_tl where
            id =l_clev_tbl_in(i).id;
        delete okc_k_lines_b where
            id =l_clev_tbl_in(i).id;

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
	END;
    end loop;
end if;

/* IF nvl(l_return_status,'*') <> 'S'
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
      RAISE e_Error;*/
IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
  RAISE e_Error;
END IF;
END IF;


Oks_Coverages_Pvt.UNDO_EVENTS	(P_line_Id ,
			l_Return_Status	,
			l_msg_data	)  ;
   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      RAISE e_Error;
   end if;

Oks_Coverages_Pvt.UNDO_Counters	(P_line_Id ,
			l_Return_Status	,
			l_msg_data	)  ;
   if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
   then
      RAISE e_Error;
   end if;
x_Return_status:=l_Return_status;

EXCEPTION
    WHEN e_Error THEN
    -- notify caller of an error as UNEXPETED error
    x_msg_count :=l_msg_count;
x_msg_data:=l_msg_data;
x_Return_status:=l_Return_status;
/*      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Undo_Line',
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
        'Undo_Line',
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
        'Undo_Line',
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        l_msg_count,
        l_msg_data,
        '_PVT'
      );*/
    WHEN OTHERS THEN
x_msg_count :=l_msg_count;
    OKC_API.SET_MESSAGE(
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	        => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Undo_Line;


Procedure CHECK_COVERAGE_MATCH
   ( p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Source_contract_Line_Id       IN NUMBER,
    P_Target_contract_Line_Id       IN NUMBER,
    x_coverage_match         OUT  NOCOPY VARCHAR2) IS


--  First compare coverage
   Cursor Cur_get_cov_info(p_contract_line_id NUMBER) IS
    SELECT coverage_id, standard_cov_yn
    FROM OKS_K_LINES_B
    WHERE cle_id = p_contract_line_id;
--  get the coverage info

   Cursor Cur_Get_Cov_details(p_cov_line_id NUMBER) IS
   SELECT NAME, ITEM_DESCRIPTION,
	EXCEPTION_YN
	FROM OKC_K_LINES_V
   	WHERE id = p_cov_line_id
  	AND   lse_id in (2,15,20);

   Cursor Get_Coverage_rules(p_cov_line_id NUMBER) IS
   Select   COVERAGE_TYPE,
            EXCEPTION_COV_ID,
            INHERITANCE_TYPE,
            TRANSFER_OPTION,
            PROD_UPGRADE_YN
          /* COmmented by Jvorugan for Bug:4610449  NVL(PM_PROGRAM_ID,0) PM_PROGRAM_ID,
                                                    NVL(PM_CONF_REQ_YN,0) PM_CONF_REQ_YN,
                                                    NVL(PM_SCH_EXISTS_YN,0) PM_SCH_EXISTS_YN */
    FROM    OKS_K_LINES_B
    WHERE   CLE_ID = p_cov_line_id;

    Source_Coverage_rules   Get_Coverage_rules%ROWTYPE;
    Target_Coverage_rules   Get_Coverage_rules%ROWTYPE;

--Added by Jvorugan for Bug:4610449
-- Cursor to get the PM info. With R12, PM info will be stored with oks_k_lines_b record for the topline
   Cursor Get_PM_rules(p_contract_line_id NUMBER) IS
   Select   NVL(PM_PROGRAM_ID,0) PM_PROGRAM_ID,
            NVL(PM_CONF_REQ_YN,0) PM_CONF_REQ_YN,
            NVL(PM_SCH_EXISTS_YN,0) PM_SCH_EXISTS_YN
    FROM    OKS_K_LINES_B
    WHERE   CLE_ID = p_contract_line_id;

    Source_PM_rules   Get_PM_rules%ROWTYPE;
    Target_PM_rules   Get_PM_rules%ROWTYPE;


    Cursor Cur_Get_BussProc(p_cle_id NUMBER) IS
    SELECT lines.id,
    -- lines.start_date start_date,
    -- lines.end_date end_date,
    items.object1_id1
    FROM OKC_K_LINES_V lines, OKC_K_ITEMS_V items
    WHERE lines.cle_id  = p_cle_id
    AND lines.lse_id IN(3,16,21)
    AND items.JTOT_OBJECT1_CODE = 'OKX_BUSIPROC'
    AND items.cle_id = lines.id ;

    -- PRE AND DST RULES FOR A BP

CURSOR CUR_GET_OKS_BP(p_cle_id NUMBER) IS
SELECT lines.id 		bp_line_id,
       NVL(lines.price_list_id,0)		price_list_id,
       items.object1_id1 		object1_id1,
       NVL(kines.discount_list,0)		discount_list,
       NVL(kines.offset_duration,0)	offset_duration,
       NVL(kines.offset_period,0)		offset_period,
       NVL(kines.allow_bt_discount,0)	allow_bt_discount,
       NVL(kines.apply_default_timezone,0)	apply_default_timezone
 FROM  OKC_K_LINES_B lines,
       OKC_K_ITEMS   items,
       OKS_K_LINES_B kines
WHERE lines.cle_id = p_cle_id
AND lines.id = items.cle_id
AND items.jtot_object1_code = 'OKX_BUSIPROC'
AND lines.lse_id in (3,16,21)
AND kines.cle_id = lines.id
AND lines.dnz_chr_id = kines.dnz_chr_id
AND lines.dnz_chr_id = items.dnz_chr_id;


    -- COVER TIMES FOR BUSINESS PROCESS

Cursor Cur_Get_Cover_times(p_id NUMBER, p_bp_id NUMBER) IS
    SELECT lines.id,
           items.object1_id1   object1_id1,
           covtz.timezone_id   timezone_id,
           covtz.default_yn    default_yn,
           covtm.start_hour    start_hour,
           covtm.start_minute  start_minute,
           covtm.end_hour      end_hour,
           covtm.end_minute    end_minute,
           covtm.monday_yn     monday_yn,
           covtm.tuesday_yn    tuesday_yn,
           covtm.wednesday_yn  wednesday_yn,
           covtm.thursday_yn   thursday_yn,
           covtm.friday_yn     friday_yn,
           covtm.saturday_yn   saturday_yn,
           covtm.sunday_yn     sunday_yn
    FROM    OKC_K_LINES_B lines,
            OKC_K_ITEMS items,
            OKS_COVERAGE_TIMEZONES covtz,
            OKS_COVERAGE_TIMES covtm
    WHERE   lines.id = p_id
    AND     lines.lse_id IN (3,16,21)
    AND     lines.dnz_chr_id = items.dnz_chr_id
    AND     items.cle_id = lines.id
    AND     items.object1_id1 = p_bp_id
    AND     items.jtot_object1_code = 'OKX_BUSIPROC'
    AND     items.dnz_chr_id = lines.dnz_chr_id
    AND     covtz.cle_id = lines.id
    AND     covtz.dnz_chr_id = lines.dnz_chr_id
    AND     covtm.cov_tze_line_id = covtz.id
   ORDER BY to_number(items.object1_id1), covtz.timezone_id ;

--    REACTION  TIMES FOR A BUSINESS PROCESS

   Cursor Cur_Get_React_Times(p_cle_id NUMBER) IS
   SELECT lines.id react_time_line_id,
          oksl.id  oks_react_line_id,
          NVL(oksl.incident_severity_id,0) incident_severity_id,
          NVL(oksl.pdf_id,0) pdf_id,
          NVL(oksl.work_thru_yn,'N') work_thru_yn,
          NVL(oksl.react_active_yn, 'N') react_active_yn,
          oksl.react_time_name  react_time_name,
          act.id act_type_line_id,
          act.action_type_code action_type_code,
          acm.uom_code uom_code,
          NVL(acm.sun_duration,0) sun_duration,
          NVL(acm.mon_duration,0) mon_duration,
          NVL(acm.tue_duration,0) tue_duration,
          NVL(acm.wed_duration,0) wed_duration,
          NVL(acm.thu_duration,0) thu_duration,
          NVL(acm.fri_duration,0) fri_duration,
          NVL(acm.sat_duration,0) sat_duration
   FROM   OKC_K_LINES_B lines,
          OKS_K_LINES_V oksl,
          OKS_ACTION_TIME_TYPES act,
          OKS_ACTION_TIMES acm
   WHERE lines.cle_id = p_cle_id
   AND   lines.lse_id IN (4,17,22)
   AND   oksl.cle_id = lines.id
   AND   act.cle_id =  lines.id
   AND   act.dnz_chr_id = lines.dnz_chr_id
   AND   acm.cov_action_type_id = act.id
   AND   acm.dnz_chr_id =   act.dnz_chr_id;

  -- RESOLUTION TIMES FOR A BUSINES PROCESS

 -- RESOURCES FOR A BUSINES PROCESS

    Cursor Cur_get_resources(p_bp_line_id NUMBER, p_bp_id NUMBER) IS
    SELECT  lines.id lines_id,
            party.id party_id,
            items.object1_id1 BP_ID,
            ocv.cro_code cro_code,
            ocv.object1_id1 res_id,
            ocv.resource_class resource_class
    FROM OKC_K_LINES_V lines,
         OKC_K_PARTY_ROLES_B party,
         OKC_CONTACTS_V ocv,
         OKC_K_ITEMS_V items
    WHERE lines.id = p_bp_line_id
    AND lines.lse_id IN (3,16,21)
    AND party.cle_id = lines.id
    AND items.cle_id = lines.id
    AND items.object1_id1 = p_bp_id
    AND items.jtot_object1_code = 'OKX_BUSIPROC'
    AND party.id = ocv.cpl_id
    AND lines.dnz_chr_id = party.dnz_chr_id ;



-- BILLING TYPES  FOR A BUSINESS PROCESS

  Cursor Cur_Get_Bill_Types(p_cle_id NUMBER) IS
   SELECT    lines.id bill_type_line_id,
            items.object1_id1 object1_id1,
            oksl.discount_amount  discount_amount,
            oksl.discount_percent discount_percent,
            txn.billing_type billing_type
    FROM OKC_K_LINES_V lines,
         OKS_K_LINES_B oksl,
         OKC_K_ITEMS_V items,
         okx_txn_billing_types_v txn
   WHERE lines.cle_id = p_cle_id
   AND   oksl.cle_id = lines.id
   AND   oksl.dnz_chr_id = lines.dnz_chr_id
   AND   items.cle_id = lines.id
   AND  lines.lse_id IN (5,23,59)
   AND  items.jtot_object1_code = 'OKX_BILLTYPE'
   AND  items.object1_id1 = txn.id1;

   -- BILL RATES FOR A BUSINES PROCESS

-- code changed for new bill rate schedules, 02/24/2003


    CURSOR CUR_GET_BRS(p_bt_cle_id NUMBER) IS
   SELECT  NVL(brs.START_HOUR,0) START_HOUR,
 NVL(brs.START_MINUTE,0) START_MINUTE,
 NVL(brs.END_HOUR,0) END_HOUR,
 NVL(brs.END_MINUTE,0)END_MINUTE,
 NVL(brs.MONDAY_FLAG,'N') MONDAY_FLAG,
 NVL(brs.TUESDAY_FLAG,'N')TUESDAY_FLAG,
 NVL(brs.WEDNESDAY_FLAG,'N')WEDNESDAY_FLAG,
 NVL(brs.THURSDAY_FLAG,'N')THURSDAY_FLAG,
 NVL(brs.FRIDAY_FLAG,'N')FRIDAY_FLAG,
 NVL(brs.SATURDAY_FLAG,'N')SATURDAY_FLAG,
 NVL(brs.SUNDAY_FLAG,'N')SUNDAY_FLAG,
 NVL(brs.OBJECT1_ID1,'N')OBJECT1_ID1,
 NVL(brs.OBJECT1_ID2,'N')OBJECT1_ID2,
 NVL(brs.JTOT_OBJECT1_CODE,'N')JTOT_OBJECT1_CODE,
 NVL(brs.BILL_RATE_CODE,'N')BILL_RATE_CODE,
 NVL(brs.FLAT_RATE,0)FLAT_RATE,
 NVL(brs.UOM,'N') UOM,
 NVL(brs.HOLIDAY_YN,'N') HOLIDAY_YN,
 NVL(brs.PERCENT_OVER_LIST_PRICE,0) PERC_OVER_LIST_PRICE
 FROM OKS_BILLRATE_SCHEDULES brs
 WHERE brs.bt_cle_id = p_bt_cle_id ;


   i                         NUMBER:= 0 ;
   j                         NUMBER:= 0 ;
   k                         NUMBER:= 0 ;
   src_cvr_index             NUMBER:= 0;
   tgt_cvr_index             NUMBER:= 0;
   l_source_start_date       Date;
   l_source_end_date         Date;
   l_target_start_date       Date;
   l_target_end_date         Date;
   l_source_exp              OKC_K_LINES_V.EXCEPTION_YN%TYPE;
   l_target_exp              OKC_K_LINES_V.EXCEPTION_YN%TYPE;
   l_src_cov_id              NUMBER;
   l_tgt_cov_id              NUMBER;
   G_MISMATCH                EXCEPTION ;
   l_return                  BOOLEAN:= TRUE;
   v_bp_found                BOOLEAN := FALSE;
   l_bp                      VARCHAR2(100);
   src_index                 NUMBER;
   tgt_index                 NUMBER;
   src_res_index             NUMBER;
   tgt_res_index             NUMBER:= 0;
   l_param                   NUMBER:= 0;
   l_param2                  NUMBER:= 0;
   src_cvr_index1            NUMBER:= 0;
   tgt_cvr_index1            NUMBER:= 0;
   src_rcn_index             NUMBER:= 0;
   tgt_rcn_index             NUMBER:= 0;
   src_rcn_index1            NUMBER:= 0;
   tgt_rcn_index1            NUMBER:= 0;
   l_rcn                     NUMBER:= 0;
   l_rsn                     NUMBER:= 0;
   src_rsn_index             NUMBER:= 0;
   tgt_rsn_index             NUMBER:= 0;
   src_rsn_index1            NUMBER:= 0;
   tgt_rsn_index1            NUMBER:= 0;
   src_bill_type_index       NUMBER:= 0;
   tgt_bill_type_index       NUMBER:= 0;
   src_bill_type_index1      NUMBER:= 0;
   tgt_bill_type_index1      NUMBER:= 0;
   l_bill_type               NUMBER:= 0;
   l_bill_rate_type          VARCHAR2(10);
   src_bill_rate_index       NUMBER:= 0;
   tgt_bill_rate_index       NUMBER:= 0;
   l_src_bill_rate_line_id   NUMBER:= 0;
   l_tgt_bill_rate_line_id   NUMBER:= 0;
   src_bill_rate_index1      NUMBER:= 0;
   tgt_bill_rate_index1      NUMBER:= 0;
   l_bill_rate               NUMBER:= 0;
   src_bp_rule_index         NUMBER:= 0;
   tgt_bp_rule_index         NUMBER:= 0;
   src_bp_rule_index1        NUMBER:= 0;
   tgt_bp_rule_index1        NUMBER:= 0;
   l_bp_rule                 NUMBER:= 0;
   source_res_index             NUMBER:= 0;
    target_res_index             NUMBER:= 0;
  -- x_return_status           VARCHAR2(1);
  l_msg_count 	             NUMBER;
  l_msg_data		     VARCHAR2(2000):=null;
  l_source_cov_name          VARCHAR2(150);
  l_target_cov_name          VARCHAR2(150);
  l_source_cov_desc          OKC_K_LINES_V.ITEM_DESCRIPTION%TYPE;
  l_target_cov_desc          OKC_K_LINES_V.ITEM_DESCRIPTION%TYPE;
  l_pml_src_index            NUMBER:= 0;
  l_pml_tgt_index            NUMBER:= 0;
 -- l_src_pml_index1           NUMBER:= 0;
 -- l_tgt_pml_index1           NUMBER:= 0;
  l_pml_param                NUMBER:= 0;
  l_src_pml_index            NUMBER;
  src_pma_index1            NUMBER;
  tgt_pma_index1            NUMBER;
  l_pma_rule                VARCHAR2(1);
  src_pma_index             NUMBER:= 0;
  tgt_pma_index            NUMBER:= 0;
  -- GLOBAL VARIABLES
  l_api_version		    CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	    CONSTANT	VARCHAR2(1):= 'F';
  l_return_status	    VARCHAR2(1);
    l_pm_match 			VARCHAR2(1);
    l_src_std_cov_yn    VARCHAR2(1);
    l_tgt_std_cov_yn    VARCHAR2(1);

BEGIN
-- R12 changes start
 Open Cur_get_cov_info(p_source_contract_line_id) ;
 Fetch Cur_get_cov_info INTO l_src_cov_id,l_src_std_cov_yn;
 Close Cur_get_cov_info;

 Open Cur_get_cov_info(p_target_contract_line_id) ;
 Fetch Cur_get_cov_info INTO l_tgt_cov_id,l_tgt_std_cov_yn;
 Close Cur_get_cov_info;
-- If one standard coverage and the other one customized coverage, raise mismatch
IF l_src_std_cov_yn <> l_tgt_std_cov_yn
Then
     Raise G_MISMATCH;
END IF ;
-- If both are standard coverage and are not same, raise mismatch
IF l_src_std_cov_yn = 'Y'
and l_src_cov_id <> l_tgt_cov_id
then
     Raise G_MISMATCH;
END IF ;

 Open Cur_Get_Cov_details(l_src_cov_id) ;
 Fetch Cur_Get_Cov_details Into l_source_cov_name, l_source_cov_desc,
                            --l_source_start_date, l_source_end_date,
	                      l_source_exp;
 Close Cur_Get_Cov_details;

 Open  Cur_Get_Cov_details(l_tgt_cov_id) ;
 Fetch Cur_Get_Cov_details Into l_target_cov_name, l_target_cov_desc,
                            --l_target_start_date, l_target_end_date,
			      l_target_exp;
 Close Cur_Get_Cov_details;

-- R12 changes end

 IF l_source_cov_name <> l_target_cov_name
    OR l_source_cov_desc <> l_target_cov_desc
    --OR l_source_start_date <> l_target_start_date
    --OR l_source_end_date <> l_target_end_date
    OR l_source_exp <> l_target_exp   Then
     Raise G_MISMATCH;
 END IF ;

    OPEN Get_Coverage_Rules(l_src_cov_id)   ;
    FETCH Get_Coverage_rules INTO Source_Coverage_rules;
    CLOSE Get_Coverage_Rules ;

    OPEN Get_Coverage_Rules(l_tgt_cov_id)   ;
    FETCH Get_Coverage_rules INTO Target_Coverage_rules;
    CLOSE Get_Coverage_Rules ;

    IF  ( (Source_Coverage_rules.COVERAGE_TYPE     <> Target_Coverage_rules.COVERAGE_TYPE)
     OR  (Source_Coverage_rules.EXCEPTION_COV_ID  <> Target_Coverage_rules.EXCEPTION_COV_ID)
     OR  (Source_Coverage_rules.TRANSFER_OPTION   <> Target_Coverage_rules.TRANSFER_OPTION     )
     OR  (Source_Coverage_rules.PROD_UPGRADE_YN   <> Target_Coverage_rules.PROD_UPGRADE_YN)
     OR  (Source_Coverage_rules.INHERITANCE_TYPE  <> Target_Coverage_rules.INHERITANCE_TYPE))
    /* Commented by Jvorugan for Bug:4610449. With R12 Pm info will be stored with oks_k_lines_b
       record associated with the service line.
        OR  (Source_Coverage_rules.PM_PROGRAM_ID     <> Target_Coverage_rules.PM_PROGRAM_ID )
        OR  (Source_Coverage_rules.PM_CONF_REQ_YN    <> Target_Coverage_rules.PM_CONF_REQ_YN   )
        OR  (Source_Coverage_rules.PM_SCH_EXISTS_YN  <> Target_Coverage_rules.PM_SCH_EXISTS_YN)) */
   Then

       Raise G_MISMATCH;
  END IF ;
   -- Added by Jvorugan for Bug:4610449. R12 Changes start
    OPEN Get_PM_rules(P_Source_contract_Line_Id);
    FETCH Get_PM_rules INTO Source_PM_rules;
    CLOSE Get_PM_rules ;

    OPEN Get_PM_rules(P_Target_contract_Line_Id);
    FETCH Get_PM_rules INTO Target_PM_rules;
    CLOSE Get_PM_rules ;

    IF ((Source_PM_rules.PM_PROGRAM_ID     <> Target_PM_rules.PM_PROGRAM_ID)
    OR  (Source_PM_rules.PM_CONF_REQ_YN    <> Target_PM_rules.PM_CONF_REQ_YN)
    OR  (Source_PM_rules.PM_SCH_EXISTS_YN  <> Target_PM_rules.PM_SCH_EXISTS_YN))

    THEN
        Raise G_MISMATCH;
    END IF;

IF ((Source_PM_rules.PM_PROGRAM_ID IS NOT NULL) AND
	(Target_PM_rules.PM_PROGRAM_ID IS NOT NULL)) THEN

 OKS_PM_PROGRAMS_PVT.check_pm_match
       ( p_api_version                  => l_api_version,
        p_init_msg_list                 => l_init_msg_list,
        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data,
        P_Source_coverage_Line_Id       => P_Source_contract_Line_Id,  -- l_src_cov_id,commented by Jvorugan
        P_Target_coverage_Line_Id       => P_Target_contract_Line_Id,  -- l_tgt_cov_id,
        x_pm_match                      => l_pm_match);

IF l_pm_match <> 'Y' THEN
	Raise G_MISMATCH;
END IF;

END IF;

-- End of Changes for R12 by Jvorugan
-------------------------Business Process ------------------------------

    FOR C1 IN Cur_Get_BussProc(l_src_cov_id)    LOOP
       i:= i + 1;
       x_source_bp_tbl_type(i).object1_id1:= C1.object1_id1 ;
       x_source_bp_tbl_type(i).bp_line_id:= C1.id ;
       --x_source_bp_tbl_type(i).start_date:= C1.start_date;
       --x_source_bp_tbl_type(i).end_date:= C1.end_date;
    END LOOP ;


    FOR C2 IN Cur_Get_BussProc(l_tgt_cov_id) LOOP
       j:= j + 1;
       x_target_bp_tbl_type(j).object1_id1:= C2.object1_id1 ;
       x_target_bp_tbl_type(j).bp_line_id:= C2.id ;
       --x_target_bp_tbl_type(j).start_date:= C2.start_date;
       --x_target_bp_tbl_type(j).end_date:= C2.end_date;
    END LOOP ;

    IF x_source_bp_tbl_type.count <> x_target_bp_tbl_type.count Then

            RAISE G_MISMATCH ;
    END IF ;

IF x_source_bp_tbl_type.count > 0 Then
       FOR src_index in x_source_bp_tbl_type.FIRST..x_source_bp_tbl_type.LAST   LOOP

        FOR tgt_index in x_target_bp_tbl_type.FIRST..x_target_bp_tbl_type.LAST  LOOP

                IF x_source_bp_tbl_type(src_index).object1_id1 = x_target_bp_tbl_type(tgt_index).object1_id1 THEN
               /*
                    IF   ((x_source_bp_tbl_type(src_index).end_date <> x_target_bp_tbl_type(tgt_index).end_date)
                        OR (x_source_bp_tbl_type(src_index).start_date <> x_target_bp_tbl_type(tgt_index).start_date)) THEN


                        RAISE G_MISMATCH ;
                   END IF;
              */
                            v_bp_found := TRUE;
                            k := k+1;
                            l_bp_tbl(k).bp_id          := x_source_bp_tbl_type(src_index).object1_id1;
                            l_bp_tbl(k).src_bp_line_id := x_source_bp_tbl_type(src_index).bp_line_id;
                            l_bp_tbl(k).tgt_bp_line_id := x_target_bp_tbl_type(tgt_index).bp_line_id;
                            EXIT ;
                    END IF ;
        END LOOP ;

                IF NOT v_bp_found  then
                    RAISE G_MISMATCH ;
                END IF;
               v_bp_found := FALSE;

        END LOOP ;
END IF;
    -------resource---

IF l_bp_tbl.count > 0 Then -- IF 1

    FOR bp_index in l_bp_tbl.FIRST..l_bp_tbl.LAST LOOP -- LOOP 1

   source_res_index := 0;

    FOR C1 IN Cur_get_resources(l_bp_tbl(bp_index).src_bp_line_id,to_number(l_bp_tbl(bp_index).bp_id))  LOOP -- LOOP 2
     source_res_index := source_res_index + 1;
     x_source_res_tbl_type(source_res_index).bp_id:= C1.BP_ID;
     x_source_res_tbl_type(source_res_index).cro_code:= C1.CRO_CODE;
     x_source_res_tbl_type(source_res_index).object1_id1:= C1.res_id;
     x_source_res_tbl_type(source_res_index).resource_class:= C1.RESOURCE_CLASS;
    END LOOP; -- LOOP 2

  target_res_index := 0;

    FOR C2 IN Cur_get_resources(l_bp_tbl(bp_index).tgt_bp_line_id,to_number(l_bp_tbl(bp_index).bp_id))  LOOP -- LOOP 3
     target_res_index:= target_res_index + 1;
     x_target_res_tbl_type(target_res_index).bp_id:= C2.BP_ID;
     x_target_res_tbl_type(target_res_index).cro_code:= C2.CRO_CODE;
     x_target_res_tbl_type(target_res_index).object1_id1:= C2.res_id;
     x_target_res_tbl_type(target_res_index).resource_class:= C2.RESOURCE_CLASS;
    END LOOP ; -- LOOP 3

    IF  x_source_res_tbl_type.count <> x_target_res_tbl_type.count Then --IF 2

        RAISE G_MISMATCH ;
    END IF; --IF 2

IF x_source_res_tbl_type.count > 0 Then --IF 3
    FOR src_res_index IN x_source_res_tbl_type.FIRST..x_source_res_tbl_type.LAST   LOOP --LOOP 4

    tgt_res_index:= x_target_res_tbl_type.FIRST ;

    LOOP --LOOP 5

    IF x_source_res_tbl_type(src_res_index).cro_code = x_target_res_tbl_type(tgt_res_index).cro_code
      AND  x_source_res_tbl_type(src_res_index).object1_id1 = x_target_res_tbl_type(tgt_res_index).object1_id1
      AND  x_source_res_tbl_type(src_res_index).resource_class  = x_target_res_tbl_type(tgt_res_index).resource_class THEN

        l_param := 1 ;
        EXIT ;

    ELSE
      l_param := 2 ;
    END IF ;

    EXIT WHEN (tgt_res_index = x_target_res_tbl_type.LAST) ;
    tgt_res_index:= x_target_res_tbl_type.NEXT(tgt_res_index);

    END LOOP ; --LOOP 5

        IF  l_param = 2 THEN
            RAISE G_MISMATCH ;
        END IF ;
    END LOOP ;  --LOOP 4

END IF ;
END LOOP; -- LOOP 1
END IF;

    ---EnD resource---
------------------Buss Process OKS LINES--------------------

    FOR source_bp_rec IN CUR_GET_OKS_BP(l_src_cov_id)   LOOP
     src_bp_rule_index := src_bp_rule_index + 1 ;

      x_source_bp_tbl(src_bp_rule_index).PRICE_LIST_ID            := source_bp_rec.price_list_id;
      x_source_bp_tbl(src_bp_rule_index).OBJECT1_ID1              := source_bp_rec.object1_id1;
      x_source_bp_tbl(src_bp_rule_index).DISCOUNT_LIST            := source_bp_rec.discount_list;
      x_source_bp_tbl(src_bp_rule_index).OFFSET_DURATION          := source_bp_rec.offset_duration;
      x_source_bp_tbl(src_bp_rule_index).OFFSET_PERIOD            := source_bp_rec.offset_period;
      x_source_bp_tbl(src_bp_rule_index).ALLOW_BT_DISCOUNT        := source_bp_rec.allow_bt_discount;
      x_source_bp_tbl(src_bp_rule_index).APPLY_DEFAULT_TIMEZONE   := source_bp_rec.apply_default_timezone;
    END LOOP ;


    FOR target_bp_rec IN CUR_GET_OKS_BP(l_tgt_cov_id)   LOOP

     tgt_bp_rule_index := tgt_bp_rule_index + 1 ;

      x_target_bp_tbl(tgt_bp_rule_index).PRICE_LIST_ID            := target_bp_rec.price_list_id;
      x_target_bp_tbl(tgt_bp_rule_index).OBJECT1_ID1              := target_bp_rec.object1_id1;
      x_target_bp_tbl(tgt_bp_rule_index).DISCOUNT_LIST            := target_bp_rec.discount_list;
      x_target_bp_tbl(tgt_bp_rule_index).OFFSET_DURATION          := target_bp_rec.offset_duration;
      x_target_bp_tbl(tgt_bp_rule_index).OFFSET_PERIOD            := target_bp_rec.offset_period;
      x_target_bp_tbl(tgt_bp_rule_index).ALLOW_BT_DISCOUNT        := target_bp_rec.allow_bt_discount;
      x_target_bp_tbl(tgt_bp_rule_index).APPLY_DEFAULT_TIMEZONE   := target_bp_rec.apply_default_timezone;

    END LOOP ;

  IF x_source_bp_tbl.count <> x_target_bp_tbl.count Then

    RAISE G_MISMATCH ;
END IF;

IF x_source_bp_tbl.count > 0 then --x_source_bp_tbl.count > 0
    FOR src_bp_rule_index1 IN x_source_bp_tbl.FIRST..x_source_bp_tbl.LAST
    LOOP
       tgt_bp_rule_index1:= x_target_bp_tbl.FIRST ;

       LOOP

         IF     x_source_bp_tbl(src_bp_rule_index1).object1_id1      = x_target_bp_tbl(tgt_bp_rule_index1).object1_id1
         AND    x_source_bp_tbl(src_bp_rule_index1).price_list_id    = x_target_bp_tbl(tgt_bp_rule_index1).price_list_id
         AND    x_source_bp_tbl(src_bp_rule_index1).discount_list    = x_target_bp_tbl(tgt_bp_rule_index1).discount_list
         AND    x_source_bp_tbl(src_bp_rule_index1).offset_duration  = x_target_bp_tbl(tgt_bp_rule_index1).offset_duration
         AND    x_source_bp_tbl(src_bp_rule_index1).offset_period    = x_target_bp_tbl(tgt_bp_rule_index1).offset_period
         AND    x_source_bp_tbl(src_bp_rule_index1).allow_bt_discount = x_target_bp_tbl(tgt_bp_rule_index1).allow_bt_discount
         AND    x_source_bp_tbl(src_bp_rule_index1).apply_default_timezone = x_target_bp_tbl(tgt_bp_rule_index1).apply_default_timezone
        THEN
             l_bp_rule:= 1 ;
                  EXIT ;
             ELSE
             l_bp_rule:= 2 ;
        END IF ;

         EXIT WHEN(tgt_bp_rule_index1 = x_target_bp_tbl.LAST);
         tgt_bp_rule_index1:= x_target_bp_tbl.NEXT(tgt_bp_rule_index1);

         END LOOP ;

         IF l_bp_rule = 2 THEN
            RAISE G_MISMATCH;
         END IF ;

    END LOOP ;

End IF; --x_source_bp_tbl.count > 0

------------------Buss Process OKS LINES--------------------

------------------Coverage Times-------------------------

src_cvr_index:= 0;

FOR I IN l_bp_tbl.FIRST .. l_bp_tbl.LAST LOOP
    FOR C1 IN CUR_GET_COVER_TIMES(l_bp_tbl(I).src_bp_line_id,l_bp_tbl(I).bp_id)   LOOP

    src_cvr_index:= src_cvr_index + 1 ;

  x_source_bp_cover_time_tbl(src_cvr_index).object1_id1  := c1.object1_id1;
  x_source_bp_cover_time_tbl(src_cvr_index).timezone_id  := c1.timezone_id;
  x_source_bp_cover_time_tbl(src_cvr_index).default_yn   := c1.default_yn;
  x_source_bp_cover_time_tbl(src_cvr_index).start_hour   := c1.start_hour;
  x_source_bp_cover_time_tbl(src_cvr_index).start_minute := c1.start_minute;
  x_source_bp_cover_time_tbl(src_cvr_index).end_hour     := c1.end_hour;
  x_source_bp_cover_time_tbl(src_cvr_index).end_minute   := c1.end_minute;
  x_source_bp_cover_time_tbl(src_cvr_index).monday_yn    := c1.monday_yn;
  x_source_bp_cover_time_tbl(src_cvr_index).tuesday_yn   := c1.tuesday_yn;
  x_source_bp_cover_time_tbl(src_cvr_index).wednesday_yn := c1.wednesday_yn;
  x_source_bp_cover_time_tbl(src_cvr_index).thursday_yn  := c1.thursday_yn;
  x_source_bp_cover_time_tbl(src_cvr_index).friday_yn    := c1.friday_yn;
  x_source_bp_cover_time_tbl(src_cvr_index).saturday_yn  := c1.saturday_yn;
  x_source_bp_cover_time_tbl(src_cvr_index).sunday_yn    := c1.sunday_yn;
  END LOOP ;
END LOOP;

  tgt_cvr_index:= 0;
FOR I IN l_bp_tbl.FIRST .. l_bp_tbl.LAST LOOP
  FOR C2 IN CUR_GET_COVER_TIMES(l_bp_tbl(I).tgt_bp_line_id,l_bp_tbl(I).bp_id) LOOP
  tgt_cvr_index:= tgt_cvr_index + 1 ;

  x_target_bp_cover_time_tbl(tgt_cvr_index).object1_id1  := c2.object1_id1;
  x_target_bp_cover_time_tbl(tgt_cvr_index).timezone_id  := c2.timezone_id;
  x_target_bp_cover_time_tbl(tgt_cvr_index).default_yn   := c2.default_yn;
  x_target_bp_cover_time_tbl(tgt_cvr_index).start_hour   := c2.start_hour;
  x_target_bp_cover_time_tbl(tgt_cvr_index).start_minute := c2.start_minute;
  x_target_bp_cover_time_tbl(tgt_cvr_index).end_hour     := c2.end_hour;
  x_target_bp_cover_time_tbl(tgt_cvr_index).end_minute   := c2.end_minute;
  x_target_bp_cover_time_tbl(tgt_cvr_index).monday_yn    := c2.monday_yn;
  x_target_bp_cover_time_tbl(tgt_cvr_index).tuesday_yn   := c2.tuesday_yn;
  x_target_bp_cover_time_tbl(tgt_cvr_index).wednesday_yn := c2.wednesday_yn;
  x_target_bp_cover_time_tbl(tgt_cvr_index).thursday_yn  := c2.thursday_yn;
  x_target_bp_cover_time_tbl(tgt_cvr_index).friday_yn    := c2.friday_yn;
  x_target_bp_cover_time_tbl(tgt_cvr_index).saturday_yn  := c2.saturday_yn;
  x_target_bp_cover_time_tbl(tgt_cvr_index).sunday_yn    := c2.sunday_yn;

  END LOOP ;
END LOOP;
    IF x_source_bp_cover_time_tbl.count <> x_target_bp_cover_time_tbl.count Then

        RAISE G_MISMATCH ;
    END IF;

    IF x_source_bp_cover_time_tbl.count > 0 Then
      FOR src_cvr_index1 IN x_source_bp_cover_time_tbl.FIRST..x_source_bp_cover_time_tbl.LAST   LOOP

        tgt_cvr_index1:= x_target_bp_cover_time_tbl.FIRST ;

        LOOP

        IF  x_source_bp_cover_time_tbl(src_cvr_index1).object1_id1  =  x_target_bp_cover_time_tbl(tgt_cvr_index1).object1_id1
        AND x_source_bp_cover_time_tbl(src_cvr_index1).timezone_id  =  x_target_bp_cover_time_tbl(tgt_cvr_index1).timezone_id
        AND x_source_bp_cover_time_tbl(src_cvr_index1).default_yn   =  x_target_bp_cover_time_tbl(tgt_cvr_index1).default_yn
        AND x_source_bp_cover_time_tbl(src_cvr_index1).start_hour   =  x_target_bp_cover_time_tbl(tgt_cvr_index1).start_hour
        AND x_source_bp_cover_time_tbl(src_cvr_index1).start_minute =  x_target_bp_cover_time_tbl(tgt_cvr_index1).start_minute
        AND x_source_bp_cover_time_tbl(src_cvr_index1).end_hour     =  x_target_bp_cover_time_tbl(tgt_cvr_index1).end_hour
        AND x_source_bp_cover_time_tbl(src_cvr_index1).end_minute   =  x_target_bp_cover_time_tbl(tgt_cvr_index1).end_minute
        AND x_source_bp_cover_time_tbl(src_cvr_index1).monday_yn    =  x_target_bp_cover_time_tbl(tgt_cvr_index1).monday_yn
        AND x_source_bp_cover_time_tbl(src_cvr_index1).tuesday_yn   =  x_target_bp_cover_time_tbl(tgt_cvr_index1).tuesday_yn
        AND x_source_bp_cover_time_tbl(src_cvr_index1).wednesday_yn =  x_target_bp_cover_time_tbl(tgt_cvr_index1).wednesday_yn
        AND x_source_bp_cover_time_tbl(src_cvr_index1).thursday_yn  =  x_target_bp_cover_time_tbl(tgt_cvr_index1).thursday_yn
        AND x_source_bp_cover_time_tbl(src_cvr_index1).friday_yn    =  x_target_bp_cover_time_tbl(tgt_cvr_index1).friday_yn
        AND x_source_bp_cover_time_tbl(src_cvr_index1).saturday_yn  =  x_target_bp_cover_time_tbl(tgt_cvr_index1).saturday_yn
        AND x_source_bp_cover_time_tbl(src_cvr_index1).sunday_yn    =  x_target_bp_cover_time_tbl(tgt_cvr_index1).sunday_yn
        Then
                l_param2:= 1 ;
                EXIT ;
         ELSE
                l_param2:= 2;
        END IF ;

         EXIT WHEN (tgt_cvr_index1 = x_target_bp_cover_time_tbl.LAST);
         tgt_cvr_index1:= x_target_bp_cover_time_tbl.NEXT(tgt_cvr_index1);

         END LOOP ;

            IF l_param2 = 2 Then

                Raise G_Mismatch ;
            END IF ;


      END LOOP ;
    END IF;

------------------ END Coverage Times-------------------------
------------------Reaction Times-------------------------

      src_rcn_index:= 0;
    FOR I IN  l_bp_tbl.FIRST .. l_bp_tbl.LAST LOOP
      FOR C1 IN CUR_GET_REACT_TIMES(l_bp_tbl(I).src_bp_line_id)  LOOP
       src_rcn_index:= src_rcn_index + 1 ;

       x_source_react_time_tbl(src_rcn_index).incident_severity_id    := C1.INCIDENT_SEVERITY_ID;
       x_source_react_time_tbl(src_rcn_index).pdf_id                  := C1.PDF_ID;
       x_source_react_time_tbl(src_rcn_index).work_thru_yn            := C1.WORK_THRU_YN;
       x_source_react_time_tbl(src_rcn_index).react_active_yn         := C1.REACT_ACTIVE_YN;
       x_source_react_time_tbl(src_rcn_index).react_time_name         := C1.REACT_TIME_NAME;
       x_source_react_time_tbl(src_rcn_index).action_type_code        := C1.ACTION_TYPE_CODE;
       x_source_react_time_tbl(src_rcn_index).uom_code                := C1.UOM_CODE;
       x_source_react_time_tbl(src_rcn_index).sun_duration            := C1.SUN_DURATION;
       x_source_react_time_tbl(src_rcn_index).mon_duration            := C1.MON_DURATION;
       x_source_react_time_tbl(src_rcn_index).tue_duration            := C1.TUE_DURATION;
       x_source_react_time_tbl(src_rcn_index).wed_duration            := C1.WED_DURATION;
       x_source_react_time_tbl(src_rcn_index).thu_duration            := C1.THU_DURATION;
       x_source_react_time_tbl(src_rcn_index).fri_duration            := C1.FRI_DURATION;
       x_source_react_time_tbl(src_rcn_index).sat_duration            := C1.WED_DURATION;

      END LOOP ;
    END LOOP;

        tgt_rcn_index:= 0;
    FOR I IN  l_bp_tbl.FIRST .. l_bp_tbl.LAST LOOP
      FOR C2 IN CUR_GET_REACT_TIMES(l_bp_tbl(I).tgt_bp_line_id)  LOOP
      tgt_rcn_index := tgt_rcn_index + 1;

       x_target_react_time_tbl(tgt_rcn_index).incident_severity_id    := C2.INCIDENT_SEVERITY_ID;
       x_target_react_time_tbl(tgt_rcn_index).pdf_id                  := C2.PDF_ID;
       x_target_react_time_tbl(tgt_rcn_index).work_thru_yn            := C2.WORK_THRU_YN;
       x_target_react_time_tbl(tgt_rcn_index).react_active_yn         := C2.REACT_ACTIVE_YN;
       x_target_react_time_tbl(tgt_rcn_index).react_time_name         := C2.REACT_TIME_NAME;
       x_target_react_time_tbl(tgt_rcn_index).action_type_code        := C2.ACTION_TYPE_CODE;
       x_target_react_time_tbl(tgt_rcn_index).uom_code                := C2.UOM_CODE;
       x_target_react_time_tbl(tgt_rcn_index).sun_duration            := C2.SUN_DURATION;
       x_target_react_time_tbl(tgt_rcn_index).mon_duration            := C2.MON_DURATION;
       x_target_react_time_tbl(tgt_rcn_index).tue_duration            := C2.TUE_DURATION;
       x_target_react_time_tbl(tgt_rcn_index).wed_duration            := C2.WED_DURATION;
       x_target_react_time_tbl(tgt_rcn_index).thu_duration            := C2.THU_DURATION;
       x_target_react_time_tbl(tgt_rcn_index).fri_duration            := C2.FRI_DURATION;
       x_target_react_time_tbl(tgt_rcn_index).sat_duration            := C2.WED_DURATION;

      END LOOP ;
    END LOOP;

   -- NOW COMPARE THE SOURCE AND TARGET RCN TABLES

   IF x_source_react_time_tbl.count <> x_target_react_time_tbl.count Then
         RAISE G_MISMATCH ;
   END IF ;
If x_source_react_time_tbl.count > 0 Then
 FOR src_rcn_index1 IN x_source_react_time_tbl.FIRST..x_source_react_time_tbl.LAST
 LOOP
    tgt_rcn_index1:= x_target_react_time_tbl.FIRST;
    LOOP

      IF x_source_react_time_tbl(src_rcn_index1).incident_severity_id = x_target_react_time_tbl(tgt_rcn_index1).incident_severity_id
      AND x_source_react_time_tbl(src_rcn_index1).pdf_id              = x_target_react_time_tbl(tgt_rcn_index1).pdf_id
      AND x_source_react_time_tbl(src_rcn_index1).work_thru_yn        = x_target_react_time_tbl(tgt_rcn_index1).work_thru_yn
      AND x_source_react_time_tbl(src_rcn_index1).react_active_yn     = x_target_react_time_tbl(tgt_rcn_index1).react_active_yn
      AND x_source_react_time_tbl(src_rcn_index1).react_time_name     = x_target_react_time_tbl(tgt_rcn_index1).react_time_name
      AND x_source_react_time_tbl(src_rcn_index1).action_type_code    = x_target_react_time_tbl(tgt_rcn_index1).action_type_code
      AND x_source_react_time_tbl(src_rcn_index1).uom_code            = x_target_react_time_tbl(tgt_rcn_index1).uom_code
      AND x_source_react_time_tbl(src_rcn_index1).sun_duration        = x_target_react_time_tbl(tgt_rcn_index1).sun_duration
      AND x_source_react_time_tbl(src_rcn_index1).mon_duration        = x_target_react_time_tbl(tgt_rcn_index1).mon_duration
      AND x_source_react_time_tbl(src_rcn_index1).tue_duration        = x_target_react_time_tbl(tgt_rcn_index1).tue_duration
      AND x_source_react_time_tbl(src_rcn_index1).wed_duration        = x_target_react_time_tbl(tgt_rcn_index1).wed_duration
      AND x_source_react_time_tbl(src_rcn_index1).thu_duration        = x_target_react_time_tbl(tgt_rcn_index1).thu_duration
      AND x_source_react_time_tbl(src_rcn_index1).fri_duration        = x_target_react_time_tbl(tgt_rcn_index1).fri_duration
      AND x_source_react_time_tbl(src_rcn_index1).sat_duration        = x_target_react_time_tbl(tgt_rcn_index1).sat_duration
       Then
         l_rcn:= 1 ;
             EXIT ;

         ELSE
           l_rcn:= 2 ;
         END IF ;

          EXIT WHEN(tgt_rcn_index1 = x_target_react_time_tbl.LAST);
          tgt_rcn_index1:= x_target_react_time_tbl.NEXT(tgt_rcn_index1);


            END LOOP ; -- inner loop

          IF l_rcn = 2 Then
              Raise G_Mismatch ;
            END IF ;
       END LOOP ;
End If;
------------------ END Reaction Times-------------------------

-------------------BILL TYPES/RATES--------------------------


   src_bill_type_index:= 0 ;
    FOR I IN   l_bp_tbl.FIRST .. l_bp_tbl.LAST LOOP
        FOR C1 IN CUR_GET_BILL_TYPES(l_bp_tbl(I).src_bp_line_id)   LOOP

            src_bill_type_index:= src_bill_type_index + 1 ;

            x_source_bill_tbl(src_bill_type_index).object1_id1       := C1.OBJECT1_ID1;
            x_source_bill_tbl(src_bill_type_index).bill_type_line_id := C1.BILL_TYPE_LINE_ID;
            x_source_bill_tbl(src_bill_type_index).billing_type      := C1.BILLING_TYPE;
            x_source_bill_tbl(src_bill_type_index).discount_amount   := C1.DISCOUNT_AMOUNT;
            x_source_bill_tbl(src_bill_type_index).discount_percent  := C1.DISCOUNT_PERCENT;
        END LOOP ;
    END LOOP;

     tgt_bill_type_index:= 0;

    FOR I IN   l_bp_tbl.FIRST .. l_bp_tbl.LAST LOOP
        FOR C2 IN CUR_GET_BILL_TYPES(l_bp_tbl(I).tgt_bp_line_id)   LOOP
        tgt_bill_type_index:= tgt_bill_type_index + 1 ;
        x_target_bill_tbl(tgt_bill_type_index).object1_id1       := C2.OBJECT1_ID1;
        x_target_bill_tbl(tgt_bill_type_index).bill_type_line_id := C2.BILL_TYPE_LINE_ID;
        x_target_bill_tbl(tgt_bill_type_index).billing_type      := C2.BILLING_TYPE;
        x_target_bill_tbl(tgt_bill_type_index).discount_amount   := C2.DISCOUNT_AMOUNT;
        x_target_bill_tbl(tgt_bill_type_index).discount_percent   := C2.DISCOUNT_PERCENT;
        END LOOP ;
    END LOOP;


IF x_source_bill_tbl.count <> x_target_bill_tbl.count Then

     RAISE G_MISMATCH ;
END IF ;

IF x_source_bill_tbl.count > 0 Then
   FOR  src_bill_type_index1 IN x_source_bill_tbl.FIRST..x_source_bill_tbl.LAST   LOOP

         tgt_bill_type_index1:= x_target_bill_tbl.FIRST ;

         LOOP

         IF  ((x_source_bill_tbl(src_bill_type_index1).object1_id1     = x_target_bill_tbl(tgt_bill_type_index1).object1_id1)
         AND (x_source_bill_tbl(src_bill_type_index1).billing_type    = x_target_bill_tbl(tgt_bill_type_index1).billing_type)
         AND (x_source_bill_tbl(src_bill_type_index1).discount_amount = x_target_bill_tbl(tgt_bill_type_index1).discount_amount)
         AND (x_source_bill_tbl(src_bill_type_index1).discount_percent = x_target_bill_tbl(tgt_bill_type_index1).discount_percent))
         Then

              l_bill_type:= 1 ;

              IF x_source_bill_tbl(src_bill_type_index1).billing_type = 'L' THEN
                  l_src_bill_rate_line_id:= x_source_bill_tbl(src_bill_type_index1).bill_type_line_id ;

                 src_bill_rate_index:= 0;


               FOR src_brs_rec IN CUR_GET_BRS(l_src_bill_rate_line_id)  LOOP
              src_bill_rate_index:= src_bill_rate_index + 1 ;

              x_source_brs_tbl(src_bill_rate_index).START_HOUR        := src_brs_rec.START_HOUR;
              x_source_brs_tbl(src_bill_rate_index).START_MINUTE      := src_brs_rec.START_MINUTE;
              x_source_brs_tbl(src_bill_rate_index).END_HOUR          := src_brs_rec.END_HOUR;
              x_source_brs_tbl(src_bill_rate_index).END_MINUTE        := src_brs_rec.END_MINUTE;
              x_source_brs_tbl(src_bill_rate_index).MONDAY_FLAG       := src_brs_rec.MONDAY_FLAG;
              x_source_brs_tbl(src_bill_rate_index).TUESDAY_FLAG      := src_brs_rec.TUESDAY_FLAG;
              x_source_brs_tbl(src_bill_rate_index).WEDNESDAY_FLAG    := src_brs_rec.WEDNESDAY_FLAG;
              x_source_brs_tbl(src_bill_rate_index).THURSDAY_FLAG     := src_brs_rec.THURSDAY_FLAG;
              x_source_brs_tbl(src_bill_rate_index).FRIDAY_FLAG       := src_brs_rec.FRIDAY_FLAG;
              x_source_brs_tbl(src_bill_rate_index).SATURDAY_FLAG     := src_brs_rec.SATURDAY_FLAG;
              x_source_brs_tbl(src_bill_rate_index).SUNDAY_FLAG       := src_brs_rec.SUNDAY_FLAG;
              x_source_brs_tbl(src_bill_rate_index).OBJECT1_ID1       := src_brs_rec.OBJECT1_ID1;
              x_source_brs_tbl(src_bill_rate_index).OBJECT1_ID2       := src_brs_rec.OBJECT1_ID2;
              x_source_brs_tbl(src_bill_rate_index).JTOT_OBJECT1_CODE := src_brs_rec.JTOT_OBJECT1_CODE;
              x_source_brs_tbl(src_bill_rate_index).BILL_RATE_CODE    := src_brs_rec.BILL_RATE_CODE;
              x_source_brs_tbl(src_bill_rate_index).FLAT_RATE         := src_brs_rec.FLAT_RATE;
              x_source_brs_tbl(src_bill_rate_index).UOM               := src_brs_rec.UOM;
              x_source_brs_tbl(src_bill_rate_index).HOLIDAY_YN        := src_brs_rec.HOLIDAY_YN;
              x_source_brs_tbl(src_bill_rate_index).PERCENT_OVER_LIST_PRICE  := src_brs_rec.PERC_OVER_LIST_PRICE;

                END LOOP ;

          l_tgt_bill_rate_line_id:= x_target_bill_tbl(tgt_bill_type_index1).bill_type_line_id ;

             tgt_bill_rate_index:= 0;

             FOR tgt_brs_rec IN CUR_GET_BRS(l_tgt_bill_rate_line_id)    LOOP
             tgt_bill_rate_index:= tgt_bill_rate_index + 1 ;

              x_target_brs_tbl(tgt_bill_rate_index).START_HOUR        := tgt_brs_rec.START_HOUR;
              x_target_brs_tbl(tgt_bill_rate_index).START_MINUTE      := tgt_brs_rec.START_MINUTE;
              x_target_brs_tbl(tgt_bill_rate_index).END_HOUR          := tgt_brs_rec.END_HOUR;
              x_target_brs_tbl(tgt_bill_rate_index).END_MINUTE        := tgt_brs_rec.END_MINUTE;
              x_target_brs_tbl(tgt_bill_rate_index).MONDAY_FLAG       := tgt_brs_rec.MONDAY_FLAG;
              x_target_brs_tbl(tgt_bill_rate_index).TUESDAY_FLAG      := tgt_brs_rec.TUESDAY_FLAG;
              x_target_brs_tbl(tgt_bill_rate_index).WEDNESDAY_FLAG    := tgt_brs_rec.WEDNESDAY_FLAG;
              x_target_brs_tbl(tgt_bill_rate_index).THURSDAY_FLAG     := tgt_brs_rec.THURSDAY_FLAG;
              x_target_brs_tbl(tgt_bill_rate_index).FRIDAY_FLAG       := tgt_brs_rec.FRIDAY_FLAG;
              x_target_brs_tbl(tgt_bill_rate_index).SATURDAY_FLAG     := tgt_brs_rec.SATURDAY_FLAG;
              x_target_brs_tbl(tgt_bill_rate_index).SUNDAY_FLAG       := tgt_brs_rec.SUNDAY_FLAG;
              x_target_brs_tbl(tgt_bill_rate_index).OBJECT1_ID1       := tgt_brs_rec.OBJECT1_ID1;
              x_target_brs_tbl(tgt_bill_rate_index).OBJECT1_ID2       := tgt_brs_rec.OBJECT1_ID2;
              x_target_brs_tbl(tgt_bill_rate_index).JTOT_OBJECT1_CODE := tgt_brs_rec.JTOT_OBJECT1_CODE;
              x_target_brs_tbl(tgt_bill_rate_index).BILL_RATE_CODE    := tgt_brs_rec.BILL_RATE_CODE;
              x_target_brs_tbl(tgt_bill_rate_index).FLAT_RATE         := tgt_brs_rec.FLAT_RATE;
              x_target_brs_tbl(tgt_bill_rate_index).UOM               := tgt_brs_rec.UOM;
              x_target_brs_tbl(tgt_bill_rate_index).HOLIDAY_YN        := tgt_brs_rec.HOLIDAY_YN;
              x_target_brs_tbl(tgt_bill_rate_index).PERCENT_OVER_LIST_PRICE  := tgt_brs_rec.PERC_OVER_LIST_PRICE;

          END LOOP ;

              IF   x_source_brs_tbl.count <> x_target_brs_tbl.count Then

                  RAISE G_MISMATCH ;
             END IF ;



         IF x_source_brs_tbl.count > 0 Then
         FOR  src_bill_rate_index1 IN x_source_brs_tbl.FIRST..x_source_brs_tbl.LAST
         LOOP
         tgt_bill_rate_index1:= x_target_brs_tbl.FIRST ;

            LOOP
               IF x_source_brs_tbl(src_bill_rate_index1).START_HOUR = x_target_brs_tbl(tgt_bill_rate_index1).START_HOUR
          AND x_source_brs_tbl(src_bill_rate_index1).START_MINUTE = x_target_brs_tbl(tgt_bill_rate_index1).START_MINUTE
          AND x_source_brs_tbl(src_bill_rate_index1).END_HOUR = x_target_brs_tbl(tgt_bill_rate_index1).END_HOUR
          AND x_source_brs_tbl(src_bill_rate_index1).END_MINUTE = x_target_brs_tbl(tgt_bill_rate_index1).END_MINUTE
          AND x_source_brs_tbl(src_bill_rate_index1).MONDAY_FLAG = x_target_brs_tbl(tgt_bill_rate_index1).MONDAY_FLAG
          AND x_source_brs_tbl(src_bill_rate_index1).TUESDAY_FLAG = x_target_brs_tbl(tgt_bill_rate_index1).TUESDAY_FLAG
          AND x_source_brs_tbl(src_bill_rate_index1).WEDNESDAY_FLAG = x_target_brs_tbl(tgt_bill_rate_index1).WEDNESDAY_FLAG
          AND x_source_brs_tbl(src_bill_rate_index1).THURSDAY_FLAG = x_target_brs_tbl(tgt_bill_rate_index1).THURSDAY_FLAG
          AND x_source_brs_tbl(src_bill_rate_index1).FRIDAY_FLAG = x_target_brs_tbl(tgt_bill_rate_index1).FRIDAY_FLAG
          AND x_source_brs_tbl(src_bill_rate_index1).SATURDAY_FLAG = x_target_brs_tbl(tgt_bill_rate_index1).SATURDAY_FLAG
          AND x_source_brs_tbl(src_bill_rate_index1).SUNDAY_FLAG = x_target_brs_tbl(tgt_bill_rate_index1).SUNDAY_FLAG
          AND x_source_brs_tbl(src_bill_rate_index1).OBJECT1_ID1 = x_target_brs_tbl(tgt_bill_rate_index1).OBJECT1_ID1
          AND x_source_brs_tbl(src_bill_rate_index1).OBJECT1_ID2 = x_target_brs_tbl(tgt_bill_rate_index1).OBJECT1_ID2
          AND x_source_brs_tbl(src_bill_rate_index1).JTOT_OBJECT1_CODE = x_target_brs_tbl(tgt_bill_rate_index1).JTOT_OBJECT1_CODE
          AND x_source_brs_tbl(src_bill_rate_index1).BILL_RATE_CODE = x_target_brs_tbl(tgt_bill_rate_index1).BILL_RATE_CODE
          AND x_source_brs_tbl(src_bill_rate_index1).FLAT_RATE = x_target_brs_tbl(tgt_bill_rate_index1).FLAT_RATE
          AND x_source_brs_tbl(src_bill_rate_index1).UOM = x_target_brs_tbl(tgt_bill_rate_index1).UOM
          AND x_source_brs_tbl(src_bill_rate_index1).HOLIDAY_YN = x_target_brs_tbl(tgt_bill_rate_index1).HOLIDAY_YN
          AND x_source_brs_tbl(src_bill_rate_index1).PERCENT_OVER_LIST_PRICE = x_target_brs_tbl(tgt_bill_rate_index1).PERCENT_OVER_LIST_PRICE
          Then

          l_bill_rate:= 1 ;

          EXIT ;

          ELSE
           l_bill_rate:= 2 ;
       END IF ;

       EXIT WHEN(tgt_bill_rate_index1 = x_target_brs_tbl.LAST);
       tgt_bill_rate_index1:= x_target_brs_tbl.NEXT(tgt_bill_rate_index1);

       END LOOP ;
       IF l_bill_rate =  2 Then

            RAISE G_MISMATCH ;
        END IF ;
       END LOOP ;
       End if;
          END IF ;  -- for labor type = 'L'
        EXIT ;

            ELSE
            l_bill_type:= 2 ;
      END IF ;

       EXIT WHEN(tgt_bill_type_index1 = x_target_bill_tbl.LAST);
                 tgt_bill_type_index1:= x_target_bill_tbl.NEXT(tgt_bill_type_index1);

           END LOOP ;      -- INNER LOOP
      IF l_bill_type = 2 Then

         Raise G_Mismatch ;
    END IF ;
       END LOOP ; -- outer loop
  End If;

-------------------END BILL TYPES/RATES--------------------------

x_source_bp_tbl.DELETE;
x_target_bp_tbl.DELETE;
x_source_res_tbl_type.DELETE;
x_target_res_tbl_type.DELETE;
x_source_bp_cover_time_tbl.DELETE;
x_target_bp_cover_time_tbl.DELETE;
x_source_react_time_tbl.DELETE;
x_target_react_time_tbl.DELETE;
x_source_bill_tbl.DELETE;
x_target_bill_tbl.DELETE;
x_source_brs_tbl.DELETE;
x_target_brs_tbl.DELETE;



     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     x_coverage_match:= 'Y';

 Exception

  When G_MISMATCH THEN
     x_coverage_match:= 'N';
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;

   WHEN OTHERS THEN
     OKC_API.set_message(G_APP_NAME,
			  G_UNEXPECTED_ERROR,
			  G_SQLCODE_TOKEN,
			  SQLCODE,
			  G_SQLERRM_TOKEN,
			  SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      x_coverage_match:= 'E';


END CHECK_COVERAGE_MATCH;

Procedure CHECK_TimeZone_Exists
   ( p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_BP_Line_ID	   	    IN NUMBER,
    P_TimeZone_Id  			IN NUMBER,
    x_TimeZone_Exists       OUT NOCOPY VARCHAR2) IS

		l_Cle_ID        NUMBER;
		l_timezone_id   NUMBER;
		l_dummy         VARCHAR2(1) := NULL;

		CURSOR Check_CovTime_Zone(l_cle_id IN NUMBER,l_timezone_id IN NUMBER) IS
		SELECT 'X'
		FROM    OKS_COVERAGE_TIMEZONES
		WHERE   cle_id = l_cle_id
		AND     timezone_id = l_timezone_id;

BEGIN

		l_Cle_ID := P_BP_Line_ID;
		l_timezone_id := P_TimeZone_Id;

		OPEN Check_CovTime_Zone(l_Cle_ID,l_timezone_id);
			FETCH Check_CovTime_Zone INTO l_dummy;
		CLOSE Check_CovTime_Zone;

				IF l_dummy = 'X' THEN
					x_TimeZone_Exists := 'Y';
				ELSE
   		 			x_TimeZone_Exists := 'N';
				END IF;

     	x_return_status:= OKC_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN

    OKC_API.SET_MESSAGE(
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	        => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


END CHECK_TimeZone_Exists;




PROCEDURE  CREATE_ADJUSTED_COVERAGE(
    p_api_version     IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Source_contract_Line_Id       IN NUMBER,
    P_Target_contract_Line_Id       IN NUMBER,
    x_Actual_coverage_id    OUT NOCOPY NUMBER) IS

  CURSOR Cur_LineDet (P_Line_Id IN NUMBER) IS
  SELECT ID FROM OKC_K_LINES_v
  WHERE CLE_ID= P_Line_Id
  AND   LSE_ID in (2,15,20);

  CURSOR Cur_LineDet1 (P_Line_Id IN NUMBER) IS
  SELECT Start_Date,End_Date FROM OKC_K_LINES_v
  WHERE ID= P_Line_Id;

  l_cov_id                         OKC_K_LINES_V.ID%TYPE;
  l_start_date                     OKC_K_LINES_V.START_DATE%TYPE;
  l_end_date                       OKC_K_LINES_V.END_DATE%TYPE;

  l_api_version		               CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	               CONSTANT	VARCHAR2(1):= 'F';
  l_return_status	               VARCHAR2(1);
  l_msg_count		               NUMBER;
  l_msg_data		               VARCHAR2(2000):=null;
  l_msg_index_out                  Number;
  l_Source_contract_Line_Id        CONSTANT	NUMBER     := P_Source_contract_Line_Id;
  l_Target_contract_Line_Id        CONSTANT	NUMBER     := P_Target_contract_Line_Id;
  l_Actual_coverage_id             NUMBER;
  l_api_name                       CONSTANT VARCHAR2(30) := 'create_adjusted_coverage';
  l_ac_rec_in                      OKS_COVERAGES_PVT.ac_rec_type;

-----------------------------------------
BEGIN


  IF (G_DEBUG_ENABLED = 'Y') THEN
        okc_debug.Set_Indentation('Create_Adjusted_Coverage');
        okc_debug.log('Entered Create_Adjusted_Coverage', 2);
  END IF;

  l_ac_rec_in.svc_cle_id    := l_Target_contract_Line_Id;


  OPEN Cur_LineDet(l_Source_contract_Line_Id);
  FETCH Cur_LineDet INTO l_cov_Id;
  IF Cur_LineDet%FOUND
  THEN
     l_ac_rec_in.tmp_cle_id := l_cov_Id;
  ELSE
    OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Coverage does not exist');
    CLOSE Cur_LineDet;
    l_return_status := OKC_API.G_RET_STS_ERROR;
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
  CLOSE Cur_LineDet;

  OPEN Cur_LineDet1(l_Target_contract_Line_Id);
  FETCH Cur_LineDet1 INTO l_start_date,l_end_date;
  IF Cur_LineDet1%FOUND
  THEN
     l_ac_rec_in.Start_date := l_Start_date;
     l_ac_rec_in.End_date   := l_End_date;
  ELSE
    OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Target contract line does not exist');
    CLOSE Cur_LineDet1;
    l_return_status := OKC_API.G_RET_STS_ERROR;
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
  CLOSE Cur_LineDet1;

  IF (G_DEBUG_ENABLED = 'Y') THEN
            okc_debug.log('Before create_actual_coverage', 2);
  END IF;

    OKS_COVERAGES_PVT.CREATE_ACTUAL_COVERAGE(
                p_api_version           => l_api_version,
                p_init_msg_list         => 'F',
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data,
                p_ac_rec_in             => l_ac_rec_in,
                p_restricted_update     => 'T',   -- 'F', modified based on bug 5493713
                x_Actual_coverage_id    => l_Actual_coverage_id);

  IF (G_DEBUG_ENABLED = 'Y') THEN
            okc_debug.log('After create_actual_coverage '||l_return_status, 2);
  END IF;

   /*  IF nvl(l_return_status,'*') <> 'S'
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
        END IF;*/

      IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      x_return_status         := l_return_status;
      x_Actual_coverage_id    := l_Actual_coverage_id;



      IF (G_DEBUG_ENABLED = 'Y') THEN
           okc_debug.log('End of CREATE_ADJUSTED_COVERAGE'||l_return_status, 2);
           okc_debug.Reset_Indentation;
      END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN

      IF (G_DEBUG_ENABLED = 'Y') THEN
           okc_debug.log('Exp of CREATE_ADJUSTED_COVERAGE'||SQLERRM, 2);
           okc_debug.Reset_Indentation;
      END IF;
      x_return_status := l_return_status ;
  /*    x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Create_actual_coverage',
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Create_actual_coverage',
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Create_actual_coverage',
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */

 WHEN OTHERS THEN

      IF (G_DEBUG_ENABLED = 'Y') THEN
           okc_debug.log('Exp of CREATE_ADJUSTED_COVERAGE'||SQLERRM, 2);
           okc_debug.Reset_Indentation;
      END IF;

      OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1	        => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
       -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count :=l_msg_count;
 END CREATE_ADJUSTED_COVERAGE;

 --=============================================================================

 PROCEDURE INIT_BILL_RATE_LINE(x_bill_rate_tbl OUT  NOCOPY OKS_BRS_PVT.OKSBILLRATESCHEDULESVTBLTYPE)
IS

BEGIN

x_bill_rate_tbl(1).id        := okc_api.g_miss_num ;
x_bill_rate_tbl(1).cle_id    := okc_api.g_miss_num ;
x_bill_rate_tbl(1).bt_cle_id    := okc_api.g_miss_num ;
x_bill_rate_tbl(1).dnz_chr_id   := okc_api.g_miss_num;
x_bill_rate_tbl(1).start_hour    := okc_api.g_miss_num ;
x_bill_rate_tbl(1).start_minute    := okc_api.g_miss_num ;
x_bill_rate_tbl(1).end_hour    := okc_api.g_miss_num ;
x_bill_rate_tbl(1).end_minute    := okc_api.g_miss_num ;
x_bill_rate_tbl(1).monday_flag    := okc_api.g_miss_char ;
x_bill_rate_tbl(1).tuesday_flag    := okc_api.g_miss_char ;
x_bill_rate_tbl(1).wednesday_flag    := okc_api.g_miss_char ;
x_bill_rate_tbl(1).thursday_flag    := okc_api.g_miss_char ;
x_bill_rate_tbl(1).friday_flag    := okc_api.g_miss_char ;
x_bill_rate_tbl(1).saturday_flag    := okc_api.g_miss_char ;
x_bill_rate_tbl(1).sunday_flag    := okc_api.g_miss_char ;
x_bill_rate_tbl(1).object1_id1    := okc_api.g_miss_char ;
x_bill_rate_tbl(1).object1_id2    := okc_api.g_miss_char ;
x_bill_rate_tbl(1).jtot_object1_code    := okc_api.g_miss_char ;
x_bill_rate_tbl(1).bill_rate_code    := okc_api.g_miss_char ;
x_bill_rate_tbl(1).flat_rate    := okc_api.g_miss_num ;
x_bill_rate_tbl(1).uom    := okc_api.g_miss_char ;
x_bill_rate_tbl(1).holiday_yn    := okc_api.g_miss_char ;
x_bill_rate_tbl(1).percent_over_list_price    := okc_api.g_miss_num ;
x_bill_rate_tbl(1).program_application_id := okc_api.g_miss_num ;
x_bill_rate_tbl(1).program_id                  := okc_api.g_miss_num ;
x_bill_rate_tbl(1).program_update_date     := okc_api.g_miss_date ;
x_bill_rate_tbl(1).request_id              := okc_api.g_miss_num ;
x_bill_rate_tbl(1).created_by    := okc_api.g_miss_num ;
x_bill_rate_tbl(1).creation_date    := okc_api.g_miss_date ;
x_bill_rate_tbl(1).last_updated_by    := okc_api.g_miss_num ;
x_bill_rate_tbl(1).last_update_date    := okc_api.g_miss_date ;
x_bill_rate_tbl(1).last_update_login    := okc_api.g_miss_num ;
x_bill_rate_tbl(1).security_group_id    := okc_api.g_miss_num ;

END ;
--===========================================================================================

PROCEDURE Validate_billrate_schedule(p_billtype_line_id IN NUMBER,
                                     p_holiday_yn IN varchar2,
                                     x_days_overlap OUT  NOCOPY billrate_day_overlap_type,
                                     x_return_status OUT  NOCOPY VARCHAR2)
IS

TYPE billrate_schedule_rec IS RECORD
 (start_time NUMBER,
  end_time NUMBER);
TYPE billrate_schedule_tbl_type IS TABLE OF billrate_schedule_rec
INDEX BY BINARY_INTEGER;
i number := 0;
l_overlap_yn varchar2(1);
l_overlap_message   VARCHAR2(200);

l_time_tbl   billrate_schedule_tbl_type;
l_api_name VARCHAR2(50):= 'VALIDATE_BILLRATE_SCHEDULE';
x_msg_count NUMBER;
x_msg_data VARCHAR2(2000);
l_overlap_days varchar2(1000) := NULL;

CURSOR Cur_monday(l_bt_id IN NUMBER, l_holiday IN Varchar2) IS
SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_BILLRATE_SCHEDULES_V
WHERE BT_CLE_ID = l_bt_id
AND MONDAY_FLAG = 'Y'
AND holiday_yn = l_holiday;

CURSOR Cur_tuesday(l_bt_id IN NUMBER, l_holiday IN Varchar2) IS
SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_BILLRATE_SCHEDULES_V
WHERE BT_CLE_ID = l_bt_id
AND TUESDAY_FLAG = 'Y'
AND holiday_yn = l_holiday;

CURSOR Cur_wednesday(l_bt_id IN NUMBER, l_holiday IN Varchar2) IS
SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_BILLRATE_SCHEDULES_V
WHERE BT_CLE_ID = l_bt_id
AND WEDNESDAY_FLAG = 'Y'
AND holiday_yn = l_holiday;

CURSOR Cur_thursday(l_bt_id IN NUMBER, l_holiday IN Varchar2) IS
SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_BILLRATE_SCHEDULES_V
WHERE BT_CLE_ID = l_bt_id
AND THURSDAY_FLAG = 'Y'
AND holiday_yn = l_holiday;

CURSOR Cur_friday(l_bt_id IN NUMBER, l_holiday IN Varchar2) IS
SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_BILLRATE_SCHEDULES_V
WHERE BT_CLE_ID = l_bt_id
AND FRIDAY_FLAG = 'Y'
AND holiday_yn = l_holiday;

CURSOR Cur_saturday(l_bt_id IN NUMBER, l_holiday IN Varchar2) IS
SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_BILLRATE_SCHEDULES_V
WHERE BT_CLE_ID = l_bt_id
AND SATURDAY_FLAG = 'Y'
AND holiday_yn = l_holiday;

CURSOR Cur_sunday(l_bt_id IN NUMBER, l_holiday IN Varchar2) IS
SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_BILLRATE_SCHEDULES_V
WHERE BT_CLE_ID = l_bt_id
AND SUNDAY_FLAG = 'Y'
AND holiday_yn = l_holiday;

--Define cursors for other days.
FUNCTION get_day_meaning (p_day_code IN varchar2)
RETURN varchar2
IS
CURSOR Get_day IS
SELECT meaning from fnd_lookups where lookup_type = 'DAY_NAME'
and lookup_code = p_day_code;
l_day_meaning VARCHAR2(100);

BEGIN
  OPEN Get_day;
  FETCH Get_day INTO l_day_meaning;
  CLOSE Get_day;
  return nvl(l_day_meaning,NULL);
end get_day_meaning ;

PROCEDURE Check_overlap(p_time_tbl IN billrate_schedule_tbl_type,
                        p_overlap_yn OUT NOCOPY Varchar2)
IS

l_start NUMBER;
l_end   NUMBER;

l_start_new NUMBER;
l_end_new   NUMBER;
j number := 0;
k number := 0;

BEGIN
p_overlap_yn := 'N';
FOR j in 1 .. p_time_tbl.COUNT
LOOP
l_start := p_time_tbl(j).start_time;
l_end := p_time_tbl(j).end_time;

  FOR k in 1 .. p_time_tbl.COUNT
  LOOP
        l_start_new := p_time_tbl(k).start_time;
        l_end_new := p_time_tbl(k).end_time;
        IF j <> k then
                IF (l_start_new <= l_end and l_start_new >= l_start)
            OR (l_end_new >= l_start and l_end_new <=  l_end) then

            IF (l_start_new = l_end )
                   OR (l_end_new = l_start ) then
                    IF p_overlap_yn <> 'Y' then
                       p_overlap_yn := 'N';
                    END IF ;
                 else
                    p_overlap_yn := 'Y';
             END IF ;


          END IF;
        END IF;
  END LOOP;

END LOOP;


--write the validation logic
END Check_overlap;


BEGIN
--l_overlap_message := 'The following days have overlap :';
-- Validating for Monday.
x_return_status         := OKC_API.G_RET_STS_SUCCESS;
l_time_tbl.DELETE;
FOR monday_rec IN Cur_monday(p_billtype_line_id, p_holiday_yn)
LOOP

i := i + 1;
l_time_tbl(i).start_time := monday_rec.start_time;
l_time_tbl(i).end_time := monday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';

IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.monday_overlap);

   IF x_days_overlap.monday_overlap = 'Y' then
      l_overlap_days := get_day_meaning('MON')||',';
   END IF;

end if;

-- Validating for Tuesday.

l_time_tbl.DELETE;
i := 0;

FOR tuesday_rec IN Cur_tuesday(p_billtype_line_id, p_holiday_yn)
LOOP
i := i + 1;
l_time_tbl(i).start_time := tuesday_rec.start_time;
l_time_tbl(i).end_time := tuesday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';
IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.tuesday_overlap);
   IF x_days_overlap.tuesday_overlap = 'Y' then
      l_overlap_days := l_overlap_days||get_day_meaning('TUE')||',';
   END IF;

end if;

-- Validating for wednesday.

l_time_tbl.DELETE;
i := 0;

FOR wednesday_rec IN Cur_wednesday(p_billtype_line_id, p_holiday_yn)
LOOP
i := i + 1;
l_time_tbl(i).start_time := wednesday_rec.start_time;
l_time_tbl(i).end_time := wednesday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';
IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.wednesday_overlap);
   IF x_days_overlap.wednesday_overlap = 'Y' then
      l_overlap_days := l_overlap_days||get_day_meaning('WED')||',';
   END IF;

end if;

-- Validating for thursday.

l_time_tbl.DELETE;
i := 0;

FOR thursday_rec IN Cur_thursday(p_billtype_line_id, p_holiday_yn)
LOOP
i := i + 1;
l_time_tbl(i).start_time := thursday_rec.start_time;
l_time_tbl(i).end_time := thursday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';
IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.thursday_overlap);
   IF x_days_overlap.thursday_overlap = 'Y' then
      l_overlap_days := l_overlap_days||get_day_meaning('THU')||',';
   END IF;

end if;

-- Validating for friday.

l_time_tbl.DELETE;
i := 0;

FOR friday_rec IN Cur_friday(p_billtype_line_id, p_holiday_yn)
LOOP
i := i + 1;
l_time_tbl(i).start_time := friday_rec.start_time;
l_time_tbl(i).end_time := friday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';
IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.friday_overlap);
   IF x_days_overlap.friday_overlap = 'Y' then
      l_overlap_days := l_overlap_days||get_day_meaning('FRI')||',';
   END IF;

end if;

-- Validating for saturday.

l_time_tbl.DELETE;
i := 0;

FOR saturday_rec IN Cur_saturday(p_billtype_line_id, p_holiday_yn)
LOOP
i := i + 1;
l_time_tbl(i).start_time := saturday_rec.start_time;
l_time_tbl(i).end_time := saturday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';
IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.saturday_overlap);
   IF x_days_overlap.saturday_overlap = 'Y' then
      l_overlap_days := l_overlap_days||get_day_meaning('SAT')||',';
   END IF;

end if;

-- Validating for sunday.

l_time_tbl.DELETE;
i := 0;

FOR sunday_rec IN Cur_sunday(p_billtype_line_id, p_holiday_yn)
LOOP
i := i + 1;
l_time_tbl(i).start_time := sunday_rec.start_time;
l_time_tbl(i).end_time := sunday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';
IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.sunday_overlap);
   IF x_days_overlap.sunday_overlap = 'Y' then
      l_overlap_days := l_overlap_days||get_day_meaning('SUN')||',';
   END IF;

END IF;

   IF l_overlap_days IS not null then
            fnd_message.set_name('OKS','OKS_BILLRATE_DAYS_OVERLAP');
            fnd_message.set_token('DAYS', l_overlap_days);
   END IF;

x_return_status         := OKC_API.G_RET_STS_SUCCESS;

EXCEPTION

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
      ROLLBACK;
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
      ROLLBACK ;

END; -- Validate_billrate_schedule;


--=======================================================================================
PROCEDURE INIT_CONTRACT_LINE (x_clev_tbl OUT NOCOPY  OKC_CONTRACT_PUB.clev_tbl_type)
IS
BEGIN

    x_clev_tbl(1).id := NULL;
    x_clev_tbl(1).object_version_number := NULL;
    x_clev_tbl(1).sfwt_flag := NULL;
    x_clev_tbl(1).chr_id := NULL ;
    x_clev_tbl(1).cle_id := NULL ;
    x_clev_tbl(1).lse_id := NULL ;
    x_clev_tbl(1).line_number := NULL ;
    x_clev_tbl(1).sts_code := NULL ;
    x_clev_tbl(1).display_sequence := NULL ;
    x_clev_tbl(1).trn_code := NULL ;
    x_clev_tbl(1).name := NULL ;
    x_clev_tbl(1).comments := NULL ;
    x_clev_tbl(1).item_description := NULL ;
    x_clev_tbl(1).hidden_ind := NULL ;
    x_clev_tbl(1).price_negotiated := NULL ;
    x_clev_tbl(1).price_level_ind := NULL ;
    x_clev_tbl(1).dpas_rating := NULL ;
    x_clev_tbl(1).block23text := NULL ;
    x_clev_tbl(1).exception_yn := NULL ;
    x_clev_tbl(1).template_used := NULL ;
    x_clev_tbl(1).date_terminated := NULL ;
    x_clev_tbl(1).start_date := NULL ;
    x_clev_tbl(1).attribute_category := NULL ;
    x_clev_tbl(1).attribute1 := NULL ;
    x_clev_tbl(1).attribute2 := NULL ;
    x_clev_tbl(1).attribute3 := NULL ;
    x_clev_tbl(1).attribute4 := NULL ;
    x_clev_tbl(1).attribute5 := NULL ;
    x_clev_tbl(1).attribute6 := NULL ;
    x_clev_tbl(1).attribute7 := NULL ;
    x_clev_tbl(1).attribute8 := NULL ;
    x_clev_tbl(1).attribute9 := NULL ;
    x_clev_tbl(1).attribute10 := NULL ;
    x_clev_tbl(1).attribute11 := NULL ;
    x_clev_tbl(1).attribute12 := NULL ;
    x_clev_tbl(1).attribute13 := NULL ;
    x_clev_tbl(1).attribute14 := NULL ;
    x_clev_tbl(1).attribute15 := NULL ;
    x_clev_tbl(1).created_by := NULL ;
    x_clev_tbl(1).creation_date := NULL ;
    x_clev_tbl(1).last_updated_by := NULL ;
    x_clev_tbl(1).last_update_date := NULL ;
    x_clev_tbl(1).price_type:= NULL ;
    x_clev_tbl(1).currency_code := NULL ;
    x_clev_tbl(1).last_update_login := NULL ;
    x_clev_tbl(1).dnz_chr_id := NULL ;

    END ; -- INIT_CONTRACT_LINE
    --=================================================


PROCEDURE  OKS_MIGRATE_BILLRATES(
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2)
    IS

    CURSOR CUR_GET_BILLRATES IS

     SELECT lines1.id billtype_line_id,
            lines2.id billrate_line_id,
            orgb.id  rule_group_id,
            rules.id rule_id,
            rules.dnz_chr_id rule_dnz_chr_id,
            rules.created_by,
            rules.creation_date,
            rules.last_updated_by,
            rules.last_update_date,
            rules.last_update_login,
            rules.rule_information_category,
            rules.rule_information1 uom, -- uom
            rules.rule_information2 flat_rate, -- flat_rate
            rules.rule_information3 percent_over_list_price, -- %over_list_price
            rules.rule_information4 bill_rate_code,          -- bill_rate_code
            NVL(rules.TEMPLATE_YN,'N') TEMPLATE_YN
            FROM
            OKC_K_LINES_B lines1,
            OKC_K_LINES_B lines2,
            OKC_RULE_GROUPS_B orgb,
            OKC_RULES_B rules
            WHERE
				lines1.lse_id IN (5,23,59)
            AND lines2.lse_id IN (6,24,60)
			AND lines1.dnz_chr_id = lines2.dnz_chr_id
            AND lines2.cle_id = lines1.id
            AND lines2.id = orgb.cle_id
            AND lines2.dnz_chr_id = orgb.dnz_chr_id
            AND  rules.rgp_id = orgb.id
            AND  rules.dnz_chr_id = orgb.dnz_chr_id
            AND rules.rule_information_category = 'RSL'
            AND rules.rule_information9 IS NULL ; -- upgrade_flag

   l_bill_rate_tbl_in     OKS_BRS_PVT.OKSBILLRATESCHEDULESVTBLTYPE ;
   x_bill_rate_tbl_out    OKS_BRS_PVT.OKSBILLRATESCHEDULESVTBLTYPE ;

    l_check_Flag  VARCHAR2(1) := 'N';
  l_api_version		CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	CONSTANT	VARCHAR2(1):= 'F';
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000):=null;
  l_api_name VARCHAR2(80):= 'OKS_MIGRATE_BILLRATES';
  G_PKG_NAME VARCHAR2(80):= 'OKS_COVERAGES_PVT' ;

  l_rulv_tbl_in        okc_rule_pub.rulv_tbl_type ;
  l_rulv_tbl_out       okc_rule_pub.rulv_tbl_type ;
BEGIN

 FOR br_rec IN CUR_GET_BILLRATES
 LOOP
    l_check_Flag := 'Y';

   INIT_BILL_RATE_LINE (l_bill_rate_tbl_in) ;

    l_bill_rate_tbl_in(1).cle_id := br_rec.billrate_line_id ;
    l_bill_rate_tbl_in(1).bt_cle_id := br_rec.billtype_line_id ;
    l_bill_rate_tbl_in(1).dnz_chr_id := br_rec.rule_dnz_chr_id;
    l_bill_rate_tbl_in(1).start_hour := NULL ;
    l_bill_rate_tbl_in(1).start_minute := NULL;
    l_bill_rate_tbl_in(1).end_hour := NULL ;
    l_bill_rate_tbl_in(1).end_minute := NULL;
    l_bill_rate_tbl_in(1).monday_flag := NULL;
    l_bill_rate_tbl_in(1).tuesday_flag := NULL;
    l_bill_rate_tbl_in(1).wednesday_flag := NULL;
    l_bill_rate_tbl_in(1).thursday_flag := NULL;
    l_bill_rate_tbl_in(1).friday_flag := NULL;
    l_bill_rate_tbl_in(1).saturday_flag := NULL;
    l_bill_rate_tbl_in(1).sunday_flag := NULL;
    l_bill_rate_tbl_in(1).object1_id1    := NULL;
    l_bill_rate_tbl_in(1).object1_id2    := NULL;
    l_bill_rate_tbl_in(1).bill_rate_code    := br_rec.bill_rate_code;
    l_bill_rate_tbl_in(1).flat_rate    := br_rec.flat_rate ;
    l_bill_rate_tbl_in(1).uom    := br_rec.uom;
    l_bill_rate_tbl_in(1).holiday_yn    := 'N';
    l_bill_rate_tbl_in(1).percent_over_list_price    := br_rec.percent_over_list_price;
    l_bill_rate_tbl_in(1).program_application_id := NULL;
    l_bill_rate_tbl_in(1).program_id := NULL;
    l_bill_rate_tbl_in(1).program_update_date := NULL;
    l_bill_rate_tbl_in(1).request_id := NULL;
    l_bill_rate_tbl_in(1).created_by    := br_rec.created_by ;
    l_bill_rate_tbl_in(1).creation_date    := br_rec.creation_date;
    l_bill_rate_tbl_in(1).last_updated_by    := br_rec.last_updated_by;
    l_bill_rate_tbl_in(1).last_update_date    := br_rec.last_update_date;
    l_bill_rate_tbl_in(1).last_update_login    := br_rec.last_update_login;
    l_bill_rate_tbl_in(1).security_group_id    := NULL;
    l_bill_rate_tbl_in(1).object_version_number    := 1; --Added


 OKS_BRS_PVT.INSERT_ROW(
    p_api_version      => l_api_version,
    p_init_msg_list    => l_init_msg_list,
    x_return_status    => l_return_status,
    x_msg_count        => l_msg_count,
    x_msg_data         => l_msg_data,
    p_oks_billrate_schedules_v_tbl => l_bill_rate_tbl_in,
    x_oks_billrate_schedules_v_tbl => x_bill_rate_tbl_out);


    IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

      x_return_status         := l_return_status;

 UPDATE okc_rules_b
 SET rule_information9 = 'Y'
 WHERE id = br_rec.rule_id ;

END LOOP ;

    IF l_check_Flag = 'N' THEN --Added

        UPDATE  OKS_BILLRATE_SCHEDULES
        SET     object_version_number = 1 ;

    END IF;

x_return_status         := OKC_API.G_RET_STS_SUCCESS;
EXCEPTION


WHEN  G_EXCEPTION_RULE_UPDATE THEN
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
       ( l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      ROLLBACK ;

   WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      ROLLBACK ;
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
      ROLLBACK;
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
      ROLLBACK ;

END    oks_migrate_billrates;

--==========================================================================
PROCEDURE OKS_BILLRATE_MAPPING(
                                p_api_version           IN NUMBER ,
                                p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                p_business_process_id   IN NUMBER,
                                p_time_labor_tbl_in     IN time_labor_tbl,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_count             OUT NOCOPY NUMBER,
                                x_msg_data              OUT NOCOPY VARCHAR2) IS

  i                               NUMBER:= 0;
  j                               NUMBER:= 0;
  l_bus_proc_id                   NUMBER;
  l_holiday_flag                  VARCHAR2(1);
  l_api_version		CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	CONSTANT	VARCHAR2(1):= 'F';
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000):=null;
  l_api_name VARCHAR2(80):= 'OKS_BILLRATE_MAPPING';
  G_PKG_NAME VARCHAR2(80):= 'OKS_COVERAGES_PVT' ;

   l_bill_rate_tbl_in     OKS_BRS_PVT.OKSBILLRATESCHEDULESVTBLTYPE ;
   x_bill_rate_tbl_out    OKS_BRS_PVT.OKSBILLRATESCHEDULESVTBLTYPE ;
   l_clev_tbl_in          OKC_CONTRACT_PUB.clev_tbl_type ;
   l_clev_tbl_out         OKC_CONTRACT_PUB.clev_tbl_type ;
   l_rulv_tbl_in          okc_rule_pub.rulv_tbl_type ;
  l_rulv_tbl_out          okc_rule_pub.rulv_tbl_type ;
   l_cle_id               NUMBER;
   l_bill_rate_code       VARCHAR2(30);

   l_conc_request_id      NUMBER;
   l_prog_appl_id         NUMBER;
   l_conc_program_id      NUMBER;
   l_program_update_date  DATE;




    CURSOR CUR_GET_ALL_BILL_RATE_CODES(p_business_process_id IN NUMBER) IS
    SELECT lines1.id bp_line_id, lines2.id bill_type_line_id,lines2.lse_id bt_lse_id,
    lines3.id bill_rate_line_id, lines3.lse_id br_lse_id,lines3.sts_code sts_code,
    lines3.dnz_chr_id br_dnz_chr_id,
    orgb.id rule_group_id,
    rules.id rule_id,
    rules.template_yn template_yn,
    rules.rule_information4 rule_information4,
    items.object1_id1, -- bp_id
    bills.id  billrate_sch_id,
    bills.cle_id  br_line_id,
    bills.bt_cle_id bt_cle_id,
    bills.bill_rate_code  bill_rate_code,
    bills.flat_rate flat_rate,
    bills.uom uom,
    bills.percent_over_list_price percent_over_list_price,
    bills.created_by created_by,
    bills.creation_date creation_date,
    bills.last_updated_by last_updated_by,
    bills.last_update_date last_update_date,
    bills.last_update_login last_update_login,
    bills.security_group_id  security_group_id,
    bills.object_version_number object_version_number--Added
    FROM
    OKC_K_LINES_B lines1,
    OKC_K_LINES_B lines2,
    OKC_K_LINES_B lines3,
    OKC_K_ITEMS items,
    OKC_RULE_GROUPS_B orgb,
    OKC_RULES_B rules,
    OKS_BILLRATE_SCHEDULES bills
    WHERE
    lines1.lse_id IN (3,16,21)
    and lines2.lse_id IN (5,23,59)
    and lines3.lse_id IN (6,24,60)
    and lines2.cle_id = lines1.id
    and lines3.cle_id = lines2.id
    and orgb.cle_id = lines3.id
    and rules.rgp_id = orgb.id
    and items.cle_id = lines1.id
    and bills.bt_cle_id = lines2.id
    and bills.cle_id = lines3.id
    and lines2.dnz_chr_id = lines1.dnz_chr_id
    and lines3.dnz_chr_id = lines2.dnz_chr_id
    and rules.rule_information10 IS NULL
    and items.object1_id1 = to_char(p_business_process_id) ;
  --  and rules.rule_information_category = 'RSL' ;
  -- and bills.start_time and end time is null;

   l_bill_rate_exists  VARCHAR2(1) := 'N';

/*    CURSOR CUR_GET_TIME_INFO(p_bus_proc_id IN NUMBER, p_holiday_flag IN VARCHAR2,p_labor_code IN VARCHAR2) IS
    SELECT TO_CHAR(START_TIME,'HH24') START_HOUR,TO_CHAR(START_TIME,'MI')START_MINUTE,
           TO_CHAR(END_TIME,'HH24')END_HOUR,TO_CHAR(END_TIME,'MI')END_MINUTE,
           MONDAY_FLAG,TUESDAY_FLAG,WEDNESDAY_FLAG,THURSDAY_FLAG,FRIDAY_FLAG,
           SATURDAY_FLAG,SUNDAY_FLAG, INVENTORY_ITEM_ID, LABOR_CODE
           FROM  CS_TM_LABOR_SCHEDULES
           WHERE BUSINESS_PROCESS_ID = p_bus_proc_id
           AND  HOLIDAY_FLAG = p_holiday_flag
           AND LABOR_CODE = p_labor_code; */

    BEGIN

    FOR bill_rate_rec IN CUR_GET_ALL_BILL_RATE_CODES(p_business_process_id)
     LOOP

     If (OKC_ASSENT_PUB.HEADER_OPERATION_ALLOWED(bill_rate_rec.br_dnz_chr_id, 'UPDATE') = 'T') then -- status and operations check

      i:= i + 1 ;

     l_bus_proc_id       := to_number(bill_rate_rec.object1_id1) ;
     l_holiday_flag      := 'N';
     l_bill_rate_code    := bill_rate_rec.rule_information4;

        l_conc_request_id := fnd_global.conc_request_id ;

      IF l_conc_request_id <> -1 THEN
         l_prog_appl_id := fnd_global.prog_appl_id ;
         l_conc_program_id := fnd_global.conc_program_id;
         l_program_update_date := sysdate;
     ELSE
         l_prog_appl_id := NULL;
         l_conc_program_id := NULL;
         l_program_update_date := NULL;
         l_conc_request_id := NULL;
      END IF ;

         IF fnd_global.conc_request_id <> -1 THEN
               fnd_file.put_line(FND_FILE.LOG, 'PROGRAM_APPLICATION_ID....'||l_prog_appl_id);
               fnd_file.put_line(FND_FILE.LOG, 'PROGRAM_ID...'||l_conc_program_id);
               fnd_file.put_line(FND_FILE.LOG, 'PROGRAM_UPDATE_DATE...'||l_program_update_date);
               fnd_file.put_line(FND_FILE.LOG, 'REQUEST_ID...'||l_conc_request_id);
               fnd_file.put_line(FND_FILE.LOG, 'Processing for BP_LINE_ID.....'||bill_rate_rec.bp_line_id);
         END IF;


       l_bill_rate_exists := 'N' ;


       FOR  j IN p_time_labor_tbl_in.FIRST .. p_time_labor_tbl_in.LAST
       LOOP


     IF p_time_labor_tbl_in(j).holiday_flag = 'N' and p_time_labor_tbl_in(j).labor_code = l_bill_rate_code
     THEN

      IF   l_bill_rate_exists = 'N' THEN
           l_bill_rate_exists := 'Y';

         INIT_BILL_RATE_LINE (l_bill_rate_tbl_in) ;


        l_bill_rate_tbl_in(1).id               := bill_rate_rec.billrate_sch_id ;
        l_bill_rate_tbl_in(1).cle_id           := bill_rate_rec.br_line_id ;
        l_bill_rate_tbl_in(1).bt_cle_id        := bill_rate_rec.bt_cle_id ;
        l_bill_rate_tbl_in(1).start_hour       := TO_NUMBER(TO_CHAR(p_time_labor_tbl_in(j).START_TIME,'HH24')) ;
        l_bill_rate_tbl_in(1).start_minute     := TO_NUMBER(TO_CHAR(p_time_labor_tbl_in(j).START_TIME,'MI'));
        l_bill_rate_tbl_in(1).end_hour         := TO_NUMBER(TO_CHAR(p_time_labor_tbl_in(j).END_TIME,'HH24'));
        l_bill_rate_tbl_in(1).end_minute       := TO_NUMBER(TO_CHAR(p_time_labor_tbl_in(j).END_TIME,'MI'));
        l_bill_rate_tbl_in(1).monday_flag      := p_time_labor_tbl_in(j).monday_flag ;
        l_bill_rate_tbl_in(1).tuesday_flag     := p_time_labor_tbl_in(j).tuesday_flag ;
        l_bill_rate_tbl_in(1).wednesday_flag   := p_time_labor_tbl_in(j).wednesday_flag;
        l_bill_rate_tbl_in(1).thursday_flag    := p_time_labor_tbl_in(j).thursday_flag;
        l_bill_rate_tbl_in(1).friday_flag      := p_time_labor_tbl_in(j).friday_flag;
        l_bill_rate_tbl_in(1).saturday_flag    := p_time_labor_tbl_in(j).saturday_flag;
        l_bill_rate_tbl_in(1).sunday_flag      := p_time_labor_tbl_in(j).sunday_flag;
        l_bill_rate_tbl_in(1).object1_id1      := p_time_labor_tbl_in(j).inventory_item_id ;
        l_bill_rate_tbl_in(1).object1_id2      := '#';
        l_bill_rate_tbl_in(1).bill_rate_code   := bill_rate_rec.bill_rate_code;
        l_bill_rate_tbl_in(1).flat_rate        := bill_rate_rec.flat_rate ;
        l_bill_rate_tbl_in(1).uom              := bill_rate_rec.uom;
        l_bill_rate_tbl_in(1).holiday_yn       := 'N';
        l_bill_rate_tbl_in(1).percent_over_list_price     := bill_rate_rec.percent_over_list_price;
        l_bill_rate_tbl_in(1).program_application_id      := l_prog_appl_id;
        l_bill_rate_tbl_in(1).program_id                  := l_conc_program_id;
        l_bill_rate_tbl_in(1).program_update_date         := l_program_update_date;
        l_bill_rate_tbl_in(1).request_id                  := l_conc_request_id;
        l_bill_rate_tbl_in(1).created_by                 := bill_rate_rec.created_by ;
        l_bill_rate_tbl_in(1).creation_date              := bill_rate_rec.creation_date;
        l_bill_rate_tbl_in(1).last_updated_by            := bill_rate_rec.last_updated_by;
        l_bill_rate_tbl_in(1).last_update_date           := bill_rate_rec.last_update_date;
        l_bill_rate_tbl_in(1).last_update_login          := bill_rate_rec.last_update_login;
        l_bill_rate_tbl_in(1).security_group_id          := bill_rate_rec.security_group_id;
        l_bill_rate_tbl_in(1).object_version_number      := bill_rate_rec.object_version_number;--Added

             OKS_BRS_PVT.update_row(
                             p_api_version          => l_api_version,
                             p_init_msg_list        => p_init_msg_list,
                             x_return_status        => l_return_status,
                             x_msg_count            => l_msg_count,
                             x_msg_data             => l_msg_data,
                             p_oks_billrate_schedules_v_tbl => l_bill_rate_tbl_in,
                             x_oks_billrate_schedules_v_tbl => x_bill_rate_tbl_out);

        IF fnd_global.conc_request_id <> -1 THEN
               fnd_file.put_line(FND_FILE.LOG, 'AFTER OKS_BRS_PVT.UPDATE_ROW......');
               fnd_file.put_line(FND_FILE.LOG, 'Return Status from OKS_BRS_PVT.UPDATE_ROW API...'||l_return_status);
         END IF;



                  IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                       RAISE G_EXCEPTION_BRS_UPDATE ;
                  END IF;

    ELSE -- create lines in okc_k_lines_b, oks_billrate_schedules

                  INIT_CONTRACT_LINE(l_clev_tbl_in);
                  INIT_BILL_RATE_LINE(l_bill_rate_tbl_in) ;

                  l_clev_tbl_in(1).cle_id := bill_rate_rec.bill_type_line_id;
                  l_clev_tbl_in(1).lse_id := bill_rate_rec.br_lse_id;
                  l_clev_tbl_in(1).sfwt_flag := 'N';
                  l_clev_tbl_in(1).exception_yn := 'N';
                  l_clev_tbl_in(1).sts_code:= bill_rate_rec.sts_code ;
                  l_clev_tbl_in(1).dnz_chr_id:= bill_rate_rec.br_dnz_chr_id ;
                  l_clev_tbl_in(1).display_sequence:= 1 ;



                  OKC_CONTRACT_PUB.CREATE_CONTRACT_LINE(p_api_version => l_api_version,
                                                        p_init_msg_list => l_init_msg_list,
                                                        x_return_status => l_return_status,
                                                        x_msg_count    => l_msg_count,
                                                        x_msg_data  => l_msg_data,
                                                        p_restricted_update => 'F',
                                                        p_clev_tbl => l_clev_tbl_in,
                                                        x_clev_tbl => l_clev_tbl_out  );

                          x_return_status         := l_return_status;



        IF fnd_global.conc_request_id <> -1 THEN
               fnd_file.put_line(FND_FILE.LOG, 'AFTER OKC_CONTRACT_PUB.CREATE_CONTRACT_LINE......');
               fnd_file.put_line(FND_FILE.LOG, 'Return Status from OKC_CONTRACT_PUB.CREATE_CONTRACT_LINE API...'||l_return_status);
         END IF;


                   IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                       RAISE G_EXCEPTION_HALT_VALIDATION ;
                  END IF;

                  l_cle_id := l_clev_tbl_out(1).id ;

                   l_bill_rate_tbl_in(1).cle_id := l_cle_id; --C1.billrate_line_id ;
                   l_bill_rate_tbl_in(1).bt_cle_id := bill_rate_rec.bill_type_line_id ;
                   l_bill_rate_tbl_in(1).start_hour       := TO_NUMBER(TO_CHAR(p_time_labor_tbl_in(j).START_TIME,'HH24')) ;
                   l_bill_rate_tbl_in(1).start_minute     := TO_NUMBER(TO_CHAR(p_time_labor_tbl_in(j).START_TIME,'MI'));
                   l_bill_rate_tbl_in(1).end_hour         := TO_NUMBER(TO_CHAR(p_time_labor_tbl_in(j).END_TIME,'HH24'));
                   l_bill_rate_tbl_in(1).end_minute       := TO_NUMBER(TO_CHAR(p_time_labor_tbl_in(j).END_TIME,'MI'));
                   l_bill_rate_tbl_in(1).monday_flag := p_time_labor_tbl_in(j).monday_flag;
                   l_bill_rate_tbl_in(1).tuesday_flag := p_time_labor_tbl_in(j).tuesday_flag;
                   l_bill_rate_tbl_in(1).wednesday_flag := p_time_labor_tbl_in(j).wednesday_flag;
                   l_bill_rate_tbl_in(1).thursday_flag := p_time_labor_tbl_in(j).thursday_flag;
                   l_bill_rate_tbl_in(1).friday_flag := p_time_labor_tbl_in(j).friday_flag;
                   l_bill_rate_tbl_in(1).saturday_flag := p_time_labor_tbl_in(j).saturday_flag;
                   l_bill_rate_tbl_in(1).sunday_flag := p_time_labor_tbl_in(j).sunday_flag;
                   l_bill_rate_tbl_in(1).object1_id1    := p_time_labor_tbl_in(j).inventory_item_id;
                   l_bill_rate_tbl_in(1).object1_id2    := '#';
                   l_bill_rate_tbl_in(1).bill_rate_code    := p_time_labor_tbl_in(j).labor_code;
                   l_bill_rate_tbl_in(1).flat_rate    := NULL;
                   l_bill_rate_tbl_in(1).uom    := NULL;
                   l_bill_rate_tbl_in(1).holiday_yn    := 'N';
                   l_bill_rate_tbl_in(1).percent_over_list_price    := NULL;
                   l_bill_rate_tbl_in(1).program_application_id      := l_prog_appl_id;
                   l_bill_rate_tbl_in(1).program_id                  := l_conc_program_id;
                   l_bill_rate_tbl_in(1).program_update_date         := l_program_update_date;
                   l_bill_rate_tbl_in(1).request_id                  := l_conc_request_id;
                   l_bill_rate_tbl_in(1).created_by                 := bill_rate_rec.created_by ;
                   l_bill_rate_tbl_in(1).creation_date              := bill_rate_rec.creation_date;
                   l_bill_rate_tbl_in(1).last_updated_by            := bill_rate_rec.last_updated_by;
                   l_bill_rate_tbl_in(1).last_update_date           := bill_rate_rec.last_update_date;
                   l_bill_rate_tbl_in(1).last_update_login          := bill_rate_rec.last_update_login;
                   l_bill_rate_tbl_in(1).security_group_id          := bill_rate_rec.security_group_id;
                   l_bill_rate_tbl_in(1).object_version_number      := bill_rate_rec.object_version_number;--Added


              OKS_BRS_PVT.INSERT_ROW(
                                    p_api_version      => l_api_version,
                                    p_init_msg_list    => l_init_msg_list,
                                    x_return_status    => l_return_status,
                                    x_msg_count        => l_msg_count,
                                    x_msg_data         => l_msg_data,
                                    p_oks_billrate_schedules_v_tbl => l_bill_rate_tbl_in,
                                    x_oks_billrate_schedules_v_tbl => x_bill_rate_tbl_out);

                        x_return_status         := l_return_status;


         IF fnd_global.conc_request_id <> -1 THEN
               fnd_file.put_line(FND_FILE.LOG, 'AFTER OKS_BRS_PVT.INSERT_ROW......');
               fnd_file.put_line(FND_FILE.LOG, 'Return Status from OKS_BRS_PVT.INSERT_ROW API...'||l_return_status);
         END IF;



    IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


   END IF ;
   END IF ;
      END LOOP ;

       -- update the rule line with mapped status to Y


 -- code commented to fix bug#2954917 for charges integration
 UPDATE okc_rules_b
 SET rule_information9 = 'Y'
 WHERE id = bill_rate_rec.rule_id ;

  /*  l_rulv_tbl_in(1).id := bill_rate_rec.rule_id ;
    l_rulv_tbl_in(1).rule_information10 := 'Y';
    l_rulv_tbl_in(1).template_yn := bill_rate_rec.template_yn;


      OKC_RULE_PUB.UPDATE_RULE(p_api_version      => l_api_version,
                               p_init_msg_list    => l_init_msg_list,
                               x_return_status    => l_return_status,
                               x_msg_count        => l_msg_count,
                               x_msg_data         => l_msg_data,
                               p_rulv_tbl         => l_rulv_tbl_in,
                               x_rulv_tbl         => l_rulv_tbl_out); */

           IF fnd_global.conc_request_id <> -1 THEN
               fnd_file.put_line(FND_FILE.LOG, 'AFTER OKC_RULE_PUB.UPDATE_RULE......Updating RULE_INFORMATION10 to Y');
             --  fnd_file.put_line(FND_FILE.LOG, 'Return Status from OKC_RULE_PUB.UPDATE_RULE API...'||l_return_status);
         END IF;




  end if; -- status and operations check

END LOOP ;
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF fnd_global.conc_request_id <> -1 THEN
         fnd_file.put_line(FND_FILE.LOG, 'Return Status from API...'||x_return_status);
      END IF;


EXCEPTION
WHEN G_EXCEPTION_RULE_UPDATE THEN
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
       ( l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      ROLLBACK ;
      IF fnd_global.conc_request_id <> -1 THEN
         fnd_file.put_line(FND_FILE.LOG, 'Raised Exception...||G_EXCEPTION_RULE_UPDATE');
      END IF;



WHEN  G_EXCEPTION_BRS_UPDATE THEN
 x_return_status := OKC_API.HANDLE_EXCEPTIONS
       ( l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      ROLLBACK ;
      IF fnd_global.conc_request_id <> -1 THEN
         fnd_file.put_line(FND_FILE.LOG, 'Raised Exception...||G_EXCEPTION_BRS_UPDATE');
      END IF;

   WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      ROLLBACK ;

       IF fnd_global.conc_request_id <> -1 THEN
         fnd_file.put_line(FND_FILE.LOG, 'Raised Exception...||G_EXCEPTION_HALT_VALIDATION');
      END IF;

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
      ROLLBACK;
       IF fnd_global.conc_request_id <> -1 THEN
         fnd_file.put_line(FND_FILE.LOG, 'Raised Exception...||G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;


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
      ROLLBACK ;
       IF fnd_global.conc_request_id <> -1 THEN
         fnd_file.put_line(FND_FILE.LOG, 'Raised Exception...||OTHERS');
      END IF;


    END  oks_billrate_mapping ;


   --==========================================================================================

PROCEDURE     Get_Notes_Details(P_source_object_id      IN NUMBER,
                                    X_Notes_TBL             OUT nocopy jtf_note_tbl_type,
                                    X_Return_Status         OUT nocopy VARCHAR2,
                                    P_source_object_code    IN VARCHAR2) IS -- Bug:5944200

        CURSOR GET_NOTES_DETAILS_CUR(l_id IN NUMBER) IS
        SELECT  B.JTF_NOTE_ID JTF_NOTE_ID,
                B.SOURCE_OBJECT_CODE SOURCE_OBJECT_CODE,
                B.NOTE_STATUS NOTE_STATUS,
                B.NOTE_TYPE NOTE_TYPE,
                B.NOTES NOTES,
                B.NOTES_DETAIL NOTES_DETAIL,
           -- Modified by Jvorugan for Bug:4489214 who columns not to be populated from old contract
                B.Entered_by Entered_by,
                B.Entered_date Entered_date
           -- End of changes for Bug:4489214
        FROM    JTF_NOTES_VL B
        WHERE   B.SOURCE_OBJECT_ID = l_id
        AND     B.SOURCE_OBJECT_CODE = P_source_object_code ; -- Bug:5944200


i   NUMBER := 0;

    BEGIN

        I := 0;
        L_Notes_TBL.DELETE;


        FOR GET_NOTES_DETAILS_REC IN GET_NOTES_DETAILS_CUR(P_source_object_id) LOOP


            L_Notes_TBL(i).source_object_code  := GET_NOTES_DETAILS_REC.SOURCE_OBJECT_CODE;
            L_Notes_TBL(i).Notes               := GET_NOTES_DETAILS_REC.NOTES;
            JTF_NOTES_PUB.writeLobToData(GET_NOTES_DETAILS_REC.JTF_NOTE_ID,L_Notes_TBL(i).Notes_detail);
            --GET_NOTES_DETAILS_REC.NOTES_DETAIL;
            L_Notes_TBL(i).note_status           := GET_NOTES_DETAILS_REC.NOTE_STATUS;
            L_Notes_TBL(i).note_type             := GET_NOTES_DETAILS_REC.NOTE_TYPE;
           -- Modified by Jvorugan for Bug:4489214 who columns not to be populated from old contract
            L_Notes_TBL(i).entered_by             := GET_NOTES_DETAILS_REC.ENTERED_BY;
            L_Notes_TBL(i).entered_date           := GET_NOTES_DETAILS_REC.ENTERED_DATE;
           -- End of changes for Bug:4489214



            I := I +1 ;
        END LOOP;
            X_RETURN_STATUS         := 'S';
EXCEPTION
	WHEN OTHERS THEN
   	X_RETURN_STATUS := 'E';
   OKC_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
END Get_Notes_Details;




PROCEDURE COPY_NOTES
           (p_api_version           IN NUMBER ,
            p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            p_line_id               IN NUMBER,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2) IS

    L_line_Id   NUMBER :=   P_line_id;
    L_FIRST_REC VARCHAR2(1) := 'N';

		l_created_by            Number := NULL;
		l_last_updated_by       Number := NULL;
		l_last_update_login     Number := NULL;


    CURSOR get_orig_contract_CUR(l_id IN NUMBER) IS
    SELECT  lines2.id orig_line_id,lines2.dnz_chr_id  orig_dnz_chr_id,
            lines1.Id New_line_ID,lines1.chr_Id New_Chr_Id,
            lines1.created_by,
            lines1.last_updated_by,
            lines1.last_update_login
    FROM    -- okc_k_lines_v lines1, --new_id
            -- okc_k_lines_v lines2  -- old_id
	    okc_k_lines_b lines1,  --Modified by Jvorugan for Bug:4560735
	    okc_k_lines_b lines2
    WHERE   lines1.id =l_id
    AND     lines1.ORIG_SYSTEM_ID1 = lines2.ID;
    --AND     lines1.lse_id =1
    --AND     lines2.lse_id = 1;


    l_source_object_code      JTF_NOTES_B.SOURCE_OBJECT_CODE%TYPE;
    l_source_object_id        JTF_NOTES_B.SOURCE_OBJECT_ID%TYPE;
    l_note_type               JTF_NOTES_B.NOTE_TYPE%TYPE;
    l_note_status             JTF_NOTES_B.NOTE_STATUS%TYPE;
    l_notes                   JTF_NOTES_TL.NOTES%TYPE;
    l_Notes_detail            VARCHAR2(32767);

    l_Return_Status         VARCHAR2(1) := NULL;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(1000);
    l_jtf_note_id           NUMBER;
    l_jtf_note_contexts_tab jtf_notes_pub.jtf_note_contexts_tbl_type;


BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    FOR get_orig_contract_REC IN get_orig_contract_CUR(l_line_ID) LOOP

      /* Commented by Jvorugan for Bug:4489214 who columns not to be populated from old contract
	l_created_by            :=  get_orig_contract_REC.created_by;
        l_last_updated_by       :=  get_orig_contract_REC.last_updated_by;
        l_last_update_login     :=  get_orig_contract_REC.last_update_login; */



         Get_Notes_Details( P_source_object_id   =>  get_orig_contract_REC.orig_line_id,
                            X_Notes_TBL          =>  l_Notes_TBL,
                            X_Return_Status      =>  l_Return_Status,
                            P_source_object_code =>  'OKS_COV_NOTE'); -- Bug:5944200

        IF    l_Return_Status = 'S' THEN
            IF   (l_Notes_TBL.COUNT > 0) THEN
                FOR I IN l_Notes_TBL.FIRST .. l_Notes_TBL.LAST LOOP

                JTF_NOTES_PUB.create_note
                  ( p_jtf_note_id           => NULL--:JTF_NOTES.JTF_NOTE_ID
                  , p_api_version           => 1.0
                  , p_init_msg_list         => 'F'
                  , p_commit                => 'F'
                  , p_validation_level      => 0
                  , x_return_status         => l_return_status
                  , x_msg_count             => l_msg_count
                  , x_msg_data              => l_msg_data
                  , p_source_object_code    => l_Notes_TBL(i).source_object_code
                  , p_source_object_id      => get_orig_contract_REC.New_line_ID
                  , p_notes                 => l_Notes_TBL(i).notes
                  , p_notes_detail          => l_Notes_TBL(i).notes_Detail
                  , p_note_status           => l_Notes_TBL(i).note_status
                  , p_note_type             => l_Notes_TBL(i).note_type
                  , p_entered_by            => l_Notes_TBL(i).entered_by   -- -1 Modified for Bug:4489214
                  , p_entered_date          => l_Notes_TBL(i).entered_date -- SYSDATE Modified for Bug:4489214
                  , x_jtf_note_id           => l_jtf_note_id
                  , p_creation_date         => SYSDATE
                  , p_created_by            => FND_GLOBAL.USER_ID        --  created_by Modified for Bug:4489214
                  , p_last_update_date      => SYSDATE
                  , p_last_updated_by       => FND_GLOBAL.USER_ID        -- l_last_updated_by Modified for Bug:4489214
                  , p_last_update_login     => FND_GLOBAL.LOGIN_ID       -- l_last_update_login Modified for Bug:4489214
                  , p_attribute1            => NULL
                  , p_attribute2            => NULL
                  , p_attribute3            => NULL
                  , p_attribute4            => NULL
                  , p_attribute5            => NULL
                  , p_attribute6            => NULL
                  , p_attribute7            => NULL
                  , p_attribute8            => NULL
                  , p_attribute9            => NULL
                  , p_attribute10           => NULL
                  , p_attribute11           => NULL
                  , p_attribute12           => NULL
                  , p_attribute13           => NULL
                  , p_attribute14           => NULL
                  , p_attribute15           => NULL
                  , p_context               => NULL
                  , p_jtf_note_contexts_tab => l_jtf_note_contexts_tab);--l_jtf_note_contexts_tab  );

                END LOOP;
            END IF;

            END IF;
        END LOOP;
-- COMMIT;  -- There should not be any COMMIT in any API
EXCEPTION

  WHEN OTHERS THEN

      OKC_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END COPY_NOTES;

PROCEDURE Copy_Coverage(p_api_version         IN     NUMBER,
                          p_init_msg_list     IN     VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status     OUT    NOCOPY    VARCHAR2,
                          x_msg_count         OUT    NOCOPY    NUMBER,
                          x_msg_data          OUT    NOCOPY   VARCHAR2,
                          p_contract_line_id  IN     NUMBER) IS



     l_klnv_tbl_in            oks_kln_pvt.klnv_tbl_type;
     l_klnv_tbl_out           oks_kln_pvt.klnv_tbl_type;
     l_billrate_sch_tbl_in    oks_brs_pvt.OksBillrateSchedulesVTblType;
     l_billrate_sch_tbl_out   oks_brs_pvt.OksBillrateSchedulesVTblType;

     l_timezone_tbl_in        oks_ctz_pvt.OksCoverageTimezonesVTblType;
     l_timezone_tbl_out       oks_ctz_pvt.OksCoverageTimezonesVTblType;

     l_cover_time_tbl_in     oks_cvt_pvt.oks_coverage_times_v_tbl_type;
     l_cover_time_tbl_out    oks_cvt_pvt.oks_coverage_times_v_tbl_type;

     l_act_pvt_tbl_in       oks_act_pvt.OksActionTimeTypesVTblType;
     l_act_pvt_tbl_out       oks_act_pvt.OksActionTimeTypesVTblType;

     l_acm_pvt_tbl_in       oks_acm_pvt.oks_action_times_v_tbl_type;
     l_acm_pvt_tbl_out       oks_acm_pvt.oks_action_times_v_tbl_type;

    l_new_Bp_line_Id NUMBER  := NULL;
    l_new_TimeZone_Id   NUMBER  := NULL;
     l_new_contract_line_id  NUMBER;
     l_new_cov_line_id       NUMBER;
     l_new_cov_start_date    DATE;
     l_new_cov_end_date      DATE;
     l_new_dnz_chr_id        NUMBER;
     l_old_dnz_chr_id        NUMBER;

     l_old_contract_line_id  NUMBER;
     l_old_cov_line_id       NUMBER;
     l_old_cov_start_date    DATE;
     l_old_cov_end_date      DATE;

     l_old_Time_Zone_Id NUMBER;
     l_old_Time_Zone_Dnz_Chr_Id NUMBER;

  l_api_version             CONSTANT    NUMBER     := 1.0;
  l_init_msg_list           CONSTANT    VARCHAR2(1):= 'F';
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;

  l_message                     VARCHAR2(2000):=null;
  l_msg_index_out   Number;

  l_msg_data            VARCHAR2(2000):=null;
  l_api_name            VARCHAR2(80):= 'OKS_COPY_COVERAGE';
  G_PKG_NAME            VARCHAR2(80):= 'OKS_COVERAGES_PVT' ;
  l_validate_yn         VARCHAR2(1):= 'N';
  l_orig_sys_id1        NUMBER;
  i                     NUMBER:= 0;
  l_bp_id               NUMBER;
  l_old_bp_line_id      NUMBER;
  l_old_busi_proc_id    NUMBER;
  j                     NUMBER;
  l_tze_id              NUMBER;
  l_bp_line_id          NUMBER  := NULL;
  l_cov_tze_line_id     NUMBER;
l_line_NUMBER   NUMBER;
l_RT_ID         NUMBER;
l_rt_dnz_chr_id NUMBER;
M               NUMBER;
N               NUMBER;
L               NUMBER  := 0;
k               NUMBER  := 0;
F               NUMBER  := 0;
l_line_id_four  NUMBER  := 0;
l_act_pvt_ID    NUMBER  := 0;
l_act_pvt_new_ID    NUMBER  := 0;
l_act_pvt_dnz_chr_ID    NUMBER  := 0;
l_Act_pvt_cle_id        NUMBER  := 0;

l_old_bill_type_ID      NUMBER  := 0;
l_bill_Type_ID          NUMBER  := 0;
l_bill_Type_Dnz_Chr_ID  NUMBER  := 0;

l_old_object1_id1       NUMBER  := 0;
l_old_line_number       NUMBER  := 0;
l_new_Bp_Object1_ID1    NUMBER  := 0;
-- get the original system_id1 from okc_k_lines_b

     CURSOR CUR_GET_ORIG_SYS_ID1(p_id IN NUMBER) IS
     SELECT ORIG_SYSTEM_ID1
     FROM OKC_K_LINES_B
     WHERE ID = p_id ;
-- get the coverage details for the coverage line added by jvorugan
   CURSOR CUR_GET_COV_DET(p_id IN NUMBER) IS
    SELECT ID,DNZ_CHR_ID, START_DATE, END_DATE
    FROM OKC_K_LINES_B
    WHERE id = p_id;

    cr_cov_det   CUR_GET_COV_DET%ROWTYPE;

 -- get the pm_program_id associated with the service line added by jvorugan
   CURSOR CUR_GET_PROGRAM_ID(p_contract_line_id IN NUMBER) IS
    SELECT PM_PROGRAM_ID
    FROM OKS_K_LINES_B
    WHERE cle_id =p_contract_line_id;


-- check whether the coverage is template   added by jvorugan
   CURSOR check_cov_tmpl(p_cov_id IN Number) IS
    SELECT count(*) FROM OKC_K_LINES_B
    WHERE id = p_cov_id
    AND lse_id in (2,15,20)
    and dnz_chr_id < 0;

-- get the coverage id for the service line

    CURSOR CUR_GET_COV_LINE_ID(p_contract_line_id IN NUMBER) IS
    SELECT ID,DNZ_CHR_ID, START_DATE, END_DATE
    FROM OKC_K_LINES_B
    WHERE cle_id = p_contract_line_id
    AND lse_id  IN (2,15,20);

    cr_cov_line   cur_get_cov_line_id%ROWTYPE;

-- get the coverage line attributes from oks_k_lines_b
   CURSOR CUR_GET_COV_ATTR(p_cle_id IN NUMBER) IS
   SELECT ID, CLE_ID,
   COVERAGE_TYPE,EXCEPTION_COV_ID,SYNC_DATE_INSTALL,
   TRANSFER_OPTION, PROD_UPGRADE_YN,INHERITANCE_TYPE,
   PM_PROGRAM_ID,
   PM_CONF_REQ_YN,PM_SCH_EXISTS_YN,object_version_number
   FROM OKS_K_LINES_B
   WHERE cle_id = p_cle_id ;

-- get the old and new business process line details
/*
  CURSOR CUR_GET_OLD_BP(p_cle_id IN NUMBER) IS
  SELECT lines1.id bp_line_id, lines1.start_date start_date, lines1.end_date end_date,
         to_number(items.object1_id1) object1_id1,
         oks.discount_list discount_list,
         oks.offset_period offset_period,
         oks.offset_duration offset_duration,
         oks.allow_bt_discount allow_bt_discount,
         oks.apply_default_timezone apply_default_timezone,
         oks.OBJECT_VERSION_NUMBER OBJECT_VERSION_NUMBER
         FROM okc_k_lines_b lines1,
              oks_k_lines_b oks,
              okc_k_items items
         WHERE lines1.cle_id = p_cle_id
         AND items.cle_id = lines1.id
         AND items.jtot_object1_code = 'OKX_BUSIPROC'
         AND oks.cle_id = lines1.id
         AND lines1.lse_id IN (3,16,21)
         ORDER BY items.object1_id1, lines1.start_date, lines1.end_date;
*/

-- CURSOR CUR_GET_OLD_BP modified for bug#4155384 - smohapat
  CURSOR CUR_GET_OLD_BP(p_cle_id IN NUMBER) IS
  SELECT lines1.id bp_line_id,
         lines1.start_date start_date,
         lines1.end_date end_date,
         oks.discount_list discount_list,
         oks.offset_period offset_period,
         oks.offset_duration offset_duration,
         oks.allow_bt_discount allow_bt_discount,
         oks.apply_default_timezone apply_default_timezone,
         oks.OBJECT_VERSION_NUMBER OBJECT_VERSION_NUMBER
         FROM okc_k_lines_b lines1,
              oks_k_lines_b oks
         WHERE lines1.cle_id = p_cle_id
         AND oks.cle_id = lines1.id
         AND lines1.lse_id IN (3,16,21);
/*
  CURSOR CUR_GET_NEW_BP(p_cle_id IN NUMBER ,P_Object1_Id1 IN NUMBER , p_old_bp_id in number) IS
  SELECT lines1.id bp_line_id, lines1.dnz_chr_id dnz_chr_id,lines1.start_date start_date, lines1.end_date end_date,
         to_number(items.object1_id1) object1_id1
          FROM okc_k_lines_b lines1,
               okc_k_items items
         WHERE lines1.cle_id = p_cle_id
         AND items.cle_id = lines1.id
         AND items.jtot_object1_code = 'OKX_BUSIPROC'
         AND to_number(items.object1_id1) = p_object1_id1
         AND lines1.lse_id IN (3,16,21)
         AND lines1.orig_system_id1 = p_old_bp_id --New check added to allow duplicate BP
         ORDER BY items.object1_id1, lines1.start_date, lines1.end_date;
*/
-- CURSOR CUR_GET_NEW_BP modified for bug#4155384 - smohapat

           CURSOR CUR_GET_NEW_BP(p_cle_id IN NUMBER , p_old_bp_id in number) IS
           SELECT lines1.id bp_line_id, lines1.dnz_chr_id dnz_chr_id,lines1.start_date start_date, lines1.end_date end_date
           FROM okc_k_lines_b lines1
           WHERE lines1.cle_id = p_cle_id
           AND lines1.lse_id IN (3,16,21)
           AND lines1.orig_system_id1 = p_old_bp_id ;

-- Get Old And New Reaction Times
  CURSOR CUR_GET_OLD_RT(p_cle_id IN NUMBER) IS
    SELECT  lines1.id rt_line_id,
            lines1.dnz_chr_id rt_dnz_chr_id,
            lines1.line_number  rt_line_number,
            lines1.start_date start_date,
            lines1.end_date end_date,
            oks.INCIDENT_SEVERITY_ID,
            oks.WORK_THRU_YN,
            oks.REACT_ACTIVE_YN,
            oks.SFWT_FLAG,
            oks.REACT_TIME_NAME,
            oks.discount_list discount_list,
            oks.offset_period offset_period,
            oks.offset_duration offset_duration,
            oks.allow_bt_discount allow_bt_discount,
            oks.apply_default_timezone apply_default_timezone,
            oks.OBJECT_VERSION_NUMBER OBJECT_VERSION_NUMBER
    FROM    okc_k_lines_b lines1,
            oks_k_lines_v oks
    WHERE   lines1.cle_id =  p_cle_id
    AND     oks.cle_id = lines1.id
    AND     lines1.lse_id IN (4,17,22)
    ORDER BY lines1.line_number,lines1.start_date, lines1.end_date;

/*
  CURSOR  CUR_GET_NEW_RT(P_Bp_line_Id IN NUMBER,P_new_dnz_chr_id IN NUMBER,l_new_Bp_Object1_ID1 IN NUMBER,
                                                        l_orig_system_id1 IN NUMBER) IS

    SELECT RT.ID,
           RT.DNZ_CHR_ID
    FROM   okc_k_lines_b   BT,
           okc_k_lines_B    RT,
           okc_k_items      BT_Item
    WHERE   BT.id =   P_Bp_line_Id
    AND     BT.dnz_chr_id = P_new_dnz_chr_id
    AND    BT.lse_id IN (3,16,21)
    AND    BT.ID = RT.cle_id
    AND    RT.lse_id in(4,17,22)
    AND    BT_ITEM.cle_id =    BT.id
    AND    BT_ITEM.DNZ_CHR_ID =BT.DNZ_CHR_ID
    AND    to_number(BT_ITEM.Object1_id1) =l_new_Bp_Object1_ID1 --1000
    AND    RT.dnz_chr_id = BT_ITEM.dnz_chr_id
        AND        RT.orig_system_id1   = l_orig_system_id1;
    */

 -- CURSOR CUR_GET_NEW_RT modified for bug#4155384 - smohapat
    CURSOR  CUR_GET_NEW_RT(p_bp_line_id IN NUMBER,p_old_rt_id in number) IS
    SELECT RT.ID,
           RT.DNZ_CHR_ID
    FROM   okc_k_lines_b   RT
    WHERE  RT.cle_id = p_bp_line_id
    AND    RT.lse_id in(4,17,22)
        AND        RT.orig_system_id1   = p_old_rt_id;



    CURSOR Get_Old_Act_Time_Types(P_RT_ID   IN NUMBER,P_DNZ_CHR_ID IN NUMBER)  IS
    SELECT  ID,
            DNZ_CHR_ID,
            ACTION_TYPE_CODE,
            OBJECT_VERSION_NUMBER
    FROM    OKS_ACTION_TIME_TYPES
    WHERE   CLE_ID =  P_RT_ID
    AND     DNZ_CHR_ID  =    P_DNZ_CHR_ID;

    CURSOR Get_Old_Act_Times_Cur    (p_act_pvt_ID   IN NUMBER,P_Act_Dnz_Chr_ID  IN NUMBER) IS
    SELECT      ID,
                COV_ACTION_TYPE_ID,
                CLE_ID,
                DNZ_CHR_ID,
                UOM_CODE,
                SUN_DURATION,
                MON_DURATION,
                TUE_DURATION,
                WED_DURATION,
                THU_DURATION,
                FRI_DURATION,
                SAT_DURATION,
                SECURITY_GROUP_ID,
                OBJECT_VERSION_NUMBER
    FROM        OKS_ACTION_TIMES
    WHERE       COV_ACTION_TYPE_ID  =   p_act_pvt_ID
    AND         DNZ_CHR_ID          =   P_Act_Dnz_Chr_ID;

 -- Get Old And new Billing Types
/*
 CURSOR CUR_GET_OLD_BT(p_id IN NUMBER) IS
 SELECT lines1.id bp_line_id, lines1.start_date start_date, lines1.end_date end_date,
        lines2.id bt_line_id, lines2.dnz_chr_id dnz_chr_id,
        lines2.object_version_number object_version_number,
        lines2.line_number line_number,
         to_number(items1.object1_id1) busi_proc_id,
         to_number(items2.object1_id1) bill_type_id,
         oks.discount_amount  discount_amount,
         oks.discount_percent discount_percent
         FROM okc_k_lines_b lines1,
              okc_k_lines_b lines2,
              oks_k_lines_b oks,
              okc_k_items items1,
              okc_k_items items2
         WHERE lines1.id = p_id
         AND   lines2.cle_id = lines1.id
         AND items1.cle_id = lines1.id
         AND items2.cle_id = lines2.id
         AND items1.jtot_object1_code = 'OKX_BUSIPROC'
         AND items2.jtot_object1_code = 'OKX_BILLTYPE'
         AND oks.cle_id = lines2.id
         AND items1.dnz_chr_id = lines1.dnz_chr_id
         AND items2.dnz_chr_id = lines2.dnz_chr_id
         AND lines1.lse_id IN (3,16,21)
         AND lines2.lse_id IN (5,23,59)
         ORDER BY busi_proc_id, bill_type_id, lines1.start_date, lines1.end_date;
*/

 -- CURSOR CUR_GET_OLD_BT modified for bug#4155384 - smohapat

 CURSOR CUR_GET_OLD_BT(p_bp_id IN NUMBER) IS
 SELECT lines1.id bt_line_id, lines1.start_date start_date, lines1.end_date end_date,
        lines2.dnz_chr_id dnz_chr_id,
        lines2.object_version_number object_version_number,
        lines1.line_number line_number,
        lines2.discount_amount  discount_amount,
        lines2.discount_percent discount_percent
  FROM  okc_k_lines_b lines1,
        oks_k_lines_b lines2
  WHERE lines1.cle_id = p_bp_id
  AND   lines2.cle_id = lines1.id
  AND   lines1.lse_id IN (5,23,59);


/*
 CURSOR CUR_GET_NEW_BT(p_id IN NUMBER,p_object2_id IN NUMBER) IS
 SELECT lines1.id bp_line_id, lines1.start_date start_date, lines1.end_date end_date,
        lines2.id bt_line_id, lines2.dnz_chr_id dnz_chr_id,
        lines2.object_version_number object_version_number,
         to_number(items1.object1_id1) busi_proc_id,
         to_number(items2.object1_id1) bill_type_id
         FROM okc_k_lines_b lines1,
              okc_k_lines_b lines2,
              okc_k_items items1,
              okc_k_items items2
         WHERE lines1.id = p_id
         AND   lines2.cle_id = lines1.id
--         AND   lines2.line_number = p_line_number
         AND items1.cle_id = lines1.id
         AND items2.cle_id = lines2.id
         AND items1.jtot_object1_code = 'OKX_BUSIPROC'
         AND items2.jtot_object1_code = 'OKX_BILLTYPE'
         AND to_number(items2.object1_id1) = p_object2_id
         AND items1.dnz_chr_id = lines1.dnz_chr_id
         AND items2.dnz_chr_id = lines2.dnz_chr_id
         AND lines1.lse_id IN (3,16,21)
         AND lines2.lse_id IN (5,23,59)
         ORDER BY busi_proc_id, bill_type_id, lines1.start_date, lines1.end_date;


*/

        -- CURSOR CUR_GET_NEW_BT modified for bug#4155384 - smohapat

        CURSOR CUR_GET_NEW_BT(p_bp_line_id IN NUMBER,p_old_bt_id in number) IS
        SELECT BT.id bt_line_id, BT.start_date start_date,BT.dnz_chr_id,
               BT.end_date end_date,BT.object_version_number
        FROM okc_k_lines_b BT
        WHERE BT.cle_id = p_bp_line_id
        AND BT.lse_id IN (5,23,59)
        AND BT.orig_system_id1  = p_old_bt_id;


   -- get the old and new bill rates
   /*
    CURSOR CUR_GET_OLD_BILL_RATE(p_id IN NUMBER,p_object1_id1 IN NUMBER)IS
    SELECT BTY.id BT_LINE_ID,
           BTY.start_date start_date,
           BTY.end_date end_date,
           BRT.id BR_LINE_ID,
           BRT.line_number line_number,
           TO_NUMBER(BTY_ITEM.object1_id1) bill_type_id,
           BRS.start_hour start_hour,
           BRS.start_minute start_minute,
           BRS.end_hour end_hour,
           BRS.end_minute end_minute,
           BRS.monday_flag monday_flag,
           BRS.tuesday_flag tuesday_flag,
           BRS.wednesday_flag wednesday_flag,
           BRS.thursday_flag thursday_flag,
           BRS.friday_flag friday_flag,
           BRS.saturday_flag saturday_flag,
           BRS.sunday_flag sunday_flag,
           BRS.object1_id1 object1_id1,
           BRS.object1_id2 object1_id2,
           BRS.jtot_object1_code jtot_object1_code,
           BRS.bill_rate_code bill_rate_code,
           BRS.flat_rate flat_rate,
           BRS.uom uom,
           BRS.holiday_yn holiday_yn,
           BRS.percent_over_list_price percent_over_list_price,
           BRS.object_version_number object_version_number --Added
    FROM   okc_k_lines_b BTY,
           okc_k_lines_b BRT,
           okc_k_items   BTY_ITEM,
           oks_billrate_schedules BRS
    WHERE  BTY.id = p_id --274672627862321176435113785401106834939--
    AND    BTY.lse_id IN (5,23,59)
--    AND    BRT.line_number = p_line_number
    AND    BTY_ITEM.cle_id = BTY.id
    AND    BTY_ITEM.dnz_chr_id = BTY.dnz_chr_id
    AND    BTY_ITEM.jtot_object1_code = 'OKX_BILLTYPE'
    AND    TO_NUMBER(BTY_ITEM.object1_id1) = p_object1_id1
    AND    BTY.id = BRT.cle_id
    AND    BRT.lse_id IN (6,24,60)
    AND    BRS.cle_id = BRT.id
    ORDER BY  BRT.line_number ,BTY.start_date,BTY.end_date,bill_type_id;

    */

     -- CURSOR CUR_GET_OLD_BILL_RATE modified for bug#4155384 - smohapat
     CURSOR CUR_GET_OLD_BILL_RATE(p_id IN NUMBER)IS
     SELECT
           BRS.cle_id,
           BRS.start_hour start_hour,
           BRS.start_minute start_minute,
           BRS.end_hour end_hour,
           BRS.end_minute end_minute,
           BRS.monday_flag monday_flag,
           BRS.tuesday_flag tuesday_flag,
           BRS.wednesday_flag wednesday_flag,
           BRS.thursday_flag thursday_flag,
           BRS.friday_flag friday_flag,
           BRS.saturday_flag saturday_flag,
           BRS.sunday_flag sunday_flag,
           BRS.object1_id1 object1_id1,
           BRS.object1_id2 object1_id2,
           BRS.jtot_object1_code jtot_object1_code,
           BRS.bill_rate_code bill_rate_code,
           BRS.flat_rate flat_rate,
           BRS.uom uom,
           BRS.holiday_yn holiday_yn,
           BRS.percent_over_list_price percent_over_list_price,
           BRS.object_version_number object_version_number --Added
    FROM   oks_billrate_schedules BRS
    WHERE  BRS.bt_cle_id = p_id ;



/*
    CURSOR CUR_GET_NEW_BILL_RATE(p_id IN NUMBER,p_object1_id1 IN NUMBER)IS
    SELECT BTY.ID BT_LINE_ID,
           BTY.start_date start_date,
           BTY.end_date end_date,
           BTY.line_number line_number,
           BRT.ID BR_LINE_ID,
           BRT.dnz_chr_id dnz_chr_id,
           TO_NUMBER(BTY_ITEM.object1_id1) bill_type_id
    FROM   okc_k_lines_b BTY,
           okc_k_lines_b BRT,
           okc_k_items   BTY_ITEM
    WHERE  BTY.id =p_id
  --  AND    BTY.line_Number = p_line_number
    AND    BTY.lse_id IN (5,23,59)
    AND    BTY.id = BTY_ITEM.cle_id
    AND    BTY_ITEM.dnz_chr_id = BTY.dnz_chr_id
    AND    BTY_ITEM.jtot_object1_code = 'OKX_BILLTYPE'
    AND    BRT.cle_id = BTY.id
    AND    BRT.lse_id IN (6,24,60)
    AND    TO_NUMBER(BTY_ITEM.object1_id1) = p_object1_id1
    ORDER BY  BTY.start_date,BTY.end_date,bill_type_id;
*/

     -- CURSOR CUR_GET_NEW_BILL_RATE modified for bug#4155384 - smohapat

    CURSOR CUR_GET_NEW_BILL_RATE(p_bt_id IN NUMBER,p_old_brs_id IN NUMBER)IS
    SELECT BRT.ID BRS_LINE_ID,
           BRT.CLE_ID BRS_CLE_LINE_ID,
           BRT.dnz_chr_id dnz_chr_id
    FROM   okc_k_lines_b BRT
    WHERE  BRT.cle_id = p_bt_id
    AND    BRT.lse_id IN (6,24,60)
    AND    BRT.orig_system_id1  = p_old_brs_id;


    -- get the old and new coverage timezones and covered times for the business process

    CURSOR CUR_GET_OLD_BUSI_PROC(p_cle_id IN NUMBER)
    IS
     SELECT lines1.id OLD_BP_LINE_ID,
            to_number(items.object1_id1) old_busi_proc_id
     FROM   okc_k_lines_b lines1,
            okc_k_items items
     WHERE  lines1.cle_id = p_cle_id
     AND    lines1.lse_id IN (3,16,21)
     AND    items.cle_id = lines1.id
     AND    items.jtot_object1_code = 'OKX_BUSIPROC'
     AND    items.dnz_chr_id = lines1.dnz_chr_id;

/*

CURSOR CUR_GET_OLD_COV_TZ(p_id IN NUMBER,p_cle_id IN NUMBER)    IS
     SELECT tze.id timezone_line_id, tze.cle_id timezone_cle_id,
            tze.timezone_id timezone_id,tze.default_yn default_yn,
            tze.dnz_chr_id tze_dnz_chr_id,tze.object_version_number tze_object_version_number,
            to_number(items.object1_id1) busi_proc_id
     FROM   OKC_K_LINES_B lines1,
                        okc_k_items items,
            oks_coverage_timezones tze
     WHERE  lines1.id     = p_id
     AND    lines1.cle_id = p_cle_id
     AND    lines1.lse_id IN (3,16,21)
     AND    items.cle_id = lines1.id
     and    items.jtot_object1_code = 'OKX_BUSIPROC'
     And    items.dnz_chr_id = lines1.dnz_chr_id
     And    lines1.dnz_chr_id = tze.dnz_chr_id
     AND    tze.cle_id = lines1.id
     ORDER BY   to_number(items.object1_id1),
                                lines1.start_date, lines1.end_date, tze.timezone_id;

*/
     -- CURSOR CUR_GET_OLD_COV_TZ modified for bug#4155384 - smohapat
     CURSOR CUR_GET_OLD_COV_TZ(p_bp_line_id IN NUMBER)    IS
     SELECT tze.id timezone_line_id, tze.cle_id timezone_cle_id,
            tze.timezone_id timezone_id,tze.default_yn default_yn,
            tze.dnz_chr_id tze_dnz_chr_id,tze.object_version_number tze_object_version_number
     FROM   oks_coverage_timezones tze
     WHERE  tze.cle_id = p_bp_line_id;



CURSOR CUR_GET_OLD_Times(p_cle_id IN NUMBER,p_dnz_chr_id IN NUMBER)    IS

    SELECT          times.id cover_time_line_id,
                    times.dnz_chr_id times_dnz_chr_id,
                    times.start_hour start_hour,
                    times.start_minute start_minute,
                    times.end_hour end_hour,
                    times.end_minute end_minute,
                    times.monday_yn monday_yn,
                    times.tuesday_yn tuesday_yn,
                    times.wednesday_yn wednesday_yn,
                    times.thursday_yn thursday_yn,
                    times.friday_yn friday_yn,
                    times.saturday_yn saturday_yn,
                    times.sunday_yn sunday_yn,
                    times.object_version_number object_version_number
     FROM           OKS_COVERAGE_TIMES TIMES
     WHERE          TIMES.COV_TZE_LINE_ID = p_cle_id
     AND            TIMES.DNZ_CHR_ID      = p_dnz_chr_id;

   CURSOR CUR_GET_NEW_BUSI_PROC_ID(p_cle_id IN NUMBER, p_busi_proc_id IN NUMBER)
    IS
     SELECT lines1.id NEW_BP_LINE_ID, lines1.dnz_chr_id new_dnz_chr_id,
            to_number(items1.object1_id1) busi_proc_id
     FROM   okc_k_lines_b lines1,
            okc_k_items items1
     WHERE  lines1.cle_id = p_cle_id
     AND    lines1.lse_id IN (3,16,21)
     AND    items1.cle_id = lines1.id
     AND    items1.jtot_object1_code = 'OKX_BUSIPROC'
     AND    to_number(items1.object1_id1) = p_busi_proc_id
     ORDER BY to_number(items1.object1_id1), lines1.start_date, lines1.end_date ;

       cu_get_new_busi_proc_id cur_get_new_busi_proc_id%ROWTYPE ;

    CURSOR  Bill_rate_CUR (P_ID IN NUMBER,P_Dnz_Chr_ID IN NUMBER) IS
    SELECT  id,
            dnz_chr_id
    FROM    okc_k_lines_b
    WHERE   cle_id  = p_id
    AND     dnz_chr_id = P_Dnz_Chr_ID;


      l_new_bp_exists   BOOLEAN   := FALSE;
      l_new_br_exists   BOOLEAN   := FALSE;
      l_new_bt_exists   BOOLEAN   := FALSE;
      l_cov_time_exists BOOLEAN   := FALSE;
      l_Count           Number :=0;
      l_cov_templ_yn    varchar2(1);
      l_pm_program_id   NUMBER;
      l_oks_exist       VARCHAR2(1);

/* Added by jvorugan as part of Copy API Redesign,this function
   checks if oks_k_lines_b record already exists and returns the status */
   FUNCTION CHECK_OKSLINE_EXIST(p_new_cle_id NUMBER,
                                x_oks_exist OUT NOCOPY VARCHAR2) return varchar2  is

    CURSOR check_line_exist IS
    SELECT 1 FROM OKS_K_LINES_B
    WHERE cle_id = p_new_cle_id
    AND rownum=1;

    l_Count     Number := 0;
    x_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
        OPEN check_line_exist;
        FETCH check_line_exist INTO l_Count;
        CLOSE check_line_exist;

        IF l_Count >0
        THEN
           x_oks_exist := 'Y';
        ELSE
           x_oks_exist := 'N';
        END IF;
        RETURN (x_return_status);

    EXCEPTION
    WHEN OTHERS THEN
        OKC_API.set_message(G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            SQLERRM);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	RETURN (x_return_status);

   END CHECK_OKSLINE_EXIST;


      BEGIN

      IF (G_DEBUG_ENABLED = 'Y') THEN
             okc_debug.Set_Indentation('Create_Actual_Coverage');
             okc_debug.log('Entered Copy_Coverage', 2);
      END IF;


      l_new_contract_line_id:= p_contract_line_id ;

      OPEN CUR_GET_ORIG_SYS_ID1(l_new_contract_line_id);
      FETCH cur_get_orig_sys_id1 INTO l_orig_sys_id1;
      CLOSE cur_get_orig_sys_id1;

    -- Added by jvorugan for copyying template
      OPEN check_cov_tmpl(l_new_contract_line_id);
      FETCH check_cov_tmpl INTO l_Count;
      CLOSE check_cov_tmpl;
      IF l_Count > 0
      THEN
          l_cov_templ_yn := 'Y';
      Else
         l_cov_templ_yn := 'N';
      END IF;

      IF l_cov_templ_yn ='N'  -- Get values associated with service line
      THEN
         OPEN CUR_GET_COV_LINE_ID(l_orig_sys_id1);
         FETCH cur_get_cov_line_id INTO cr_cov_line ;
         IF cur_get_cov_line_id%FOUND      THEN
           l_old_cov_line_id    := cr_cov_line.id;
           l_old_dnz_chr_id     := cr_cov_line.dnz_chr_id;
           l_old_cov_start_date := cr_cov_line.start_date;
           l_old_cov_end_date   := cr_cov_line.end_date;
         END IF ;
         CLOSE cur_get_cov_line_id ;

        OPEN CUR_GET_COV_LINE_ID(l_new_contract_line_id);
        FETCH cur_get_cov_line_id INTO cr_cov_line ;
        IF cur_get_cov_line_id%FOUND      THEN
           l_new_cov_line_id    := cr_cov_line.id;
           l_new_dnz_chr_id     := cr_cov_line.dnz_chr_id;
           l_new_cov_start_date := cr_cov_line.start_date;
           l_new_cov_end_date   := cr_cov_line.end_date;
        END IF ;
        CLOSE cur_get_cov_line_id;

      ELSE   -- Get values associated with template
         OPEN CUR_GET_COV_DET(l_orig_sys_id1);
         FETCH CUR_GET_COV_DET INTO cr_cov_det ;
         IF CUR_GET_COV_DET%FOUND      THEN
           l_old_cov_line_id    := cr_cov_det.id;
           l_old_dnz_chr_id     := cr_cov_det.dnz_chr_id;
           l_old_cov_start_date := cr_cov_det.start_date;
           l_old_cov_end_date   := cr_cov_det.end_date;
         END IF ;
         CLOSE CUR_GET_COV_DET ;

         OPEN CUR_GET_COV_DET(l_new_contract_line_id);
         FETCH CUR_GET_COV_DET INTO cr_cov_det ;
         IF CUR_GET_COV_DET%FOUND      THEN
           l_new_cov_line_id    := cr_cov_det.id;
           l_new_dnz_chr_id     := cr_cov_det.dnz_chr_id;
           l_new_cov_start_date := cr_cov_det.start_date;
           l_new_cov_end_date   := cr_cov_det.end_date;
         END IF ;
         CLOSE CUR_GET_COV_DET;

      END IF;


      IF l_old_cov_line_id IS NOT NULL AND l_new_cov_line_id IS NOT NULL   THEN        ---1
      -- Added by Jvorugan if oks_k_lines_b record already exists,then not created
      l_return_status := CHECK_OKSLINE_EXIST(p_new_cle_id =>l_new_cov_line_id,
                                             x_oks_exist  =>l_oks_exist);
      IF (G_DEBUG_ENABLED = 'Y') THEN
              okc_debug.log('AFTER  CHECK_OKSLINE_EXIST1'||l_return_status, 2);
      END IF;

      IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      x_return_status         := l_return_status;
      IF l_oks_exist = 'N'
      THEN
           FOR cov_attr_rec IN CUR_GET_COV_ATTR(l_old_cov_line_id)      LOOP
      INIT_OKS_K_LINE(l_klnv_tbl_in) ;

     l_klnv_tbl_in(1).cle_id             :=  l_new_cov_line_id;
     l_klnv_tbl_in(1).dnz_chr_id         :=  l_new_dnz_chr_id;
     l_klnv_tbl_in(1).coverage_type      :=  cov_attr_rec.coverage_type;
     l_klnv_tbl_in(1).exception_cov_id   :=  cov_attr_rec.exception_cov_id;
     l_klnv_tbl_in(1).transfer_option    :=  cov_attr_rec.transfer_option;
     l_klnv_tbl_in(1).prod_upgrade_yn    :=  cov_attr_rec.prod_upgrade_yn;
     l_klnv_tbl_in(1).inheritance_type   :=  cov_attr_rec.inheritance_type;
     l_klnv_tbl_in(1).sfwt_flag          :=  'N';
     l_klnv_tbl_in(1).sync_date_install  := cov_attr_rec.sync_date_install;
     l_klnv_tbl_in(1).pm_program_id      := cov_attr_rec.pm_program_id;
     l_klnv_tbl_in(1).pm_conf_req_yn     := cov_attr_rec.pm_conf_req_yn;
     l_klnv_tbl_in(1).pm_sch_exists_yn   := cov_attr_rec.pm_sch_exists_yn;
     l_klnv_tbl_in(1).object_version_number := cov_attr_rec.object_version_number;

     OKS_CONTRACT_LINE_PUB.CREATE_LINE(
                                   p_api_version    => l_api_version,
                                   p_init_msg_list  => l_init_msg_list,
                                   x_return_status  => l_return_status,
                                   x_msg_count      => l_msg_count,
                                   x_msg_data       => l_msg_data,
                                   p_klnv_tbl       => l_klnv_tbl_in,
                                   x_klnv_tbl       => l_klnv_tbl_out,
                                   p_validate_yn    => l_validate_yn);


      IF (G_DEBUG_ENABLED = 'Y') THEN
              okc_debug.log('After OKS_CONTRACT_LINE_PUB.CREATE_LINE'||l_return_status, 2);
      END IF;


      IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      x_return_status         := l_return_status;

    IF l_klnv_tbl_in(1).pm_program_id IS NOT NULL THEN -- Copy PM for coverage template
       IF l_cov_templ_yn ='Y'
       THEN
           OKS_PM_PROGRAMS_PVT.Copy_pm_template(
                                              p_api_version  => l_api_version,
                                              p_init_msg_list     =>'T',
                                              x_return_status     => l_return_status,
                                              x_msg_count         => x_msg_count,
                                              x_msg_data          =>  x_msg_data,
                                              p_old_coverage_id   => l_old_cov_line_id,
                                              p_new_coverage_id   => l_new_cov_line_id);
	   IF (G_DEBUG_ENABLED = 'Y') THEN
              okc_debug.log('AFTER CALLING OKS_PM_PROGRAMS_PVT.Copy_pm_template'||l_return_status, 2);
           END IF;

           IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                                RAISE G_EXCEPTION_HALT_VALIDATION;
           END  IF;
       END IF;


    END IF; -- PM Ends

  END LOOP ; -- Coverage End
 END IF; -- End  for oks_line_exist check


 -- BP STARTS HERE

  INIT_OKS_K_LINE(l_klnv_tbl_in) ;
  i:= 0 ;
   FOR old_bp_rec IN CUR_GET_OLD_BP(l_old_cov_line_id)   LOOP  -- OLD BP
    l_klnv_tbl_in.DELETE;
    i:= i + 1 ;
    l_old_bp_line_id                             := old_bp_rec.bp_line_Id;
   -- Added by jvorugan as a part of Copy API Redesign
    FOR new_bp_rec IN CUR_GET_NEW_BP(l_new_cov_line_id , OLD_BP_REC.BP_LINE_ID)    LOOP
        l_new_bp_exists := TRUE;
        l_new_Bp_line_Id            :=  new_bp_rec.bp_line_id;
        l_klnv_tbl_in(i).CLE_ID      := new_bp_rec.bp_line_id;
        l_klnv_tbl_in(i).DNZ_CHR_ID  := new_bp_rec.dnz_chr_id;

    END LOOP ;
      -- Added by Jvorugan if oks_k_lines_b record already exists,then not created
      l_return_status := CHECK_OKSLINE_EXIST(p_new_cle_id =>l_new_Bp_line_Id,
                                             x_oks_exist  =>l_oks_exist);
      IF (G_DEBUG_ENABLED = 'Y') THEN
              okc_debug.log('AFTER  CHECK_OKSLINE_EXIST2'||l_return_status, 2);
      END IF;

      IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      x_return_status         := l_return_status;
      IF l_oks_exist = 'N'
      THEN
        l_klnv_tbl_in(i).DISCOUNT_LIST               := old_bp_rec.discount_list;
        l_klnv_tbl_in(i).OFFSET_DURATION             := old_bp_rec.offset_duration;
        l_klnv_tbl_in(i).OFFSET_PERIOD               := old_bp_rec.offset_period;
        l_klnv_tbl_in(i).ALLOW_BT_DISCOUNT           := old_bp_rec.allow_bt_discount;
        l_klnv_tbl_in(i).APPLY_DEFAULT_TIMEZONE      := old_bp_rec.apply_default_timezone;
        l_klnv_tbl_in(i).OBJECT_VERSION_NUMBER      :=  old_bp_rec.OBJECT_VERSION_NUMBER;

--   i:= 0;

  /*    FOR new_bp_rec IN CUR_GET_NEW_BP(l_new_cov_line_id , OLD_BP_REC.BP_LINE_ID)    LOOP
        l_new_bp_exists := TRUE;
        l_new_Bp_line_Id            :=  new_bp_rec.bp_line_id;
        l_klnv_tbl_in(i).CLE_ID      := new_bp_rec.bp_line_id;
        l_klnv_tbl_in(i).DNZ_CHR_ID  := new_bp_rec.dnz_chr_id;

     END LOOP ; */ --commented by JVORUGAN

         IF l_klnv_tbl_in.COUNT > 0 AND (l_new_bp_exists = TRUE) THEN  -- 2

               OKS_CONTRACT_LINE_PUB.CREATE_LINE(p_api_version    => l_api_version,
                                                 p_init_msg_list  => l_init_msg_list,
                                                 x_return_status  => l_return_status,
                                                 x_msg_count      => l_msg_count,
                                                 x_msg_data       => l_msg_data,
                                                 p_klnv_tbl       => l_klnv_tbl_in,
                                                 x_klnv_tbl       => l_klnv_tbl_out,
                                                 p_validate_yn    => l_validate_yn);

                IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
        x_return_status         := l_return_status;
        END IF ; -- 2 -- BP ENDS HERE
      END IF; -- End  for oks_line_exist check

/****************************************************/


        IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN  ---- For Time Zones

        INIT_OKS_TIMEZONE_LINE(l_timezone_tbl_in);
        INIT_OKS_COVER_TIME_LINE(l_cover_time_tbl_in);

         m:= 0 ;
         n:= 0 ;

        FOR old_times_rec IN CUR_GET_OLD_COV_TZ(l_old_bp_line_id)      LOOP -- TZ LOOP


            m:= m + 1 ;
            l_cov_time_exists := TRUE;

                 --   IF i = 1 OR ((l_tze_id <> old_times_rec.timezone_id) OR(l_bp_id  <> old_times_rec.busi_proc_id))then
                  l_old_Time_Zone_ID                        := old_times_rec.timezone_line_id;
                  l_old_Time_Zone_Dnz_Chr_Id                := old_times_rec.tze_dnz_chr_id;
                  l_timezone_tbl_in(m).DEFAULT_YN       := old_times_rec.default_yn;
                  l_timezone_tbl_in(m).TIMEZONE_ID      := old_times_rec.timezone_id;
                  l_timezone_tbl_in(m).object_version_number    := old_times_rec.tze_object_version_number;


                  l_timezone_tbl_in(m).CLE_ID           := l_new_Bp_line_Id;
                  l_timezone_tbl_in(m).DNZ_CHR_ID       := l_new_dnz_chr_id;


                  -- create the time zone record here
                    OKS_CTZ_PVT.INSERT_ROW(p_api_version                  => l_api_version,
                                           p_init_msg_list                => l_init_msg_list,
                                           x_return_status                => l_return_status,
                                           x_msg_count                    => l_msg_count,
                                           x_msg_data                     => l_msg_data,
                                           p_oks_coverage_timezones_v_tbl => l_timezone_tbl_in,
                                           x_oks_coverage_timezones_v_tbl => l_timezone_tbl_out);


                IF (G_DEBUG_ENABLED = 'Y') THEN
                         okc_debug.log('After OKS_CTZ_PVT INSERT_ROW'||l_return_status, 2);
                END IF;

                            IF  l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                                IF l_timezone_tbl_out.COUNT > 0 THEN
                                    FOR I IN l_timezone_tbl_out.FIRST .. l_timezone_tbl_out.LAST LOOP
                                        l_new_TimeZone_Id :=l_timezone_tbl_out(m).ID;
                                    END LOOP;
                                ELSE
                                    RAISE G_EXCEPTION_HALT_VALIDATION;
                                END IF;
                            ELSE
                               RAISE G_EXCEPTION_HALT_VALIDATION;
                            END IF;


            IF l_new_TimeZone_Id IS NOT NULL THEN
                FOR CUR_GET_OLD_Times_Rec IN CUR_GET_OLD_Times(l_old_Time_Zone_ID,l_old_Time_Zone_Dnz_Chr_Id) LOOP
                  n := n + 1;
                  l_cover_time_tbl_in(n).COV_TZE_LINE_ID        := l_new_TimeZone_Id;
                  l_cover_time_tbl_in(n).DNZ_CHR_ID             := l_new_dnz_chr_id;
                  l_cover_time_tbl_in(n).START_HOUR             := CUR_GET_OLD_Times_Rec.start_hour;
                  l_cover_time_tbl_in(n).START_MINUTE           := CUR_GET_OLD_Times_Rec.start_minute;
                  l_cover_time_tbl_in(n).END_HOUR               := CUR_GET_OLD_Times_Rec.end_hour;
                  l_cover_time_tbl_in(n).END_MINUTE             := CUR_GET_OLD_Times_Rec.end_minute;
                  l_cover_time_tbl_in(n).MONDAY_YN              := CUR_GET_OLD_Times_Rec.monday_yn;
                  l_cover_time_tbl_in(n).TUESDAY_YN             := CUR_GET_OLD_Times_Rec.tuesday_yn;
                  l_cover_time_tbl_in(n).WEDNESDAY_YN           := CUR_GET_OLD_Times_Rec.wednesday_yn;
                  l_cover_time_tbl_in(n).THURSDAY_YN            := CUR_GET_OLD_Times_Rec.thursday_yn;
                  l_cover_time_tbl_in(n).FRIDAY_YN              := CUR_GET_OLD_Times_Rec.friday_yn;
                  l_cover_time_tbl_in(n).SATURDAY_YN            := CUR_GET_OLD_Times_Rec.saturday_yn;
                  l_cover_time_tbl_in(n).SUNDAY_YN              := CUR_GET_OLD_Times_Rec.sunday_yn;
                  l_cover_time_tbl_in(n).Object_version_number  := CUR_GET_OLD_Times_Rec.Object_version_number;
                END LOOP;

                 IF l_Cover_time_tbl_in.COUNT > 0 Then

                  OKS_CVT_PVT.INSERT_ROW(p_api_version               => l_api_version,
                                         p_init_msg_list             => l_init_msg_list,
                                         x_return_status             => l_return_status,
                                         x_msg_count                 => l_msg_count,
                                         x_msg_data                  => l_msg_data,
                                         p_oks_coverage_times_v_tbl  => l_cover_time_tbl_in,
                                         x_oks_coverage_times_v_tbl  => l_cover_time_tbl_out);

                END IF;

                    IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    ELSE
                    l_timezone_tbl_in.DELETE;
                    l_cover_time_tbl_in.DELETE;
                    END IF;

            END IF;


        END LOOP;-- TZ LOOP
      END IF ; --For Time Zones

/************************************************************************************/
-- RT Starts HERE

        FOR REC_GET_OLD_RT IN CUR_GET_OLD_RT(l_old_bp_line_id)   LOOP  -- OLD RT
        l := 0;
        l_klnv_tbl_in.DELETE;
         l := l + 1;

        l_line_NUMBER   :=    REC_GET_OLD_RT.rt_line_number;
        l_RT_ID         :=    REC_GET_OLD_RT.rt_line_id;
        l_rt_dnz_chr_id :=    REC_GET_OLD_RT.rt_dnz_chr_id;

	--Added by JVORUGAN as a part of COPY API Redesign
	FOR new_bp_rec IN CUR_GET_NEW_RT(l_new_Bp_line_Id,REC_GET_OLD_RT.Rt_Line_ID) LOOP --2

            l_klnv_tbl_in(l).CLE_ID      := new_bp_rec.id;
            l_klnv_tbl_in(l).DNZ_CHR_ID  := new_bp_rec.dnz_chr_id;

        END LOOP ; --2
	-- Added by Jvorugan if oks_k_lines_b record already exists,then not created
        l_return_status := CHECK_OKSLINE_EXIST(p_new_cle_id =>l_klnv_tbl_in(l).CLE_ID,
                                               x_oks_exist  =>l_oks_exist);

        IF (G_DEBUG_ENABLED = 'Y') THEN
              okc_debug.log('AFTER  CHECK_OKSLINE_EXIST3'||l_return_status, 2);
        END IF;

        IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        x_return_status         := l_return_status;
        IF l_oks_exist = 'N'
        THEN

        l_klnv_tbl_in(l).DISCOUNT_LIST               := REC_GET_OLD_RT.discount_list;
        l_klnv_tbl_in(l).OFFSET_DURATION             := REC_GET_OLD_RT.offset_duration;
        l_klnv_tbl_in(l).OFFSET_PERIOD               := REC_GET_OLD_RT.offset_period;
        l_klnv_tbl_in(l).ALLOW_BT_DISCOUNT           := REC_GET_OLD_RT.allow_bt_discount;
        l_klnv_tbl_in(l).APPLY_DEFAULT_TIMEZONE      := REC_GET_OLD_RT.apply_default_timezone;
        l_klnv_tbl_in(l).OBJECT_VERSION_NUMBER      :=  REC_GET_OLD_RT.OBJECT_VERSION_NUMBER;
        l_klnv_tbl_in(l).INCIDENT_SEVERITY_ID:=      REC_GET_OLD_RT.INCIDENT_SEVERITY_ID;
        l_klnv_tbl_in(l).WORK_THRU_YN:=  REC_GET_OLD_RT.WORK_THRU_YN;
        l_klnv_tbl_in(l).REACT_ACTIVE_YN:=  REC_GET_OLD_RT.REACT_ACTIVE_YN;
        l_klnv_tbl_in(l).SFWT_FLAG:=REC_GET_OLD_RT.SFWT_FLAG;
        l_klnv_tbl_in(l).REACT_TIME_NAME:= REC_GET_OLD_RT.REACT_TIME_NAME;


        /*        FOR new_bp_rec IN CUR_GET_NEW_RT(l_new_Bp_line_Id,REC_GET_OLD_RT.Rt_Line_ID) LOOP --2

            l_klnv_tbl_in(l).CLE_ID      := new_bp_rec.id;
            l_klnv_tbl_in(l).DNZ_CHR_ID  := new_bp_rec.dnz_chr_id;

            END LOOP ; --2  */ --commented by Jvorugan
         IF l_klnv_tbl_in.COUNT > 0 THEN  -- 2

               OKS_CONTRACT_LINE_PUB.CREATE_LINE(p_api_version    => l_api_version,
                                                 p_init_msg_list  => l_init_msg_list,
                                                 x_return_status  => l_return_status,
                                                 x_msg_count      => l_msg_count,
                                                 x_msg_data       => l_msg_data,
                                                 p_klnv_tbl       => l_klnv_tbl_in,
                                                 x_klnv_tbl       => l_klnv_tbl_out,
                                                 p_validate_yn    => l_validate_yn);


                IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                ELSE
                    l_klnv_tbl_in.DELETE;
                    FOR I IN  l_klnv_tbl_out.FIRST .. l_klnv_tbl_out.LAST LOOP
                        l_line_id_four   :=  l_klnv_tbl_out(I).Cle_ID;
                    END LOOP;
                END IF;
            x_return_status         := l_return_status;
         END IF ; -- 2
        END IF; -- End  for oks_line_exist check

                FOR Get_Old_Act_Time_Types_Rec IN   Get_Old_Act_Time_Types(l_RT_ID,l_rt_dnz_chr_id) LOOP --3
                l_act_pvt_tbl_in.DELETE;
                k := k + 1;
                    l_act_pvt_ID        :=  Get_Old_Act_Time_Types_Rec.ID;

                    l_act_pvt_tbl_in(k).cle_id                  := l_line_id_four;
                    l_act_pvt_tbl_in(k).DNZ_CHR_ID              := l_new_dnz_chr_id ; --Get_Old_Act_Time_Types_Rec.Dnz_Chr_ID;
                    l_act_pvt_tbl_in(k).ACTION_TYPE_CODE        :=Get_Old_Act_Time_Types_Rec.ACTION_TYPE_CODE;
                    l_act_pvt_tbl_in(k).OBJECT_VERSION_NUMBER   :=  Get_Old_Act_Time_Types_Rec.OBJECT_VERSION_NUMBER;

                    oks_act_pvt.insert_row(
                                            p_api_version                   =>      l_api_version,
                                            p_init_msg_list                 =>      l_init_msg_list,
                                            x_return_status                 =>      l_return_status,
                                            x_msg_count                     =>      l_msg_count,
                                            x_msg_data                      =>      l_msg_data,
                                            p_oks_action_time_types_v_tbl   =>      l_act_pvt_tbl_in,
                                            x_oks_action_time_types_v_tbl   =>      l_act_pvt_tbl_out);

                IF (G_DEBUG_ENABLED = 'Y') THEN
                         okc_debug.log('After oks_act_pvt insert_row'||l_return_status, 2);
                END IF;

                    IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    ELSE
                        FOR I IN  l_act_pvt_tbl_out.FIRST .. l_act_pvt_tbl_out.LAST LOOP
                            l_act_pvt_new_id        :=  l_act_pvt_tbl_out(I).ID;
                            l_act_pvt_dnz_chr_id        :=  l_act_pvt_tbl_out(I).dnz_chr_ID;
                            l_Act_pvt_cle_id            :=  l_act_pvt_tbl_out(I).cle_ID;
                        END LOOP;
                    END IF;


                     FOR Get_Old_Act_Times_Rec IN   Get_Old_Act_Times_Cur(l_act_pvt_ID,Get_Old_Act_Time_Types_Rec.Dnz_Chr_ID) LOOP --4
                     l_acm_pvt_tbl_in.DELETE;
                        F := F + 1;
                        l_acm_pvt_tbl_in(f).COV_ACTION_TYPE_ID := l_act_pvt_new_id;
                        l_acm_pvt_tbl_in(f).CLE_ID      :=    l_Act_pvt_cle_id;
                        l_acm_pvt_tbl_in(f).DNZ_CHR_ID  :=    l_act_pvt_dnz_chr_id;
                        l_acm_pvt_tbl_in(f).UOM_CODE    :=      Get_Old_Act_Times_Rec.UOM_CODE;
                        l_acm_pvt_tbl_in(f).SUN_DURATION:=  Get_Old_Act_Times_Rec.SUN_DURATION;
                        l_acm_pvt_tbl_in(f).MON_DURATION:=  Get_Old_Act_Times_Rec.MON_DURATION;
                        l_acm_pvt_tbl_in(f).TUE_DURATION:=  Get_Old_Act_Times_Rec.TUE_DURATION;
                        l_acm_pvt_tbl_in(f).WED_DURATION:=  Get_Old_Act_Times_Rec.WED_DURATION;
                        l_acm_pvt_tbl_in(f).THU_DURATION:=  Get_Old_Act_Times_Rec.THU_DURATION;
                        l_acm_pvt_tbl_in(f).FRI_DURATION:=  Get_Old_Act_Times_Rec.FRI_DURATION;
                        l_acm_pvt_tbl_in(f).SAT_DURATION:=  Get_Old_Act_Times_Rec.SAT_DURATION;
                        l_acm_pvt_tbl_in(f).SECURITY_GROUP_ID:= Get_Old_Act_Times_Rec.SECURITY_GROUP_ID;
                        l_acm_pvt_tbl_in(f).OBJECT_VERSION_NUMBER := Get_Old_Act_Times_Rec.OBJECT_VERSION_NUMBER;


                             OKS_ACM_PVT.insert_row(
                                            p_api_version                   =>      l_api_version,
                                            p_init_msg_list                 =>      l_init_msg_list,
                                            x_return_status                 =>      l_return_status,
                                            x_msg_count                     =>      l_msg_count,
                                            x_msg_data                      =>      l_msg_data,
                                            p_oks_action_times_v_tbl        =>      l_acm_pvt_tbl_in,
                                            x_oks_action_times_v_tbl        =>      l_acm_pvt_tbl_out);

                IF (G_DEBUG_ENABLED = 'Y') THEN
                         okc_debug.log('After OKS_ACM_PVT insert_row'||l_return_status, 2);
                END IF;

                        IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                            RAISE G_EXCEPTION_HALT_VALIDATION;
                        ELSE
                            l_acm_pvt_tbl_in.DELETE;
                            l_act_pvt_tbl_in.DELETE;
                            l_klnv_tbl_in.DELETE;
                        END IF;


                     END LOOP; --4
                     x_return_status         := l_return_status;
                END LOOP;  --3
           END LOOP;  -- OLD RT


-- RT Ends HERE

/******************************************************************************/
       -- BT STARTS HERE

    INIT_OKS_K_LINE(l_klnv_tbl_in) ;

     i := 0;

--FOR old_bt_rec IN CUR_GET_OLD_BT(l_old_cov_line_id)     LOOP --BT LOOP
   FOR old_bt_rec IN CUR_GET_OLD_BT(l_old_bp_line_id)
   LOOP --l_old_bp_line_id)  LOOP
                l_klnv_tbl_in.DELETE;
       i:= i + 1 ;


        l_old_bill_type_ID := old_bt_rec.bt_line_id;
        l_old_line_number   := old_bt_rec.line_number;

       l_klnv_tbl_in(i).DISCOUNT_AMOUNT    := old_bt_rec.discount_amount;
       l_klnv_tbl_in(i).DISCOUNT_PERCENT   := old_bt_rec.discount_percent;
       l_klnv_tbl_in(i).object_version_number   := old_bt_rec.object_version_number;

            FOR new_bt_rec IN CUR_GET_NEW_BT(l_new_Bp_line_Id,old_bt_rec.bt_line_id)    LOOP
                l_klnv_tbl_in(i).cle_id       := new_bt_rec.bt_line_id;
                l_klnv_tbl_in(i).dnz_chr_id   := new_bt_rec.dnz_chr_id;
                l_klnv_tbl_in(i).object_version_number   := new_bt_rec.object_version_number;

            END LOOP ;
            -- Added by Jvorugan if oks_k_lines_b record already exists,then not created
       l_return_status := CHECK_OKSLINE_EXIST(p_new_cle_id =>l_klnv_tbl_in(i).cle_id,
                                              x_oks_exist  =>l_oks_exist);
      IF (G_DEBUG_ENABLED = 'Y') THEN
              okc_debug.log('AFTER  CHECK_OKSLINE_EXIST4'||l_return_status, 2);
      END IF;

       IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       x_return_status         := l_return_status;
       IF l_oks_exist = 'N'
       THEN


               OKS_CONTRACT_LINE_PUB.CREATE_LINE(p_api_version    => l_api_version,
                                                 p_init_msg_list  => l_init_msg_list,
                                                 x_return_status  => l_return_status,
                                                 x_msg_count      => l_msg_count,
                                                 x_msg_data       => l_msg_data,
                                                 p_klnv_tbl       => l_klnv_tbl_in,
                                                 x_klnv_tbl       => l_klnv_tbl_out,
                                                 p_validate_yn    => l_validate_yn);

        IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        l_klnv_tbl_in.DELETE;
            FOR I IN l_klnv_tbl_out.FIRST .. l_klnv_tbl_out.LAST LOOP
                l_bill_Type_ID :=  l_klnv_tbl_out(I).CLE_ID;
                l_bill_Type_Dnz_Chr_ID := l_klnv_tbl_out(I).DNZ_CHR_ID;
            END LOOP;
        END IF;
       END IF; -- End  for oks_line_exist check

/****************************************************************************/
l_klnv_tbl_in.DELETE;

FOR Bill_rate_REC IN Bill_rate_CUR (l_bill_Type_ID,l_bill_Type_Dnz_Chr_ID) LOOP
    l_klnv_tbl_in(I).CLE_ID := Bill_rate_REC.ID;
    l_klnv_tbl_in(I).DNZ_CHR_ID := Bill_rate_REC.DNZ_CHR_ID;
    -- Added by Jvorugan if oks_k_lines_b record already exists,then not created
    l_return_status := CHECK_OKSLINE_EXIST(p_new_cle_id =>l_klnv_tbl_in(I).CLE_ID,
                                           x_oks_exist  =>l_oks_exist);
    IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status         := l_return_status;
    IF l_oks_exist = 'N'
    THEN

               OKS_CONTRACT_LINE_PUB.CREATE_LINE(p_api_version    => l_api_version,
                                                 p_init_msg_list  => l_init_msg_list,
                                                 x_return_status  => l_return_status,
                                                 x_msg_count      => l_msg_count,
                                                 x_msg_data       => l_msg_data,
                                                 p_klnv_tbl       => l_klnv_tbl_in,
                                                 x_klnv_tbl       => l_klnv_tbl_out,
                                                 p_validate_yn    => l_validate_yn);



        IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    END IF; -- End  for oks_line_exist check
 END LOOP;

/*****************************************************************************/

  INIT_BILL_RATE_LINE(l_billrate_sch_tbl_in) ;

     i := 0;
        l_billrate_sch_tbl_in.DELETE;

      FOR old_brs_rec IN CUR_GET_OLD_BILL_RATE(l_old_bill_type_ID)      LOOP
         i:= i + 1 ;

        l_billrate_sch_tbl_in(i).start_hour                 := old_brs_rec.start_hour;
        l_billrate_sch_tbl_in(i).start_minute               := old_brs_rec.start_minute;
        l_billrate_sch_tbl_in(i).end_hour                   := old_brs_rec.end_hour;
        l_billrate_sch_tbl_in(i).end_minute                 := old_brs_rec.end_minute;
        l_billrate_sch_tbl_in(i).monday_flag                := old_brs_rec.monday_flag;
        l_billrate_sch_tbl_in(i).tuesday_flag               := old_brs_rec.tuesday_flag;
        l_billrate_sch_tbl_in(i).wednesday_flag             := old_brs_rec.wednesday_flag;
        l_billrate_sch_tbl_in(i).thursday_flag              := old_brs_rec.thursday_flag;
        l_billrate_sch_tbl_in(i).friday_flag                := old_brs_rec.friday_flag;
        l_billrate_sch_tbl_in(i).saturday_flag              := old_brs_rec.saturday_flag;
        l_billrate_sch_tbl_in(i).sunday_flag                := old_brs_rec.sunday_flag;
        l_billrate_sch_tbl_in(i).object1_id1                := old_brs_rec.object1_id1;
        l_billrate_sch_tbl_in(i).object1_id2                := old_brs_rec.object1_id2;
        l_billrate_sch_tbl_in(i).jtot_object1_code          := old_brs_rec.jtot_object1_code;
        l_billrate_sch_tbl_in(i).bill_rate_code             := old_brs_rec.bill_rate_code;
        l_billrate_sch_tbl_in(i).uom                        := old_brs_rec.uom;
        l_billrate_sch_tbl_in(i).flat_rate                  := old_brs_rec.flat_rate;
        l_billrate_sch_tbl_in(i).holiday_yn                 := old_brs_rec.holiday_yn ;
        l_billrate_sch_tbl_in(i).percent_over_list_price    := old_brs_rec.percent_over_list_price;
        l_billrate_sch_tbl_in(i).object_version_number      := old_brs_rec.object_version_number;


          FOR new_brs_rec IN CUR_GET_NEW_BILL_RATE(l_bill_type_ID ,old_brs_rec.cle_id )   LOOP
                l_billrate_sch_tbl_in(i).cle_id         := new_brs_rec.BRS_LINE_ID;
                l_billrate_sch_tbl_in(i).bt_cle_id      := new_brs_rec.BRS_CLE_LINE_ID;
                l_billrate_sch_tbl_in(i).dnz_chr_id     := new_brs_rec.dnz_chr_id;
          END LOOP ;
      END LOOP ;

           IF l_billrate_sch_tbl_in.count > 0 then

                        oks_brs_pvt.insert_row(p_api_version                  => l_api_version,
                                               p_init_msg_list                => l_init_msg_list,
                                               x_return_status                => l_return_status,
                                               x_msg_count                    => l_msg_count,
                                               x_msg_data                     => l_msg_data,
                                               p_oks_billrate_schedules_v_tbl => l_billrate_sch_tbl_in,
                                               x_oks_billrate_schedules_v_tbl => l_billrate_sch_tbl_out);


                IF (G_DEBUG_ENABLED = 'Y') THEN
                         okc_debug.log('After oks_brs_pvt insert_row'||l_return_status, 2);
                END IF;

         IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
               RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

            x_return_status := l_return_status;
       END IF ;

      -- BR ENDs HERE

      x_return_status         := l_return_status;

/****************************************************************************/
END LOOP ;  --BT LOOP
/****************************************************************/

       x_return_status   := l_return_status;


 END LOOP;   -- OLD BP --BP ENDS

END IF; ---1

COPY_NOTES (p_api_version           =>  l_api_version,
            p_init_msg_list         =>  l_init_msg_list,
            p_line_id               =>  l_new_contract_line_id,
            x_return_status         =>  l_return_status,
            x_msg_count             =>  l_msg_count,
            x_msg_data              =>  l_msg_data);
      IF (G_DEBUG_ENABLED = 'Y') THEN
              okc_debug.log('AFTER  COPY_NOTES'||l_return_status, 2);
      END IF;


         IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
               RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

-- Added as part of R12 coverage Rearchitecture,create Pm schedule and associate with the service line but not coverage line
 IF l_cov_templ_yn ='N'  -- Create pm schedule only if it's not a coverage template
 THEN
    OPEN CUR_GET_PROGRAM_ID(l_orig_sys_id1);
    FETCH CUR_GET_PROGRAM_ID INTO l_pm_program_id;
    CLOSE CUR_GET_PROGRAM_ID;

    IF l_pm_program_id IS NOT NULL   --Generate schedule only if pm_program_id exists
    THEN
         OKS_PM_PROGRAMS_PVT.RENEW_PM_PROGRAM_SCHEDULE(
                                                        p_api_version    => l_api_version,
                                                        p_init_msg_list  => l_init_msg_list,
                                                        x_return_status  => l_return_status,
                                                        x_msg_count      => l_msg_count,
                                                        x_msg_data       => l_msg_data,
                                                        p_contract_line_id => l_new_contract_line_id);


           IF (G_DEBUG_ENABLED = 'Y') THEN
                 okc_debug.log('After RENEW_PM_PROGRAM_SCHEDULE'||l_return_status, 2);
           END IF;


           IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                                RAISE G_EXCEPTION_HALT_VALIDATION;
           END  IF;
    END IF;
 END IF;
-- End changes for coverage Rearchitecture by jvorugan

x_return_status:= OKC_API.G_RET_STS_SUCCESS;
l_klnv_tbl_in.DELETE;
l_billrate_sch_tbl_in.DELETE;
l_timezone_tbl_in.DELETE;
l_cover_time_tbl_in.DELETE;


         IF (G_DEBUG_ENABLED = 'Y') THEN
                     okc_debug.log('End of Copy_Coverage'||l_return_status, 2);
                     okc_debug.Reset_Indentation;
         END IF;

      EXCEPTION

        WHEN G_EXCEPTION_HALT_VALIDATION THEN

         IF (G_DEBUG_ENABLED = 'Y') THEN
                     okc_debug.log('Exp of Copy_Coverage'||SQLERRM, 2);
                     okc_debug.Reset_Indentation;
         END IF;
      x_return_status := l_return_status ;
      x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'OKS_COPY_COVERAGE',
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
         IF (G_DEBUG_ENABLED = 'Y') THEN
                     okc_debug.log('Exp of Copy_Coverage'||SQLERRM, 2);
                     okc_debug.Reset_Indentation;
         END IF;
      x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'OKS_COPY_COVERAGE',
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

         IF (G_DEBUG_ENABLED = 'Y') THEN
                     okc_debug.log('Exp of Copy_Coverage'||SQLERRM, 2);
                     okc_debug.Reset_Indentation;
         END IF;
      x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'OKS_COPY_COVERAGE',
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN

         IF (G_DEBUG_ENABLED = 'Y') THEN
                     okc_debug.log('Exp of Copy_Coverage'||SQLERRM, 2);
                     okc_debug.Reset_Indentation;
         END IF;
      OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1          => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
       -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count :=l_msg_count;


END Copy_Coverage;

--===========================================================================================

   PROCEDURE INIT_OKS_K_LINE(x_klnv_tbl  OUT NOCOPY OKS_KLN_PVT.klnv_tbl_type)
IS


BEGIN


 x_klnv_tbl(1).ID                     :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CLE_ID                 :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).DNZ_CHR_ID             :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).DISCOUNT_LIST          :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).ACCT_RULE_ID           :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).PAYMENT_TYPE           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).CC_NO                  :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).CC_EXPIRY_DATE         :=  OKC_API.G_MISS_DATE;
 x_klnv_tbl(1).CC_BANK_ACCT_ID        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CC_AUTH_CODE           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).COMMITMENT_ID          :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).LOCKED_PRICE_LIST_ID   :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).USAGE_EST_YN           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).USAGE_EST_METHOD       :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).USAGE_EST_START_DATE   :=  OKC_API.G_MISS_DATE;
 x_klnv_tbl(1).TERMN_METHOD           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).UBT_AMOUNT             :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CREDIT_AMOUNT          :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).SUPPRESSED_CREDIT      :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).OVERRIDE_AMOUNT        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).GRACE_DURATION         :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).GRACE_PERIOD           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).INV_PRINT_FLAG         :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).PRICE_UOM              :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TAX_AMOUNT             :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).TAX_INCLUSIVE_YN       :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TAX_STATUS             :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TAX_CODE               :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).TAX_EXEMPTION_ID       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).IB_TRANS_TYPE          :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).IB_TRANS_DATE          :=  OKC_API.G_MISS_DATE;
 x_klnv_tbl(1).PROD_PRICE             :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).SERVICE_PRICE          :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CLVL_LIST_PRICE        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CLVL_QUANTITY          :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CLVL_EXTENDED_AMT      :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CLVL_UOM_CODE          :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TOPLVL_OPERAND_CODE    :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TOPLVL_OPERAND_VAL     :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).TOPLVL_QUANTITY        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).TOPLVL_UOM_CODE        :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TOPLVL_ADJ_PRICE       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).TOPLVL_PRICE_QTY       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).AVERAGING_INTERVAL     :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).SETTLEMENT_INTERVAL    :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).MINIMUM_QUANTITY       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).DEFAULT_QUANTITY       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).AMCV_FLAG              :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).FIXED_QUANTITY         :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).USAGE_DURATION         :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).USAGE_PERIOD           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).LEVEL_YN               :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).USAGE_TYPE             :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).UOM_QUANTIFIED         :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).BASE_READING           :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).BILLING_SCHEDULE_TYPE  :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).COVERAGE_TYPE          :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).EXCEPTION_COV_ID       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).LIMIT_UOM_QUANTIFIED   :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).DISCOUNT_AMOUNT        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).DISCOUNT_PERCENT       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).OFFSET_DURATION        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).OFFSET_PERIOD          :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).INCIDENT_SEVERITY_ID   :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).PDF_ID                 :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).WORK_THRU_YN           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).REACT_ACTIVE_YN        :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TRANSFER_OPTION        :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).PROD_UPGRADE_YN        :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).INHERITANCE_TYPE       :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).PM_PROGRAM_ID          :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).PM_CONF_REQ_YN         :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).PM_SCH_EXISTS_YN       :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).ALLOW_BT_DISCOUNT      :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).APPLY_DEFAULT_TIMEZONE :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).SYNC_DATE_INSTALL      :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).SFWT_FLAG              :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).OBJECT_VERSION_NUMBER  :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).SECURITY_GROUP_ID      :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).REQUEST_ID             :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CREATED_BY             :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CREATION_DATE          :=  OKC_API.G_MISS_DATE;
 x_klnv_tbl(1).LAST_UPDATED_BY        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).LAST_UPDATE_DATE       :=  OKC_API.G_MISS_DATE;
 x_klnv_tbl(1).LAST_UPDATE_LOGIN      :=  OKC_API.G_MISS_NUM;
END  ;

--================================================================================
PROCEDURE INIT_OKS_TIMEZONE_LINE(x_timezone_tbl OUT NOCOPY oks_ctz_pvt.OksCoverageTimezonesVTblType)
IS

BEGIN
                  x_timezone_tbl(1).ID                     := OKC_API.G_MISS_NUM;
                  x_timezone_tbl(1).CLE_ID                 := OKC_API.G_MISS_NUM;
                  x_timezone_tbl(1).DEFAULT_YN             := OKC_API.G_MISS_CHAR;
                  x_timezone_tbl(1).TIMEZONE_ID            := OKC_API.G_MISS_NUM;
                  x_timezone_tbl(1).DNZ_CHR_ID             := OKC_API.G_MISS_NUM;
                  x_timezone_tbl(1).CREATED_BY             := OKC_API.G_MISS_NUM;
                  x_timezone_tbl(1).CREATION_DATE          := OKC_API.G_MISS_DATE;
                  x_timezone_tbl(1).LAST_UPDATED_BY        := OKC_API.G_MISS_NUM;
                  x_timezone_tbl(1).LAST_UPDATE_DATE       := OKC_API.G_MISS_DATE;
                  x_timezone_tbl(1).LAST_UPDATE_LOGIN      := OKC_API.G_MISS_NUM;
                  x_timezone_tbl(1).SECURITY_GROUP_ID      := OKC_API.G_MISS_NUM;
                  x_timezone_tbl(1).PROGRAM_APPLICATION_ID := OKC_API.G_MISS_NUM;
                  x_timezone_tbl(1).PROGRAM_ID             := OKC_API.G_MISS_NUM;
                  x_timezone_tbl(1).PROGRAM_UPDATE_DATE    := OKC_API.G_MISS_DATE;
                  x_timezone_tbl(1).REQUEST_ID             := OKC_API.G_MISS_NUM;

END ;
--=================================================================================
PROCEDURE INIT_OKS_COVER_TIME_LINE(x_cover_time_tbl OUT NOCOPY oks_cvt_pvt.oks_coverage_times_v_tbl_type)

IS
     BEGIN
               x_cover_time_tbl(1).ID                     := OKC_API.G_MISS_NUM;
               x_cover_time_tbl(1).COV_TZE_LINE_ID        := OKC_API.G_MISS_NUM;
               x_cover_time_tbl(1).DNZ_CHR_ID             := OKC_API.G_MISS_NUM;
               x_cover_time_tbl(1).START_HOUR             := OKC_API.G_MISS_NUM;
               x_cover_time_tbl(1).START_MINUTE           := OKC_API.G_MISS_NUM;
               x_cover_time_tbl(1).END_HOUR               := OKC_API.G_MISS_NUM;
               x_cover_time_tbl(1).END_MINUTE             := OKC_API.G_MISS_NUM;
               x_cover_time_tbl(1).MONDAY_YN              := OKC_API.G_MISS_CHAR;
               x_cover_time_tbl(1).TUESDAY_YN             := OKC_API.G_MISS_CHAR;
               x_cover_time_tbl(1).WEDNESDAY_YN           := OKC_API.G_MISS_CHAR;
               x_cover_time_tbl(1).THURSDAY_YN            := OKC_API.G_MISS_CHAR;
               x_cover_time_tbl(1).FRIDAY_YN              := OKC_API.G_MISS_CHAR;
               x_cover_time_tbl(1).SATURDAY_YN            := OKC_API.G_MISS_CHAR;
               x_cover_time_tbl(1).SUNDAY_YN              := OKC_API.G_MISS_CHAR;
               x_cover_time_tbl(1).CREATED_BY             := OKC_API.G_MISS_NUM;
               x_cover_time_tbl(1).CREATION_DATE          := OKC_API.G_MISS_DATE;
               x_cover_time_tbl(1).LAST_UPDATED_BY        := OKC_API.G_MISS_NUM;
               x_cover_time_tbl(1).LAST_UPDATE_DATE       := OKC_API.G_MISS_DATE;
               x_cover_time_tbl(1).LAST_UPDATE_LOGIN      := OKC_API.G_MISS_NUM;
               x_cover_time_tbl(1).SECURITY_GROUP_ID      := OKC_API.G_MISS_NUM;
               x_cover_time_tbl(1).PROGRAM_APPLICATION_ID := OKC_API.G_MISS_NUM;
               x_cover_time_tbl(1).PROGRAM_ID             := OKC_API.G_MISS_NUM;
               x_cover_time_tbl(1).PROGRAM_UPDATE_DATE    := OKC_API.G_MISS_DATE;
               x_cover_time_tbl(1).REQUEST_ID             := OKC_API.G_MISS_NUM;

END ;
--==========================================================================

 PROCEDURE INIT_OKS_ACT_TYPE(x_act_time_tbl OUT NOCOPY OKS_ACT_PVT.OksActionTimeTypesVTblType)
 IS
  BEGIN

    x_act_time_tbl(1).id                              := OKC_API.G_MISS_NUM;
    x_act_time_tbl(1).cle_id                          := OKC_API.G_MISS_NUM;
    x_act_time_tbl(1).dnz_chr_id                      := OKC_API.G_MISS_NUM;
    x_act_time_tbl(1).action_type_code                := OKC_API.G_MISS_CHAR;
    x_act_time_tbl(1).security_group_id               := OKC_API.G_MISS_NUM;
    x_act_time_tbl(1).program_application_id          := OKC_API.G_MISS_NUM;
    x_act_time_tbl(1).program_id                      := OKC_API.G_MISS_NUM;
    x_act_time_tbl(1).program_update_date             := OKC_API.G_MISS_DATE;
    x_act_time_tbl(1).request_id                      := OKC_API.G_MISS_NUM;
    x_act_time_tbl(1).created_by                      := OKC_API.G_MISS_NUM;
    x_act_time_tbl(1).creation_date                   := OKC_API.G_MISS_DATE;
    x_act_time_tbl(1).last_updated_by                 := OKC_API.G_MISS_NUM;
    x_act_time_tbl(1).last_update_date                := OKC_API.G_MISS_DATE;
    x_act_time_tbl(1).last_update_login               := OKC_API.G_MISS_NUM;
END ;
--===============================================================================
PROCEDURE INIT_OKS_ACT_TIME(x_act_type_tbl OUT NOCOPY OKS_ACM_PVT.oks_action_times_v_tbl_type)

IS
   BEGIN

    x_act_type_tbl(1).id                         := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).cov_action_type_id         := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).cle_id                     := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).dnz_chr_id                 := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).uom_code                   := OKC_API.G_MISS_CHAR;
    x_act_type_tbl(1).sun_duration               := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).mon_duration               := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).tue_duration               := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).wed_duration               := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).thu_duration               := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).fri_duration               := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).sat_duration               := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).security_group_id          := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).program_application_id     := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).program_id                 := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).program_update_date        := OKC_API.G_MISS_DATE;
    x_act_type_tbl(1).request_id                 := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).created_by                 := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).creation_date              := OKC_API.G_MISS_DATE;
    x_act_type_tbl(1).last_updated_by            := OKC_API.G_MISS_NUM;
    x_act_type_tbl(1).last_update_date           := OKC_API.G_MISS_DATE;
    x_act_type_tbl(1).last_update_login          := OKC_API.G_MISS_NUM;

 END ;
 --============================================================================

PROCEDURE VALIDATE_COVERTIME(p_tze_line_id   IN NUMBER,
                                 x_days_overlap  OUT  NOCOPY oks_coverages_pvt.billrate_day_overlap_type,
                                 x_return_status OUT  NOCOPY VARCHAR2)
IS
G_PKG_NAME VARCHAR2(40):= 'OKS_COVERAGES_PVT';

TYPE covertime_schedule_rec IS RECORD
 (start_time NUMBER,
  end_time NUMBER);

TYPE covertime_schedule_tbl_type IS TABLE OF covertime_schedule_rec
INDEX BY BINARY_INTEGER;

i number := 0;
l_overlap_yn        VARCHAR2(1);
l_overlap_message   VARCHAR2(200);

l_time_tbl   covertime_schedule_tbl_type;
l_api_name      VARCHAR2(50):= 'VALIDATE_COVERTIME_SCHEDULE';
x_msg_count     NUMBER;
x_msg_data      VARCHAR2(2000);
l_overlap_days  VARCHAR2(1000) := NULL;

CURSOR Cur_monday(l_tze_id IN NUMBER) IS

SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_COVERAGE_TIMES_V
WHERE COV_TZE_LINE_ID = l_tze_id
AND MONDAY_YN = 'Y' ;



CURSOR Cur_tuesday(l_tze_id IN NUMBER) IS
SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_COVERAGE_TIMES_V
WHERE COV_TZE_LINE_ID = l_tze_id
AND TUESDAY_YN = 'Y' ;


CURSOR Cur_wednesday(l_tze_id IN NUMBER) IS
SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_COVERAGE_TIMES_V
WHERE COV_TZE_LINE_ID = l_tze_id
AND WEDNESDAY_YN = 'Y' ;


CURSOR Cur_thursday(l_tze_id IN NUMBER) IS
SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_COVERAGE_TIMES_V
WHERE COV_TZE_LINE_ID = l_tze_id
AND THURSDAY_YN = 'Y' ;


CURSOR Cur_friday(l_tze_id IN NUMBER) IS
SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_COVERAGE_TIMES_V
WHERE COV_TZE_LINE_ID = l_tze_id
AND FRIDAY_YN = 'Y' ;



CURSOR Cur_saturday(l_tze_id IN NUMBER) IS
SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_COVERAGE_TIMES_V
WHERE COV_TZE_LINE_ID = l_tze_id
AND SATURDAY_YN = 'Y' ;


CURSOR Cur_sunday(l_tze_id IN NUMBER) IS
SELECT to_number(START_HOUR||decode(LENGTH(START_MINUTE),1,'0'||START_MINUTE,START_MINUTE)) start_time,
       to_number(END_HOUR||decode(LENGTH(END_MINUTE),1,'0'||END_MINUTE,END_MINUTE)) end_time
FROM OKS_COVERAGE_TIMES_V
WHERE COV_TZE_LINE_ID = l_tze_id
AND SUNDAY_YN = 'Y' ;

--Define cursors for other days.
FUNCTION get_day_meaning (p_day_code IN varchar2)
RETURN varchar2
IS
CURSOR Get_day IS
SELECT meaning from fnd_lookups where lookup_type = 'DAY_NAME'
and lookup_code = p_day_code;
l_day_meaning VARCHAR2(100);

BEGIN
  OPEN Get_day;
  FETCH Get_day INTO l_day_meaning;
  CLOSE Get_day;
  return nvl(l_day_meaning,NULL);
end get_day_meaning ;

PROCEDURE Check_overlap(p_time_tbl IN covertime_schedule_tbl_type,
                        p_overlap_yn OUT NOCOPY Varchar2)
IS

l_start       NUMBER;
l_end         NUMBER;
l_start_new   NUMBER;
l_end_new     NUMBER;
j             NUMBER:= 0;
k             NUMBER:= 0;

BEGIN
p_overlap_yn := 'N';
FOR j in 1 .. p_time_tbl.COUNT
LOOP
l_start := p_time_tbl(j).start_time;
l_end := p_time_tbl(j).end_time;

  FOR k in 1 .. p_time_tbl.COUNT
  LOOP
        l_start_new := p_time_tbl(k).start_time;
        l_end_new := p_time_tbl(k).end_time;
        IF j <> k then
                IF (l_start_new <= l_end and l_start_new >= l_start)
            OR (l_end_new >= l_start and l_end_new <=  l_end) then

            IF (l_start_new = l_end )
                   OR (l_end_new = l_start ) then
                   IF p_overlap_yn <> 'Y' then
                      p_overlap_yn := 'N';
                   END IF ;
                 else
                    p_overlap_yn := 'Y';
             END IF ;


          END IF;
        END IF;
  END LOOP;

END LOOP;


--write the validation logic
END Check_overlap;


BEGIN

x_return_status         := OKC_API.G_RET_STS_SUCCESS;
l_time_tbl.DELETE;
FOR monday_rec IN Cur_monday(p_tze_line_id)
LOOP

i := i + 1;
l_time_tbl(i).start_time := monday_rec.start_time;
l_time_tbl(i).end_time := monday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';

IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.monday_overlap);

   IF x_days_overlap.monday_overlap = 'Y' then
      l_overlap_days := get_day_meaning('MON')||',';
   END IF;

end if;

-- Validating for Tuesday.

l_time_tbl.DELETE;
i := 0;

FOR tuesday_rec IN Cur_tuesday(p_tze_line_id)
LOOP
i := i + 1;
l_time_tbl(i).start_time := tuesday_rec.start_time;
l_time_tbl(i).end_time := tuesday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';
IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.tuesday_overlap);
   IF x_days_overlap.tuesday_overlap = 'Y' then
      l_overlap_days := l_overlap_days||get_day_meaning('TUE')||',';
   END IF;

end if;

-- Validating for wednesday.

l_time_tbl.DELETE;
i := 0;

FOR wednesday_rec IN Cur_wednesday(p_tze_line_id)
LOOP
i := i + 1;
l_time_tbl(i).start_time := wednesday_rec.start_time;
l_time_tbl(i).end_time := wednesday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';
IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.wednesday_overlap);
   IF x_days_overlap.wednesday_overlap = 'Y' then
      l_overlap_days := l_overlap_days||get_day_meaning('WED')||',';
   END IF;

end if;

-- Validating for thursday.

l_time_tbl.DELETE;
i := 0;

FOR thursday_rec IN Cur_thursday(p_tze_line_id)
LOOP
i := i + 1;
l_time_tbl(i).start_time := thursday_rec.start_time;
l_time_tbl(i).end_time := thursday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';
IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.thursday_overlap);
   IF x_days_overlap.thursday_overlap = 'Y' then
      l_overlap_days := l_overlap_days||get_day_meaning('THU')||',';
   END IF;

end if;

-- Validating for friday.

l_time_tbl.DELETE;
i := 0;

FOR friday_rec IN Cur_friday(p_tze_line_id)
LOOP
i := i + 1;
l_time_tbl(i).start_time := friday_rec.start_time;
l_time_tbl(i).end_time := friday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';
IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.friday_overlap);
   IF x_days_overlap.friday_overlap = 'Y' then
      l_overlap_days := l_overlap_days||get_day_meaning('FRI')||',';
   END IF;

end if;

-- Validating for saturday.

l_time_tbl.DELETE;
i := 0;

FOR saturday_rec IN Cur_saturday(p_tze_line_id)
LOOP
i := i + 1;
l_time_tbl(i).start_time := saturday_rec.start_time;
l_time_tbl(i).end_time := saturday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';
IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.saturday_overlap);
   IF x_days_overlap.saturday_overlap = 'Y' then
      l_overlap_days := l_overlap_days||get_day_meaning('SAT')||',';
   END IF;

end if;

-- Validating for sunday.

l_time_tbl.DELETE;
i := 0;

FOR sunday_rec IN Cur_sunday(p_tze_line_id)
LOOP
i := i + 1;
l_time_tbl(i).start_time := sunday_rec.start_time;
l_time_tbl(i).end_time := sunday_rec.end_time;
END LOOP;
l_overlap_yn := 'N';
IF l_time_tbl.COUNT > 0 then
Check_overlap(p_time_tbl => l_time_tbl, p_overlap_yn => x_days_overlap.sunday_overlap);
   IF x_days_overlap.sunday_overlap = 'Y' then
      l_overlap_days := l_overlap_days||get_day_meaning('SUN')||',';
   END IF;

END IF;

   IF l_overlap_days IS not null then
            fnd_message.set_name('OKS','OKS_BILLRATE_DAYS_OVERLAP');
            fnd_message.set_token('DAYS', l_overlap_days);
   END IF;

x_return_status         := OKC_API.G_RET_STS_SUCCESS;

EXCEPTION

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
      ROLLBACK;
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
      ROLLBACK ;

END; -- Validate_covertime;

--===========================================================================
PROCEDURE  MIGRATE_PRIMARY_RESOURCES(p_api_version                   IN NUMBER,
                                          p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                          x_return_status                 OUT NOCOPY VARCHAR2,
                                          x_msg_count                     OUT NOCOPY NUMBER,
                                          x_msg_data                      OUT NOCOPY VARCHAR2)IS



    BEGIN

-- Stubing out this procedure since no more in use.
    Null ;


END MIGRATE_PRIMARY_RESOURCES;


PROCEDURE Version_Coverage(
				p_api_version                  IN NUMBER,
				p_init_msg_list                IN VARCHAR2,
				x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
                p_chr_id                          IN NUMBER,
                p_major_version                IN NUMBER) IS

l_chr_id CONSTANT NUMBER  := p_chr_id;
l_major_version CONSTANT NUMBER  := p_major_version;
l_return_Status VARCHAR2(1);

l_msg_count     NUMBER;
l_msg_data      VARCHAR2(1000);
l_api_version           NUMBER:= 1 ;
l_init_msg_list         VARCHAR2(1):= OKC_API.G_FALSE;
G_EXCEPTION_HALT_VALIDATION EXCEPTION;

BEGIN


l_return_Status := OKS_ACT_PVT.Create_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

IF l_return_Status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;
l_return_Status := OKS_ACM_PVT.Create_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

IF l_return_Status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;
l_return_Status := OKS_CVT_PVT.Create_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

IF l_return_Status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;
l_return_Status := OKS_CTZ_PVT.Create_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);
IF l_return_Status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

l_return_Status := OKS_BRS_PVT.Create_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

IF l_return_Status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

OKS_PM_PROGRAMS_PVT.version_PM(
                p_api_version       =>  l_api_version,
                p_init_msg_list     =>  l_init_msg_list,
                x_return_status     =>  l_return_status,
                x_msg_count         =>  l_msg_count,
                x_msg_data          =>  l_msg_data,
                p_chr_id            =>  l_chr_id,
                p_major_version     =>  l_major_version);


    IF l_return_Status = 'S' THEN
        x_return_status :=  OKC_API.G_RET_STS_SUCCESS;
    ELSE
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN

       OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1                => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
       -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        x_msg_count :=l_msg_count;

    WHEN OTHERS THEN

       OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1                => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Version_Coverage;


PROCEDURE Restore_Coverage(
				p_api_version                  IN NUMBER,
				p_init_msg_list                IN VARCHAR2,
				x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
                p_chr_id                          IN NUMBER) IS

l_chr_id CONSTANT NUMBER  := p_chr_id;
l_major_version CONSTANT NUMBER  := -1;
l_return_Status VARCHAR2(1);

l_msg_count     NUMBER;
l_msg_data      VARCHAR2(1000);
l_api_version           NUMBER:= 1 ;
l_init_msg_list         VARCHAR2(1):= OKC_API.G_FALSE;
G_EXCEPTION_HALT_VALIDATION EXCEPTION;

BEGIN


l_return_Status := OKS_ACT_PVT.Restore_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

IF l_return_Status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

l_return_Status := OKS_ACM_PVT.Restore_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

IF l_return_Status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;
l_return_Status := OKS_CVT_PVT.Restore_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

IF l_return_Status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;
l_return_Status := OKS_CTZ_PVT.Restore_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

IF l_return_Status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;
l_return_Status := OKS_BRS_PVT.Restore_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

IF l_return_Status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

OKS_PM_PROGRAMS_PVT.restore_PM(
                p_api_version       =>  l_api_version,
                p_init_msg_list     =>  l_init_msg_list,
                x_return_status     =>  l_return_status,
                x_msg_count         =>  l_msg_count,
                x_msg_data          =>  l_msg_data,
                p_chr_id            =>  l_chr_id);


    IF l_return_Status = 'S' THEN
        x_return_status :=  OKC_API.G_RET_STS_SUCCESS;
    ELSE
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

EXCEPTION

   WHEN G_EXCEPTION_HALT_VALIDATION THEN

       OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1                => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
       -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        x_msg_count :=l_msg_count;

    WHEN OTHERS THEN

       OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1                => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Restore_Coverage;



PROCEDURE	Delete_History(
    			p_api_version                  IN NUMBER,
    			p_init_msg_list                IN VARCHAR2,
    			x_return_status                OUT NOCOPY VARCHAR2,
    			x_msg_count                    OUT NOCOPY NUMBER,
    			x_msg_data                     OUT NOCOPY VARCHAR2,
    			p_chr_id                       IN NUMBER) IS

l_chr_id CONSTANT NUMBER  := p_chr_id;
l_return_Status VARCHAR2(1);

l_msg_count     NUMBER;
l_msg_data      VARCHAR2(1000);
l_api_version           NUMBER:= 1 ;
l_init_msg_list         VARCHAR2(1):= OKC_API.G_FALSE;
G_EXCEPTION_HALT_VALIDATION EXCEPTION;

BEGIN

DELETE OKS_ACTION_TIME_TYPES_H
WHERE dnz_chr_id = l_chr_id;

DELETE OKS_ACTION_TIMES_H
WHERE dnz_chr_id = l_chr_id;

DELETE OKS_COVERAGE_TIMES_H
WHERE dnz_chr_id = l_chr_id;

DELETE OKS_COVERAGE_TIMEZONES_H
WHERE dnz_chr_id = l_chr_id;

DELETE OKS_BILLRATE_SCHEDULES_H
WHERE dnz_chr_id = l_chr_id;


OKS_PM_PROGRAMS_PVT.Delete_PMHistory(
                p_api_version       =>  l_api_version,
                p_init_msg_list     =>  l_init_msg_list,
                x_return_status     =>  l_return_status,
                x_msg_count         =>  l_msg_count,
                x_msg_data          =>  l_msg_data,
                p_chr_id            =>  l_chr_id);


    IF l_return_Status = 'S' THEN
        x_return_status :=  OKC_API.G_RET_STS_SUCCESS;
    ELSE
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

EXCEPTION

   WHEN G_EXCEPTION_HALT_VALIDATION THEN

       OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1                => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
       -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count :=l_msg_count;
    WHEN OTHERS THEN

       OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1                => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Delete_History;




PROCEDURE Delete_Saved_Version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER) IS

 l_api_version   			NUMBER := 1;
l_init_msg_list            	VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
l_return_status            	VARCHAR2(1);
l_return_msg               	VARCHAR2(2000);
l_msg_count                	NUMBER;
l_msg_data                 	VARCHAR2(2000);
l_api_name                 	VARCHAR2(30):= 'Delete_Saved_Version';
l_chr_id					CONSTANT NUMBER  := p_chr_id;

G_EXCEPTION_HALT_VALIDATION EXCEPTION;
BEGIN

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;


				DELETE OKS_ACTION_TIME_TYPES_H
				WHERE dnz_chr_id = l_chr_id
				And major_version = -1;

				DELETE OKS_ACTION_TIMES_H
				WHERE dnz_chr_id = l_chr_id
				And major_version = -1;

				DELETE OKS_COVERAGE_TIMES_H
				WHERE dnz_chr_id = l_chr_id
				And major_version = -1;

				DELETE OKS_COVERAGE_TIMEZONES_H
				WHERE dnz_chr_id = l_chr_id
				And major_version = -1;

				DELETE OKS_BILLRATE_SCHEDULES_H
				WHERE dnz_chr_id = l_chr_id
				And major_version = -1;




OKS_PM_PROGRAMS_PVT.Delete_PMSaved_Version(
                p_api_version       =>  l_api_version,
                p_init_msg_list     =>  l_init_msg_list,
                x_return_status     =>  l_return_status,
                x_msg_count         =>  l_msg_count,
                x_msg_data          =>  l_msg_data,
                p_chr_id            =>  l_chr_id);


    IF l_return_Status = 'S' THEN
        x_return_status :=  OKC_API.G_RET_STS_SUCCESS;
    ELSE
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

EXCEPTION

   WHEN G_EXCEPTION_HALT_VALIDATION THEN

       OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1                => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
       -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count :=l_msg_count;



    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKC_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PUB');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKC_API.G_RET_STS_UNEXP_ERROR',
       x_msg_count,
       x_msg_data,
       '_PUB');
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK ;
END Delete_Saved_Version;
--===========================================================================

PROCEDURE COPY_K_HDR_NOTES
           (p_api_version           IN NUMBER ,
            p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            p_chr_id               IN NUMBER,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2) IS

l_created_by NUMBER         := NULL;
l_last_updated_by NUMBER    := NULL;
l_last_update_login NUMBER  := NULL;
l_old_Chr_ID    NUMBER := 0;


l_Return_Status Varchar2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(1000);
l_jtf_note_id           NUMBER;
l_jtf_note_contexts_tab jtf_notes_pub.jtf_note_contexts_tbl_type;

CURSOR Get_Orig_System_Id_Cur(l_chr_id IN NUMBER) IS
SELECT ORIG_SYSTEM_ID1, Created_By,LAst_Updated_By,Last_Update_Login
FROM   OKC_K_HEADERS_B
WHERE   ID = l_chr_id;



BEGIN

        --For Get_Orig_System_Id_Rec IN Get_Orig_System_Id_Cur(P_source_object_id) LOOP
        For Get_Orig_System_Id_Rec IN Get_Orig_System_Id_Cur(P_chr_id) LOOP
            l_old_Chr_ID := Get_Orig_System_Id_Rec.ORIG_SYSTEM_ID1;
          /* Modified by Jvorugan for Bug:4489214 who columns not to be populated from old contract
	    l_created_by := Get_Orig_System_Id_Rec.created_by;
            l_last_updated_by := Get_Orig_System_Id_Rec.last_updated_by;
            l_last_update_login := Get_Orig_System_Id_Rec.last_update_login;  */
        END LOOP;

         Get_Notes_Details( P_source_object_id   =>  l_old_chr_id,
                            X_Notes_TBL          =>  l_Notes_TBL,
                            X_Return_Status      =>  l_Return_Status,
                            P_source_object_code =>  'OKS_HDR_NOTE'); -- Bug:5944200



        IF    l_Return_Status = 'S' THEN

            IF   (l_Notes_TBL.COUNT > 0) THEN
                FOR I IN l_Notes_TBL.FIRST .. l_Notes_TBL.LAST LOOP

                JTF_NOTES_PUB.create_note
                  ( p_jtf_note_id           => NULL--:JTF_NOTES.JTF_NOTE_ID
                  , p_api_version           => 1.0
                  , p_init_msg_list         => 'F'
                  , p_commit                => 'F'
                  , p_validation_level      => 0
                  , x_return_status         => l_return_status
                  , x_msg_count             => l_msg_count
                  , x_msg_data              => l_msg_data
                  , p_source_object_code    => l_Notes_TBL(i).source_object_code
                  , p_source_object_id      => p_chr_id
                  , p_notes                 => l_Notes_TBL(i).notes
                  , p_notes_detail          => l_Notes_TBL(i).notes_Detail
                  , p_note_status           => l_Notes_TBL(i).note_status
                  , p_note_type             => l_Notes_TBL(i).note_type
                  , p_entered_by            => l_Notes_TBL(i).entered_by   -- -1 Modified for Bug:4489214
                  , p_entered_date          => l_Notes_TBL(i).entered_date -- SYSDATE Modified for Bug:4489214
                  , x_jtf_note_id           => l_jtf_note_id
                  , p_creation_date         => SYSDATE
                  , p_created_by            => FND_GLOBAL.USER_ID        --  created_by Modified for Bug:4489214
                  , p_last_update_date      => SYSDATE
                  , p_last_updated_by       => FND_GLOBAL.USER_ID        -- l_last_updated_by Modified for Bug:4489214
                  , p_last_update_login     => FND_GLOBAL.LOGIN_ID       -- l_last_update_login Modified for Bug:4489214
                  , p_attribute1            => NULL
                  , p_attribute2            => NULL
                  , p_attribute3            => NULL
                  , p_attribute4            => NULL
                  , p_attribute5            => NULL
                  , p_attribute6            => NULL
                  , p_attribute7            => NULL
                  , p_attribute8            => NULL
                  , p_attribute9            => NULL
                  , p_attribute10           => NULL
                  , p_attribute11           => NULL
                  , p_attribute12           => NULL
                  , p_attribute13           => NULL
                  , p_attribute14           => NULL
                  , p_attribute15           => NULL
                  , p_context               => NULL
                  , p_jtf_note_contexts_tab => l_jtf_note_contexts_tab);

                END LOOP;
            END IF;

        END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;

EXCEPTION

  WHEN OTHERS THEN

      OKC_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END COPY_K_HDR_NOTES;

PROCEDURE Update_dnz_chr_id
           (p_coverage_id          IN NUMBER ,
            p_dnz_chr_id           IN NUMBER) IS

 -- coverage --
   l_clev_tbl_in             okc_contract_pub.clev_tbl_type;
   l_clev_tbl_out            okc_contract_pub.clev_tbl_type;
 -- End --
  -- OKC_K_ITEMS
  l_cimv_tbl_in             okc_contract_item_pub.cimv_tbl_type;
  l_cimv_tbl_out            okc_contract_item_pub.cimv_tbl_type;
  --
  -- OKS_K_LINES_B
     l_klnv_tbl_in            oks_contract_line_pub.klnv_tbl_type ;
    l_klnv_tbl_out           oks_contract_line_pub.klnv_tbl_type ;

  l_timezone_tbl_in    OKS_CTZ_PVT.OksCoverageTimezonesVTblType ;
  l_timezone_tbl_out   OKS_CTZ_PVT.OksCoverageTimezonesVTblType ;

 l_cov_time_tbl_in     OKS_CVT_PVT.oks_coverage_times_v_tbl_type;
 l_cov_time_tbl_out    OKS_CVT_PVT.oks_coverage_times_v_tbl_type;
 --  END

-- Reaction Time --
  l_act_type_tbl_in         OKS_ACT_PVT.OksActionTimeTypesVTblType;
  l_act_type_tbl_out        OKS_ACT_PVT.OksActionTimeTypesVTblType;

  l_act_time_tbl_in         OKS_ACM_PVT.OKS_ACTION_TIMES_V_TBL_TYPE;
  l_act_time_tbl_out        OKS_ACM_PVT.OKS_ACTION_TIMES_V_TBL_TYPE;

-- End Reaction Time  --

-- Preffered Resource  --
   l_cplv_tbl_in             okc_contract_party_pub.cplv_tbl_type;
  l_cplv_tbl_out            okc_contract_party_pub.cplv_tbl_type;
  --
   l_ctcv_tbl_in             okc_contract_party_pub.ctcv_tbl_type;
  l_ctcv_tbl_out            okc_contract_party_pub.ctcv_tbl_type;
 -- end Resource --

 -- Bill Rate  --
 l_bill_rate_tbl_in        OKS_BRS_PVT.OKSBILLRATESCHEDULESVTBLTYPE;
 l_bill_rate_tbl_out       OKS_BRS_PVT.OKSBILLRATESCHEDULESVTBLTYPE;

 -- End Bill Rate --

 -- Preventive Maintainance --
 -- OKs_Pm_stream_levels
 l_pmlv_tbl_in   	    OKS_PML_PVT.PMLV_TBL_TYPE;
  l_pmlv_tbl_out   	    OKS_PML_PVT.PMLV_TBL_TYPE;
  -- Oks_pm_stream_levels
  -- OKs_Pm_schedules
 l_pms_tbl_in  oks_pms_pvt.oks_pm_schedules_v_tbl_type;
 l_pms_tbl_out oks_pms_pvt.oks_pm_schedules_v_tbl_type;
  -- Oks_Pm_schedules
  -- OKS_PM_ACTIVITIES --
  l_pmav_tbl_in		    OKS_PMA_PVT.pmav_tbl_type;
  l_pmav_tbl_out	    OKS_PMA_PVT.pmav_tbl_type;
  -- OKS_PM_ACTIVITIES --
 -- End Preventive Maintainance --

Cursor Cur_react_time (p_id NUMBER) IS
Select id,dnz_chr_id from OKC_K_LINES_B
Where cle_id = p_id
And Lse_id  in (4,17);

Cursor cur_act_times (p_id NUMBER) IS
Select id,dnz_chr_id,object_version_number from OKS_ACTION_TIMES
where  COV_ACTION_TYPE_ID = p_id;



cursor cur_act_time_type (p_id NUMBER) IS
Select id,dnz_chr_id,object_version_number  from OKS_ACTION_TIME_TYPES
where cle_id = p_id
AND ACTION_TYPE_CODE IN ('RCN', 'RSN');


Cursor cur_oks_id (p_id NUMBER) IS
Select id,dnz_chr_id,cle_id,sfwt_flag,object_version_number from OKS_K_LINES_V
where cle_id = p_id;



-- Time Zone  --
  CURSOR 	csr_TZ_id(l_cle_id NUMBER) IS
          	SELECT id,dnz_chr_id,object_version_number from OKS_COVERAGE_TIMEZONES
          	WHERE  cle_id = l_cle_id;
  CURSOR 	csr_Times_id(l_cle_id NUMBER) IS
          	SELECT id,dnz_chr_id,object_version_number from OKS_COVERAGE_TIMES
          	WHERE  cov_tze_line_id = l_cle_id;

-- End Time Zone --

-- Business Process --

      CURSOR 	csr_BP_id(l_cle_id NUMBER) IS
          	SELECT id,dnz_chr_id from okc_k_lines_b
          	WHERE  cle_id = l_cle_id
		AND LSE_ID IN (3,16);

-- End Business Process--


Cursor cur_party (P_id NUMBER) IS
Select id,dnz_chr_id,chr_id,cpl_id,primary_yn,small_business_flag,women_owned_flag,cle_id,
JTOT_OBJECT1_CODE,object1_id1,rle_code from OKC_K_PARTY_ROLES_V
Where cle_id = p_id
And   dnz_chr_id = p_dnz_chr_id;


Cursor cur_contact (P_id NUMBER) IS
Select id,dnz_chr_id,cro_code,cpl_id,primary_yn,resource_class from OKC_CONTACTS
Where cpl_id = p_id;

-- Billing Type  --
Cursor cur_bill_type (p_id NUMBER) IS
Select id,dnz_chr_id from OKC_K_LINES_B
where cle_id=p_id
and lse_id in ( 5,59,23);

Cursor cur_item (p_id NUMBER) IS
Select id,dnz_chr_id,jtot_object1_code,object1_id1,cle_id,chr_id,cle_id_for,exception_yn,
PRICED_ITEM_YN,uom_code from OKC_K_ITEMS
where cle_id = p_id;


-- End Billing Type --

-- Bill Rate  --
Cursor cur_bill_sch (p_id NUMBER) IS
Select id,dnz_chr_id,object_version_number from OKS_BILLRATE_SCHEDULES
Where CLE_ID =p_id;

Cursor cur_bill_rate (p_id NUMBER) IS
Select id,dnz_chr_id from OKC_K_LINES_B
where cle_id=p_id
and lse_id in (6,60,24);
-- End Bill Rate --
-- Coverage_id --
Cursor Cur_Coverage (p_id NUMBER) IS
Select dnz_chr_id from OKC_K_LINES_B
where id =p_id ;
-- End Coverage id --


--  Variable Used --
l_coverage_id     NUMBER;
l_dnz_chr_id     NUMBER:= -1;
l_oks_line_id     NUMBER;
l_cle_id          NUMBER;
l_api_version		CONSTANT	NUMBER	:= 1.0;
l_init_msg_list	        CONSTANT	VARCHAR2(1) := OKC_API.G_TRUE;
l_return_status		    	        VARCHAR2(1) := 'S';
l_msg_count  				Number;
l_msg_data   				Varchar2(240);
l_validate_yn                           VARCHAR2(1) := 'N';
cnt                           NUMBER;
cnt1                          NUMBER;



-- End --
-- Preventive Maintainance --
Cursor cur_pm_act (p_id NUMBER) IS
Select id,dnz_chr_id ,object_version_number
from OKS_PM_ACTIVITIES
Where cle_id=p_id;

cursor cur_pm_sch (p_id NUMBER) IS
Select id , dnz_chr_id,OBJECT_VERSION_NUMBER
from  OKS_PM_SCHEDULES
Where cle_id=p_id;

Cursor cur_pm_stream (p_id NUMBER) IS
Select id,dnz_chr_id ,OBJECT_VERSION_NUMBER
from OKS_PM_STREAM_LEVELS
Where cle_id=p_id;
-- Preventive Maintanance --


Begin



-- Check the Status of Warranty_YN Check Box
-- If checked then set dnz_chr_id = -2
-- else set dnz_chr_id = -1

l_coverage_id  :=p_coverage_id;
l_dnz_chr_id := p_dnz_chr_id;
cnt :=0;
cnt1 :=0;
 Open Cur_Coverage(p_coverage_id);
 fetch Cur_Coverage into l_dnz_chr_id ;
 close Cur_Coverage;

IF l_dnz_chr_id <> p_dnz_chr_id then
 -- Coverage --
  l_clev_tbl_in(1).id                := l_coverage_id;
  l_clev_tbl_in(1).dnz_chr_id 		 := p_dnz_chr_id;

  okc_contract_pub.update_contract_line (
   	  p_api_version						    => l_api_version,
  	  p_init_msg_list					    => l_init_msg_list,
      x_return_status					    => l_return_status,
      x_msg_count							=> l_msg_count,
      x_msg_data							=> l_msg_data,
      p_restricted_update                   => 'F',
      p_clev_tbl							=> l_clev_tbl_in,
      x_clev_tbl							=> l_clev_tbl_out
      );

 End if ;

 For rec_line in  cur_oks_id (l_coverage_id) LOOP
  IF rec_line.dnz_chr_id <> p_dnz_chr_id then

    l_klnv_tbl_in(cnt).id                    :=  rec_line.id;
    l_klnv_tbl_in(cnt).dnz_chr_id            :=  p_dnz_chr_id;
    l_klnv_tbl_in(cnt).cle_id                :=  rec_line.cle_id;
    l_klnv_tbl_in(cnt).sfwt_flag            :=  rec_line.sfwt_flag;
    l_klnv_tbl_in(cnt).object_version_number :=  rec_line.object_version_number;


    cnt :=cnt+1;
    End if;
 End LOOP;
  if cnt>0 then

       OKS_CONTRACT_LINE_PUB.UPDATE_LINE(
                                   p_api_version     => l_api_version,
                                   p_init_msg_list   => l_init_msg_list,
                                   x_return_status   => l_return_status,
                                   x_msg_count       => l_msg_count,
                                   x_msg_data        => l_msg_data,
                                   p_klnv_tbl        => l_klnv_tbl_in,
                                   x_klnv_tbl        => l_klnv_tbl_out,
                                   p_validate_yn     => l_validate_yn);
   End if;
-- coverage End --

 cnt :=0;

 -- Preventive Maintainance  --
 For rec_pma in  cur_pm_act (l_coverage_id) LOOP
   IF rec_pma.dnz_chr_id <> p_dnz_chr_id then
     l_pmav_tbl_in(cnt).id         := rec_pma.id;
     l_pmav_tbl_in(cnt).dnz_chr_id := p_dnz_chr_id;
     l_pmav_tbl_in(cnt).object_version_number := rec_pma.object_version_number;
     cnt :=cnt+1;
   End if;
 End LOOP;
 If cnt>0 Then
 -- OKS_PM_ACTIVITIES
   oks_pma_pvt.update_row (
  p_api_version     => l_api_version,
             p_init_msg_list   => l_init_msg_list,
             x_return_status   => l_return_status,
          x_msg_count				=> l_msg_count,
          x_msg_data				=> l_msg_data,
          p_pmav_tbl				=> l_pmav_tbl_in,
    	  x_pmav_tbl				=> l_pmav_tbl_out);
 End if;

 cnt:=0;
 For rec_sch in  cur_pm_sch (l_coverage_id) LOOP
   IF rec_sch.dnz_chr_id <> p_dnz_chr_id then
      l_pms_tbl_in(cnt).id         := rec_sch.id;
      l_pms_tbl_in(cnt).dnz_chr_id := p_dnz_chr_id;
      l_pms_tbl_in(cnt).OBJECT_VERSION_NUMBER   :=rec_sch.OBJECT_VERSION_NUMBER;
      cnt :=cnt+1;
   End if;
 End LOOP;
 If cnt>0 Then
    -- OKS_PM_SCHEDULES --
    OKS_PMS_PVT.update_row(
 p_api_version     => l_api_version,
 p_init_msg_list   => l_init_msg_list,
 x_return_status   => l_return_status,
    x_msg_count		=> l_msg_count ,
    x_msg_data		=> l_msg_data  ,
    p_oks_pm_schedules_v_tbl => l_pms_tbl_in,
    x_oks_pm_schedules_v_tbl =>l_pms_tbl_out);
 End IF;

 cnt :=0;
 For rec_stream in  cur_pm_stream (l_coverage_id) LOOP
  IF rec_stream.dnz_chr_id <> p_dnz_chr_id then
      l_pmlv_tbl_in(cnt).id :=rec_stream.id;
      l_pmlv_tbl_in(cnt).dnz_chr_id :=p_dnz_chr_id;
      l_pmlv_tbl_in(cnt).OBJECT_VERSION_NUMBER :=rec_stream.OBJECT_VERSION_NUMBER;
      cnt :=cnt+1;
   End if;
 End LOOP;
 If cnt>0 Then
      -- OKS_PM_STRAM_LEVELS
     oks_pml_pvt.update_row (
   	  p_api_version     => l_api_version,
      p_init_msg_list   => l_init_msg_list,
      x_return_status   => l_return_status,
          x_msg_count				=> l_msg_count,
          x_msg_data				=> l_msg_data,
          p_pmlv_tbl				=> l_pmlv_tbl_in,
    	  x_pmlv_tbl				=> l_pmlv_tbl_out
    );
 End if;


 -- End Preventive Maintainance --




cnt:=0;
-- Business Process  --
--oksaucvt_tool_box.init_contract_line (l_clev_tbl_in);
FOR rec_bp in csr_bp_id(l_coverage_id) LOOP

 IF rec_bp.dnz_chr_id <> p_dnz_chr_id then

	l_clev_tbl_in(cnt).id	                 := rec_bp.id;
	l_clev_tbl_in(cnt).dnz_chr_id            :=p_dnz_chr_id;
	cnt :=cnt+1;
 End If;
-- Contract Item

   --oksaucvt_tool_box.init_contract_item (l_cimv_tbl_in);

FOR rec_item in cur_item(rec_bp.id) LOOP
 IF rec_item.dnz_chr_id <>p_dnz_chr_id Then
   l_cimv_tbl_in(cnt1).id	    	       := rec_item.id;
   l_cimv_tbl_in(cnt1).cle_id		       := rec_item.cle_id;
   l_cimv_tbl_in(cnt1).dnz_chr_id         := p_dnz_chr_id;
   l_cimv_tbl_in(cnt1).jtot_object1_code  := rec_item.jtot_object1_code;
   l_cimv_tbl_in(cnt1).cle_id_for         := rec_item.cle_id_for;
    l_cimv_tbl_in(cnt1).PRICED_ITEM_YN  := rec_item.PRICED_ITEM_YN;
   l_cimv_tbl_in(cnt1).chr_id         := rec_item.chr_id;
   l_cimv_tbl_in(cnt1).exception_yn  := rec_item.exception_yn;
   l_cimv_tbl_in(cnt1).object1_id1  := rec_item.object1_id1;

   cnt1 :=cnt1+1;
  End if;
End LOOP;
If cnt1>0 then
   okc_contract_item_pub.update_contract_item (
   	 p_api_version     => l_api_version,
     p_init_msg_list   => l_init_msg_list,
     x_return_status   => l_return_status,
     x_msg_count	   => l_msg_count,
     x_msg_data		   => l_msg_data,
     p_cimv_tbl		   => l_cimv_tbl_in,
     x_cimv_tbl	       => l_cimv_tbl_out );
 End if;
-- End Contract Item
-- OKS_K_LINES_B
cnt1 :=0;
  For rec_line in  cur_oks_id (rec_bp.id) LOOP

     If rec_line.dnz_chr_id <>p_dnz_chr_id then
	  l_klnv_tbl_in(cnt1).id                    :=  rec_line.id;
    l_klnv_tbl_in(cnt1).dnz_chr_id            :=  p_dnz_chr_id;
    l_klnv_tbl_in(cnt1).cle_id                :=  rec_line.cle_id;
    l_klnv_tbl_in(cnt1).sfwt_flag            :=  rec_line.sfwt_flag;
    l_klnv_tbl_in(cnt1).object_version_number :=  rec_line.object_version_number;
	   cnt1 :=cnt1+1;
    End if;

  End LOOP;
If cnt1>0 Then
 OKS_CONTRACT_LINE_PUB.UPDATE_LINE(
                  p_api_version     => l_api_version,
                  p_init_msg_list   => l_init_msg_list,
                  x_return_status   => l_return_status,
                  x_msg_count       => l_msg_count,
                  x_msg_data        => l_msg_data,
                  p_klnv_tbl        => l_klnv_tbl_in,
                  x_klnv_tbl        => l_klnv_tbl_out,
                  p_validate_yn     => l_validate_yn);
End if ;
  -- End OKS_K_LINES_B --
 cnt1 :=0;

End Loop; -- end Loop BP

If  cnt>0 Then
      okc_contract_pub.update_contract_line (
   	  p_api_version						    => l_api_version,
  	  p_init_msg_list					    => l_init_msg_list,
      x_return_status					    => l_return_status,
      x_msg_count							=> l_msg_count,
      x_msg_data							=> l_msg_data,
      p_restricted_update                   => 'F',
      p_clev_tbl							=> l_clev_tbl_in,
      x_clev_tbl							=> l_clev_tbl_out);
End if;

-- End Business process--
cnt :=0;


-- Reaction Time  --
FOR rec_bp in csr_bp_id(l_coverage_id ) LOOP
      FOR rec_react IN cur_react_time (rec_bp.id) LOOP

 If rec_react.dnz_chr_id<>p_dnz_chr_id then
   	 l_clev_tbl_in(cnt).dnz_chr_id	 := p_dnz_chr_id;
	 l_clev_tbl_in(cnt).id			 := rec_react.id;
    cnt :=cnt+1;
  End If;
   -- Fetch OKS_K_LINES id
  cnt1 :=0;
  For rec_line in  cur_oks_id (rec_react.id) LOOP

  IF rec_line.dnz_chr_id<>p_dnz_chr_id then
      l_klnv_tbl_in(cnt1).id                    :=  rec_line.id;
    l_klnv_tbl_in(cnt1).dnz_chr_id            :=  p_dnz_chr_id;
    l_klnv_tbl_in(cnt1).cle_id                :=  rec_line.cle_id;
    l_klnv_tbl_in(cnt1).sfwt_flag            :=  rec_line.sfwt_flag;
    l_klnv_tbl_in(cnt1).object_version_number :=  rec_line.object_version_number;
     cnt1 :=cnt1+1;
   End if ;
  End Loop;
 If cnt1>0 then
       OKS_CONTRACT_LINE_PUB.UPDATE_LINE(
                   	  p_api_version						    => l_api_version,
  	  p_init_msg_list					    => l_init_msg_list,
      x_return_status					    => l_return_status,
      x_msg_count							=> l_msg_count,
      x_msg_data							=> l_msg_data,
                    p_klnv_tbl        => l_klnv_tbl_in,
                    x_klnv_tbl        => l_klnv_tbl_out,
                    p_validate_yn     => l_validate_yn);
 End if;
  -- update the oks_action_types line
cnt1 :=0;
for rec_type in cur_act_time_type ( rec_react.id) LOOP

  if rec_type.dnz_chr_id<>p_dnz_chr_id THEN
    l_act_type_tbl_in(cnt1).dnz_chr_id        := p_dnz_chr_id;
    l_act_type_tbl_in(cnt1).id                := rec_type.id;
    l_act_type_tbl_in(cnt1).object_version_number := rec_type.object_version_number;
    cnt1 := cnt1+1;

   End if;
 End LOOP;
 If cnt1>0  Then
 OKS_ACT_PVT.Update_ROW(
      p_api_version						    => l_api_version,
  	  p_init_msg_list					    => l_init_msg_list,
      x_return_status					    => l_return_status,
      x_msg_count							=> l_msg_count,
      x_msg_data							=> l_msg_data,
                        p_oks_action_time_types_v_tbl => l_act_type_tbl_in,
                        x_oks_action_time_types_v_tbl => l_act_type_tbl_out);
  End if;

     cnt1 :=0;
   -- End Update oks_action_types line
    -- Update the oks_action_times_line
 for rec_type in cur_act_time_type ( rec_react.id) LOOP
  for rec_time in cur_act_times (rec_type.id) LOOP

   If rec_time.dnz_chr_id <>p_dnz_chr_id then

	  l_act_time_tbl_in(cnt1).dnz_chr_id             :=p_dnz_chr_id;
	  l_act_time_tbl_in(cnt1).id                     :=rec_time.id;
     l_act_time_tbl_in(cnt1).object_version_number   :=rec_time.object_version_number;
      cnt1 :=cnt1+1;

    End if;
   End LOOP;
  End LOOP;
  If cnt1>0 Then
     OKS_ACM_PVT.UPDATE_ROW(  	  p_api_version						    => l_api_version,
  	  p_init_msg_list					    => l_init_msg_list,
      x_return_status					    => l_return_status,
      x_msg_count							=> l_msg_count,
      x_msg_data							=> l_msg_data,
                         p_oks_action_times_v_tbl => l_act_time_tbl_in,
                         x_oks_action_times_v_tbl => l_act_time_tbl_out);
  End if;
    -- End oks_action_times_line
cnt1:=0;
      END LOOP;	-- Reaction Time
 End LOOP; -- BP
 if cnt>0 Then
   okc_contract_pub.update_contract_line (
   	  p_api_version						    => l_api_version,
  	  p_init_msg_list					    => l_init_msg_list,
      x_return_status					    => l_return_status,
      x_msg_count							=> l_msg_count,
      x_msg_data							=> l_msg_data,
      p_restricted_update                   => 'F',
      p_clev_tbl							=> l_clev_tbl_in,
      x_clev_tbl							=> l_clev_tbl_out );
  End if;
-- End Reaction Time --

cnt :=0;

-- Resource --
 FOR rec_bp in csr_bp_id(p_coverage_id) LOOP
   For rec_part in Cur_party (rec_bp.id) LOOP
   IF rec_part.dnz_chr_id <>p_dnz_chr_id Then
       l_cplv_tbl_in(cnt).dnz_chr_id                := p_dnz_chr_id;
       l_cplv_tbl_in(cnt).id                        :=  rec_part.id;
       l_cplv_tbl_in(cnt).chr_id                    :=  rec_part.chr_id;
       l_cplv_tbl_in(cnt).cle_id                        :=  rec_part.cle_id;
       l_cplv_tbl_in(cnt).cpl_id                        :=  rec_part.cpl_id;
       l_cplv_tbl_in(cnt).small_business_flag           :=  rec_part.small_business_flag;
       l_cplv_tbl_in(cnt).women_owned_flag                        :=  rec_part.women_owned_flag;
       l_cplv_tbl_in(cnt).primary_yn                        :=  rec_part.primary_yn;
         l_cplv_tbl_in(cnt).JTOT_OBJECT1_CODE           :=  rec_part.JTOT_OBJECT1_CODE;
       l_cplv_tbl_in(cnt).object1_id1                        :=  rec_part.object1_id1;
       l_cplv_tbl_in(cnt).rle_code                        :=  rec_part.rle_code;

       cnt :=cnt+1;
   End if;
  -- OKC_CONTACTS --
  cnt1 :=0;
   For rec_con in cur_contact (rec_part.id) LOOP
     If rec_con.dnz_chr_id <>p_dnz_chr_id then
    	l_ctcv_tbl_in(cnt1).id           := rec_con.id;
    	l_ctcv_tbl_in(cnt1).dnz_chr_id   := p_dnz_chr_id;
     l_ctcv_tbl_in(cnt1).cro_code           := rec_con.cro_code;
     l_ctcv_tbl_in(cnt1).cpl_id           := rec_con.cpl_id;
     l_ctcv_tbl_in(cnt1).primary_yn           := rec_con.primary_yn;
     l_ctcv_tbl_in(cnt1).resource_class           := rec_con.resource_class;
        cnt1 :=cnt1+1;
      End if;
   End LOOP;
 If cnt1>0 Then
    okc_contract_party_pub.update_contact (
   	  p_api_version						    => l_api_version,
  	  p_init_msg_list					    => l_init_msg_list,
      x_return_status					    => l_return_status,
      x_msg_count							=> l_msg_count,
      x_msg_data							=> l_msg_data,
      p_ctcv_tbl							=> l_ctcv_tbl_in,
    	x_ctcv_tbl							=> l_ctcv_tbl_out );
 End if;
 -- OKC_CONTACTS --
   End LOOP; -- End Party Roles
 End LOOP; -- End Bp
 If cnt>0 then
 okc_contract_party_pub.update_k_party_role (
  p_api_version						    => l_api_version,
  	  p_init_msg_list					    => l_init_msg_list,
      x_return_status					    => l_return_status,
      x_msg_count					=> l_msg_count,
      x_msg_data					=> l_msg_data,
      p_cplv_tbl					=> l_cplv_tbl_in,
      x_cplv_tbl					=> l_cplv_tbl_out );
 End if;

-- End Prefered Resource --
cnt :=0;

-- Billing Type --
FOR rec_bp in csr_bp_id(l_coverage_id ) LOOP
	For rec_bill in cur_bill_type( rec_bp.id) LOOP
 -- Contract Line for Billing Type
 If rec_bill.dnz_chr_id<>p_dnz_chr_id then
   l_clev_tbl_in(cnt).dnz_chr_id			 := p_dnz_chr_id;
   l_clev_tbl_in(cnt).id			         := rec_bill.id;
   cnt := cnt +1;
 End if;
 cnt1 :=0;

  For rec_item in cur_item (rec_bill.id) LOOP
	  -- Contract Item
	IF rec_item.dnz_chr_id<>p_dnz_chr_id then
  l_cimv_tbl_in(cnt1).id	    	       := rec_item.id;
   l_cimv_tbl_in(cnt1).cle_id		       := rec_item.cle_id;
   l_cimv_tbl_in(cnt1).dnz_chr_id         := p_dnz_chr_id;
   l_cimv_tbl_in(cnt1).jtot_object1_code  := rec_item.jtot_object1_code;
   l_cimv_tbl_in(cnt1).cle_id_for         := rec_item.cle_id_for;
    l_cimv_tbl_in(cnt1).PRICED_ITEM_YN  := rec_item.PRICED_ITEM_YN;
   l_cimv_tbl_in(cnt1).chr_id         := rec_item.chr_id;
   l_cimv_tbl_in(cnt1).exception_yn  := rec_item.exception_yn;
   l_cimv_tbl_in(cnt1).object1_id1  := rec_item.object1_id1;
    cnt1 :=cnt1+1;
    End If;
  End LOOP;
If cnt1>0 Then
   okc_contract_item_pub.update_contract_item (
   	 p_api_version     => l_api_version,
     p_init_msg_list   => l_init_msg_list,
     x_return_status   => l_return_status,
     x_msg_count	   => l_msg_count,
     x_msg_data		   => l_msg_data,
     p_cimv_tbl		   => l_cimv_tbl_in,
     x_cimv_tbl	       => l_cimv_tbl_out );
     -- End OKC_K_ITEMS
End if;
     cnt1:=0;
 For rec_oks_line in cur_oks_id (rec_bill.id) LOOP

   if rec_oks_line.dnz_chr_id<>p_dnz_chr_id then
     l_klnv_tbl_in(cnt1).id                    :=  rec_oks_line.id;
    l_klnv_tbl_in(cnt1).dnz_chr_id            :=  p_dnz_chr_id;
    l_klnv_tbl_in(cnt1).cle_id                :=  rec_oks_line.cle_id;
    l_klnv_tbl_in(cnt1).sfwt_flag            :=  rec_oks_line.sfwt_flag;
    l_klnv_tbl_in(cnt1).object_version_number :=  rec_oks_line.object_version_number;
     cnt1:=cnt1+1;
   End if;
 End LOOP;
If cnt1>0 Then
       OKS_CONTRACT_LINE_PUB.UPDATE_LINE(
              p_api_version     => l_api_version,
     p_init_msg_list   => l_init_msg_list,
     x_return_status   => l_return_status,
     x_msg_count	   => l_msg_count,
     x_msg_data		   => l_msg_data,
              p_klnv_tbl        => l_klnv_tbl_in,
              x_klnv_tbl        => l_klnv_tbl_out,
              p_validate_yn     => l_validate_yn);
 end if;
        End LOOP;
End LOOP; -- BP --
If cnt>0 then
   okc_contract_pub.update_contract_line (
   	  p_api_version						    => l_api_version,
  	  p_init_msg_list					    => l_init_msg_list,
      x_return_status					    => l_return_status,
      x_msg_count							=> l_msg_count,
      x_msg_data							=> l_msg_data,
      p_restricted_update                   => 'F',
      p_clev_tbl							=> l_clev_tbl_in,
      x_clev_tbl							=> l_clev_tbl_out  );
 End if;
-- BILLING Tpye ---

cnt :=0;

-- Billing Rate --
FOR rec_bp in csr_bp_id(l_coverage_id) LOOP
	For rec_bill in cur_bill_type( rec_bp.id) LOOP
	   For rec_billrate in cur_bill_rate ( rec_bill.id) LOOP

   If rec_billrate.dnz_chr_id <> p_dnz_chr_id Then
	    l_clev_tbl_in(cnt).id			 := rec_billrate.id;
	    l_clev_tbl_in(cnt).dnz_chr_id		 := p_dnz_chr_id;
        cnt:=cnt +1;
   End if;
	  cnt1 :=0;
	  For rec_oks_line in cur_oks_id (rec_bill.id) LOOP
	     If rec_oks_line.dnz_chr_id<>p_dnz_chr_id then
          l_klnv_tbl_in(cnt1).id                    :=  rec_oks_line.id;
    l_klnv_tbl_in(cnt1).dnz_chr_id            :=  p_dnz_chr_id;
    l_klnv_tbl_in(cnt1).cle_id                :=  rec_oks_line.cle_id;
    l_klnv_tbl_in(cnt1).sfwt_flag            :=  rec_oks_line.sfwt_flag;
    l_klnv_tbl_in(cnt1).object_version_number :=  rec_oks_line.object_version_number;
           cnt1 := cnt1+1;
         End if;
      End LOOP; -- End OKS_LINES
   If cnt1>0 Then
           OKS_CONTRACT_LINE_PUB.UPDATE_LINE(
                                p_api_version     => l_api_version,
                   p_init_msg_list   => l_init_msg_list,
                   x_return_status   => l_return_status,
                   x_msg_count       => l_msg_count,
                   x_msg_data        => l_msg_data,
                                   p_klnv_tbl        => l_klnv_tbl_in,
                                   x_klnv_tbl        => l_klnv_tbl_out,
                                   p_validate_yn     => l_validate_yn);
   End if;
        cnt1:=0;


	  For rec_billsch in cur_bill_sch (rec_billrate.id) LOOP

       If rec_billsch.dnz_chr_id <>p_dnz_chr_id then
	    l_bill_rate_tbl_in(cnt1).id                :=   rec_billsch.id ;
	    l_bill_rate_tbl_in(cnt1).dnz_chr_id        :=   p_dnz_chr_id;
        l_bill_rate_tbl_in(cnt1).object_version_number                :=   rec_billsch.object_version_number ;

        cnt1 :=cnt1+1;
	   End if;
     End LOOP; -- Billsch

  If cnt1>0 Then

     OKS_BRS_PVT.UPDATE_ROW(p_api_version     => l_api_version,
                   p_init_msg_list   => l_init_msg_list,
                   x_return_status   => l_return_status,
                   x_msg_count       => l_msg_count,
                   x_msg_data        => l_msg_data,
                   p_oks_billrate_schedules_v_tbl => l_bill_rate_tbl_in ,
                   x_oks_billrate_schedules_v_tbl => l_bill_rate_tbl_out);
    End If;
   cnt1 :=0;

      End LOOP; -- billrate
    End LOOP;
End LOOP; -- BP
If cnt>0 Then
  okc_contract_pub.update_contract_line (
   	  p_api_version						    => l_api_version,
  	  p_init_msg_list					    => l_init_msg_list,
      x_return_status					    => l_return_status,
      x_msg_count							=> l_msg_count,
      x_msg_data							=> l_msg_data,
      p_restricted_update                   => 'F',
      p_clev_tbl							=> l_clev_tbl_in,
      x_clev_tbl							=> l_clev_tbl_out);
 End if ;
 cnt :=0;
      -- End Billing Rate --


 -- TimeZone--
 FOR rec_bp in csr_bp_id(l_coverage_id) LOOP
     For rec_covtz in csr_TZ_id( rec_bp.id) LOOP

If rec_covtz.dnz_chr_id<>p_dnz_chr_id Then
  l_timezone_tbl_in(cnt).id             := rec_covtz.id;
  l_timezone_tbl_in(cnt).dnz_chr_id     := p_dnz_chr_id;
  l_timezone_tbl_in(cnt).object_version_number :=rec_covtz.object_version_number;

  cnt:=cnt+1;
End if;
         End LOOP;
 End LOOP;
 if cnt>0 then

 OKS_CTZ_PVT.UPDATE_ROW(
      p_api_version						    => l_api_version,
  	  p_init_msg_list					    => l_init_msg_list,
      x_return_status					    => l_return_status,
      x_msg_count							=> l_msg_count,
      x_msg_data							=> l_msg_data,
      p_oks_coverage_timezones_v_tbl  => l_timezone_tbl_in,
      x_oks_coverage_timezones_v_tbl  => l_timezone_tbl_out);
 End if ;
 cnt:=0;

 -- End Time Zone--
 -- Times --
 FOR rec_bp in csr_bp_id(l_coverage_id) LOOP
     For rec_covtz in csr_TZ_id( rec_bp.id) LOOP
       For rec_times in csr_Times_id (rec_covtz.id) LOOP
 -- If rec_times.dnz_chr_id<>p_dnz_chr_id Then
     l_cov_time_tbl_in(cnt).id              := rec_times.id;
     l_cov_time_tbl_in(cnt).dnz_chr_id      := p_dnz_chr_id;
     l_cov_time_tbl_in(cnt).object_version_number :=rec_times.object_version_number;

     cnt :=cnt+1;
 -- End if;
       End LOOP;
     End LOOP;
 End LOOP;
  --If cnt>0 Then
    OKS_CVT_PVT.update_row(
                           p_api_version					    => l_api_version,
                           p_init_msg_list					    => l_init_msg_list,
                           x_return_status					    => l_return_status,
                           x_msg_count							=> l_msg_count,
                           x_msg_data							=> l_msg_data,
                           p_oks_coverage_times_v_tbl      => l_cov_time_tbl_in,
                           x_oks_coverage_times_v_tbl      =>l_cov_time_tbl_out);
 -- End if;
   -- End Times --




 End Update_dnz_chr_id;

/* This procedure is used for creation of  PM and notes.
   Parameters :         p_standard_cov_id : Id of the source coverage or source contract line
                        p_contract_line_id : Id of the target contract line
   Create_K_coverage_ext can be called during the creation of service line from authoring or from renewal
   consolidation flow.
 */
PROCEDURE Create_K_coverage_ext(p_api_version          IN   NUMBER,
                                p_init_msg_list        IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                p_src_line_id          IN   NUMBER,
                                p_tgt_line_id          IN   NUMBER,
                                x_return_status        OUT  NOCOPY   VARCHAR2,
                                x_msg_count            OUT  NOCOPY   NUMBER,
                                x_msg_data             OUT  NOCOPY   VARCHAR2) IS

--Cursor definition
/*  Modified by Jvorugan .Added p_source_object_code as input parameter.
    This  differentiates whether notes is associated with a standard coverage
    or a service line  */

  CURSOR CUR_GET_NOTES(p_source_object_id IN NUMBER,p_source_object_code IN VARCHAR2)
  IS
  SELECT jtf_note_id,
         parent_note_id,
         source_object_code,
         source_number,
         notes,  --
         notes_detail,
         note_status,
         source_object_meaning,
         note_type,
         note_type_meaning,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         note_status_meaning,
         decoded_source_code,
         decoded_source_meaning,
         context
  FROM JTF_NOTES_VL
  WHERE source_object_id = p_source_object_id
  AND   source_object_code = p_source_object_code       --  'OKS_COVTMPL_NOTE'
  AND   note_status <> (case when p_source_object_code ='OKS_COVTMPL_NOTE' THEN 'P' ELSE '!' END);
       -- Commented by Jvorugan. note_status <> 'P';

CURSOR CUR_GET_LINE_DATES IS
SELECT  start_date,
        end_date
FROM    OKC_K_LINES_B
WHERE   ID = p_tgt_line_id; --p_contract_line_id;

-- Modified by Jvorugan for Bug:4610475. Added pm_sch_exists_yn,pm_conf_req_yn
CURSOR CUR_CHECK_PM_PROG IS
SELECT  pm_program_id,pm_sch_exists_yn,pm_conf_req_yn
FROM    OKS_K_LINES_B
WHERE   CLE_ID = p_src_line_id; --p_standard_cov_id;  -- modified by Jvorugan Bug:4535339  ID = p_standard_cov_id;

-- Added by Jvorugan
CURSOR CUR_GET_LSE_ID IS
SELECT  lse_id
FROM    OKC_K_LINES_B
WHERE   ID = p_src_line_id; --p_standard_cov_id;

GET_LSE_ID_REC  CUR_GET_LSE_ID%ROWTYPE;

  l_start_date              DATE;
  l_end_date                DATE;
  l_pm_prog_id              NUMBER;
  l_jtf_note_id             NUMBER;
  l_Notes_detail            VARCHAR2(32767);

  l_api_version		    CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	    CONSTANT	VARCHAR2(1):= 'F';
  l_return_status	    VARCHAR2(1);
  l_msg_count		    NUMBER;
  l_msg_data		    VARCHAR2(2000):=null;
  l_msg_index_out           NUMBER;
  l_api_name               CONSTANT VARCHAR2(30) := 'Create_K_coverage_ext';

-- Added by Jvorugan for Bug: 4610475.
  l_pm_sch_exists_yn        VARCHAR2(1);
  l_pm_conf_req_yn          VARCHAR2(1);
  l_source_object_code      JTF_NOTES_B.SOURCE_OBJECT_CODE%type;
  l_source_line_id          NUMBER;

BEGIN
  l_return_status := 'S';
  IF (G_DEBUG_ENABLED = 'Y') THEN
      okc_debug.Set_Indentation('Create_K_Coverage_Ext');
      okc_debug.log('BEGIN  CREATE_K_COVERAGE_EXT'||l_return_status, 2);
  END IF;

SAVEPOINT Create_K_coverage_ext_PVT;

-- Added by Jvorugan. Depending on  lse_id, l_source_object_code is populated.
  open  CUR_GET_LSE_ID;
  fetch CUR_GET_LSE_ID into GET_LSE_ID_REC;
  close CUR_GET_LSE_ID;

  l_source_line_id := p_src_line_id; --p_standard_cov_id;
  IF GET_LSE_ID_REC.lse_id in (1,14,19) THEN
  l_source_object_code := 'OKS_COV_NOTE';
  ELSE
  l_source_object_code := 'OKS_COVTMPL_NOTE';
  END IF;
-- End of changes by Jvorugan
FOR GET_LINE_DATES_REC in CUR_GET_LINE_DATES
LOOP
 l_start_date   := GET_LINE_DATES_REC.start_date;
 l_end_date     := GET_LINE_DATES_REC.end_date;
END LOOP;
FOR CHECK_PM_PROG_REC in CUR_CHECK_PM_PROG
LOOP
l_pm_prog_id      :=CHECK_PM_PROG_REC.pm_program_id;
l_pm_sch_exists_yn:=CHECK_PM_PROG_REC.pm_sch_exists_yn;   -- Added by Jvorugan for Bug:4610475
l_pm_conf_req_yn  :=CHECK_PM_PROG_REC.pm_conf_req_yn;

end LOOP;
  -- create notes for actual coverage from the template
-- pass coverage_template_id as (p_source_object_id IN parameter )in the cursor below
  IF (G_DEBUG_ENABLED = 'Y') THEN
      okc_debug.log('BEFORE CALLING JTF_NOTES_PUB.CREATE_NOTE'||l_return_status, 2);
  END IF;

-- Added l_source_object_code,l_source_line_id as input parameters for CUR_GET_NOTES
  FOR notes_rec IN CUR_GET_NOTES (l_source_line_id,l_source_object_code) LOOP
      JTF_NOTES_PUB.writeLobToData(notes_rec.JTF_NOTE_ID,L_Notes_detail);

      JTF_NOTES_PUB.CREATE_NOTE(p_parent_note_id        => notes_rec.parent_note_id ,
                                p_api_version           => l_api_version,
                                p_init_msg_list         =>  l_init_msg_list,
                                p_commit                => 'F',
                                p_validation_level      => 100,
                                x_return_status         => l_return_status ,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data ,
                                p_org_id                =>  NULL,
                                p_source_object_id      => p_tgt_line_id, -- p_contract_line_id,
                                p_source_object_code    => 'OKS_COV_NOTE',
                                p_notes                 =>notes_rec.notes,
                                p_notes_detail          => L_Notes_detail,
                                p_note_status           =>  notes_rec.note_status,
                                p_entered_by            =>  FND_GLOBAL.USER_ID,
                                p_entered_date          => SYSDATE ,
                                x_jtf_note_id           => l_jtf_note_id,
                                p_last_update_date      => sysdate,
                                p_last_updated_by       => FND_GLOBAL.USER_ID,
                                p_creation_date         => SYSDATE,
                                p_created_by            => FND_GLOBAL.USER_ID,
                                p_last_update_login     => FND_GLOBAL.LOGIN_ID,
                                p_attribute1            => notes_rec.ATTRIBUTE1,
                                p_attribute2            => notes_rec.ATTRIBUTE2,
                                p_attribute3            => notes_rec.ATTRIBUTE3,
                                p_attribute4            => notes_rec.ATTRIBUTE4,
                                p_attribute5            => notes_rec.ATTRIBUTE5,
                                p_attribute6            => notes_rec.ATTRIBUTE6,
                                p_attribute7            => notes_rec.ATTRIBUTE7,
                                p_attribute8            => notes_rec.ATTRIBUTE8,
                                p_attribute9            => notes_rec.ATTRIBUTE9,
                                p_attribute10           => notes_rec.ATTRIBUTE10,
                                p_attribute11           => notes_rec.ATTRIBUTE11,
                                p_attribute12           => notes_rec.ATTRIBUTE12,
                                p_attribute13           => notes_rec.ATTRIBUTE13,
                                p_attribute14           => notes_rec.ATTRIBUTE14,
                                p_attribute15           => notes_rec.ATTRIBUTE15,
                                p_context               => notes_rec.CONTEXT,
                                p_note_type             => notes_rec.NOTE_TYPE);

  IF (G_DEBUG_ENABLED = 'Y') THEN
      okc_debug.log('AFTER CALLING JTF_NOTES_PUB.CREATE_NOTE'||l_return_status, 2);
  END IF;


        IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
   END LOOP;
--errorout_ad('before'||l_return_status);

--IF l_klnv_tbl_in(1).pm_program_id IS NOT NULL then -- No need to call PM schedule instantiation if there is no program id.
--(Now I am going to add this validation (IF condition) into CREATE_PM_PROGRAM_SCHEDULE for simplicity)
IF l_pm_prog_id is not null then
-- Added by Jvorugan for Bug:4610475
-- From R12, PM will always be associated with service line instead of coverage.
-- Update oks_k_lines_b record of the service line  with the pm information.
update oks_k_lines_b set   pm_program_id   =l_pm_prog_id,
                           pm_sch_exists_yn=l_pm_sch_exists_yn,
                           pm_conf_req_yn  =l_pm_conf_req_yn
                     where cle_id          = p_tgt_line_id; --p_contract_line_id;


 OKS_PM_PROGRAMS_PVT.CREATE_PM_PROGRAM_SCHEDULE(
    p_api_version        => l_api_version,
    p_init_msg_list      => l_init_msg_list,
    x_return_status          => l_return_status,
    x_msg_count          => l_msg_count,
    x_msg_data               => l_msg_data,
    p_template_cle_id    => p_src_line_id, --p_standard_cov_id,
    p_cle_id             => p_tgt_line_id, --p_contract_line_id,
    p_cov_start_date     => l_start_date,
    p_cov_end_date       => l_end_date);
--errorout_ad('after'||l_return_status);

  IF (G_DEBUG_ENABLED = 'Y') THEN
      okc_debug.log('After OKS_PM_PROGRAMS_PVT. CREATE_PM_PROGRAM_SCHEDULE'||l_return_status, 2);
  END IF;


  IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
  END IF;
      x_return_status := l_return_status ;
EXCEPTION

        WHEN G_EXCEPTION_HALT_VALIDATION THEN
         IF (G_DEBUG_ENABLED = 'Y') THEN
                     okc_debug.log('Create_K_coverage_ext'||SQLERRM, 2);
                     okc_debug.Reset_Indentation;
         END IF;
      x_return_status := l_return_status ;
      x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Create_K_coverage_ext',
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
         IF (G_DEBUG_ENABLED = 'Y') THEN
                     okc_debug.log('Create_K_coverage_ext'||SQLERRM, 2);
                     okc_debug.Reset_Indentation;
         END IF;
      x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Create_K_coverage_ext',
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

         IF (G_DEBUG_ENABLED = 'Y') THEN
                     okc_debug.log('Create_K_coverage_ext'||SQLERRM, 2);
                     okc_debug.Reset_Indentation;
         END IF;
      x_msg_count :=l_msg_count;
      x_msg_data:=l_msg_data;
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Create_K_coverage_ext',
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN

         IF (G_DEBUG_ENABLED = 'Y') THEN
                     okc_debug.log('Create_K_coverage_ext'||SQLERRM, 2);
                     okc_debug.Reset_Indentation;
         END IF;
      OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1	        => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
       -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count :=l_msg_count;

END Create_K_coverage_ext;


/* This procedure is used for Copying the standard coverage template.
   Parameters:
              P_old_coverage_id    --  ID of the source coverage
              P_new_coverage_name  --  Name of the Target coverage
              x_new_coverage_id    -- New Id of the copied coverage    */
PROCEDURE  COPY_STANDARD_COVERAGE(
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    P_old_coverage_id               IN NUMBER,
    P_new_coverage_name             IN VARCHAR2,
    x_new_coverage_id               OUT NOCOPY NUMBER) IS

-----------------------------------------------
CURSOR CUR_GET_LINE_ID(p_cle_id NUMBER) is
 SELECT id from okc_k_lines_b
 where cle_id=p_cle_id;

-----------------------------------------------
 CURSOR Cur_childline(P_cle_Id IN NUMBER)
                     IS
  SELECT ID,lse_id
  FROM OKC_K_LINES_B
  WHERE  cle_Id=P_cle_Id;
-----------------------------------------------
CURSOR CUR_ItemDet(P_Id IN NUMBER) IS
  SELECT ID
  FROM OKC_K_ITEMS_V
  WHERE cle_Id=P_Id;
------------------------------------------------
 CURSOR Cur_childline1(P_cle_Id IN NUMBER) IS
  SELECT ID,lse_id
  FROM OKC_K_LINES_B
  WHERE  cle_Id=P_cle_Id ;
-------------------------------------------------
CURSOR Cur_PTRLDet(P_Cle_Id IN NUMBER,
                   P_role_Code IN varchar2) IS
  SELECT pr.ID
  FROM  OKC_K_Party_Roles_V pr,
            OKC_K_LINES_B lv
  WHERE pr.cle_ID=p_cle_Id
  AND   pr.Rle_Code=P_Role_Code
  AND   pr.cle_id = lv.id
  AND   pr.dnz_chr_id = lv.dnz_chr_id ;

  cr_ptrl_det   Cur_PTRLDet%rowtype;
 -------------------------------------------------
CURSOR Cur_contactDet(P_cpl_id IN NUMBER) IS
  SELECT ID
  FROM OKC_CONTACTS_V
  WHERE cpl_id=P_cpl_Id;
-------------------------------------------------
CURSOR Cur_childline_br(P_cle_Id IN NUMBER) IS
  SELECT ID
  FROM OKC_K_LINES_B
  WHERE  cle_Id=P_cle_Id;
-------------------------------------------------
l_old_coverage_id           OKC_K_LINES_B.ID%TYPE;
l_new_coverage_id           OKC_K_LINES_B.ID%TYPE;
l_old_bp_id                 OKC_K_LINES_B.ID%TYPE;
l_new_bp_id                 OKC_K_LINES_B.ID%TYPE;
l_old_bp_item_id            OKC_K_ITEMS.ID%TYPE;
l_new_bp_item_id            OKC_K_ITEMS.ID%TYPE;
l_old_rt_id                 OKC_K_LINES_B.ID%TYPE;
l_new_rt_id                 OKC_K_LINES_B.ID%TYPE;
l_new_rt_item_id            OKC_K_ITEMS.ID%TYPE;
l_old_rt_item_id            OKC_K_ITEMS.ID%TYPE;
l_old_party_id              OKC_K_PARTY_ROLES_B.ID%TYPE;
l_new_party_id              OKC_K_PARTY_ROLES_B.ID%TYPE;
l_old_contact_id            OKC_CONTACTS.ID%TYPE;
l_new_contact_id            OKC_CONTACTS.ID%TYPE;
l_old_bt_id                 OKC_K_LINES_B.ID%TYPE;
l_new_bt_id                 OKC_K_LINES_B.ID%TYPE;
l_old_br_id                 OKC_K_LINES_B.ID%TYPE;
l_new_br_id                 OKC_K_LINES_B.ID%TYPE;
l_cov_flag                  NUMBER;
l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

-- This function is called by copy_standard_coverage for insertion into okc_k_lines_b table
FUNCTION CREATE_OKC_LINE(p_new_line_id NUMBER,
                         p_old_line_id NUMBER,
                         p_flag        NUMBER,
                         p_cle_id      NUMBER DEFAULT NULL) return VARCHAR2 IS

x_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
l_start_date DATE;
l_coverage_name VARCHAR2(150);

BEGIN
 -- If flag is 1, then call is made for creating the top coverage line.
 -- so, we need to default sysdate as the start date
 IF p_flag =1
 THEN
    l_start_date := trunc(sysdate);
    l_coverage_name :=P_new_coverage_name;
 ELSE
    l_start_date :=NULL;
    l_coverage_name := NULL;
 END IF;

 INSERT INTO okc_k_lines_b
   (
     ID,
     LINE_NUMBER,
     CHR_ID,
     CLE_ID,
     CLE_ID_RENEWED,
     DNZ_CHR_ID,
     DISPLAY_SEQUENCE,
     STS_CODE,
     TRN_CODE,
     LSE_ID,
     EXCEPTION_YN,
     OBJECT_VERSION_NUMBER,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     HIDDEN_IND,
     PRICE_NEGOTIATED,
     PRICE_LEVEL_IND,
     PRICE_UNIT,
     PRICE_UNIT_PERCENT,
     INVOICE_LINE_LEVEL_IND,
     DPAS_RATING,
     TEMPLATE_USED,
     PRICE_TYPE,
     CURRENCY_CODE,
     LAST_UPDATE_LOGIN,
     DATE_TERMINATED,
     START_DATE,
     END_DATE,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8,
     ATTRIBUTE9,
     ATTRIBUTE10,
     ATTRIBUTE11,
     ATTRIBUTE12,
     ATTRIBUTE13,
     ATTRIBUTE14,
     ATTRIBUTE15,
     SECURITY_GROUP_ID,
     CLE_ID_RENEWED_TO,
     PRICE_NEGOTIATED_RENEWED,
     CURRENCY_CODE_RENEWED,
     UPG_ORIG_SYSTEM_REF,
     UPG_ORIG_SYSTEM_REF_ID,
     DATE_RENEWED,
     ORIG_SYSTEM_SOURCE_CODE,
     ORIG_SYSTEM_ID1,
     ORIG_SYSTEM_REFERENCE1,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     REQUEST_ID,
     PRICE_LIST_ID,
     PRICE_LIST_LINE_ID,
     LINE_LIST_PRICE,
     ITEM_TO_PRICE_YN,
     PRICING_DATE,
     PRICE_BASIS_YN,
     CONFIG_HEADER_ID,
     CONFIG_REVISION_NUMBER,
     CONFIG_COMPLETE_YN,
     CONFIG_VALID_YN,
     CONFIG_TOP_MODEL_LINE_ID,
     CONFIG_ITEM_TYPE,
     CONFIG_ITEM_ID,
     SERVICE_ITEM_YN,
     PH_PRICING_TYPE,
     PH_PRICE_BREAK_BASIS,
     PH_MIN_QTY,
     PH_MIN_AMT,
     PH_QP_REFERENCE_ID,
     PH_VALUE,
     PH_ENFORCE_PRICE_LIST_YN,
     PH_ADJUSTMENT,
     PH_INTEGRATED_WITH_QP,
     CUST_ACCT_ID,
     BILL_TO_SITE_USE_ID,
     INV_RULE_ID,
     LINE_RENEWAL_TYPE_CODE,
     SHIP_TO_SITE_USE_ID,
     PAYMENT_TERM_ID,
     DATE_CANCELLED,
  -- CANC_REASON_CODE,
  -- TRXN_EXTENSION_ID,
     TERM_CANCEL_SOURCE,
     ANNUALIZED_FACTOR )
  SELECT
     p_new_line_id ID,
     LINE_NUMBER,
     CHR_ID,
     p_cle_id CLE_ID,
     CLE_ID_RENEWED,
     DNZ_CHR_ID,
     DISPLAY_SEQUENCE,
     STS_CODE,
     TRN_CODE,
     LSE_ID,
     EXCEPTION_YN,
     1 OBJECT_VERSION_NUMBER,
     FND_GLOBAL.USER_ID CREATED_BY,
     SYSDATE CREATION_DATE,
     FND_GLOBAL.USER_ID LAST_UPDATED_BY,
     SYSDATE LAST_UPDATE_DATE,
     HIDDEN_IND,
     PRICE_NEGOTIATED,
     PRICE_LEVEL_IND,
     PRICE_UNIT,
     PRICE_UNIT_PERCENT,
     INVOICE_LINE_LEVEL_IND,
     DPAS_RATING,
     TEMPLATE_USED,
     PRICE_TYPE,
     CURRENCY_CODE,
     FND_GLOBAL.LOGIN_ID LAST_UPDATE_LOGIN,
     DATE_TERMINATED,
     l_start_date START_DATE,
     NULL END_DATE,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8,
     ATTRIBUTE9,
     ATTRIBUTE10,
     ATTRIBUTE11,
     ATTRIBUTE12,
     ATTRIBUTE13,
     ATTRIBUTE14,
     ATTRIBUTE15,
     SECURITY_GROUP_ID,
     CLE_ID_RENEWED_TO,
     PRICE_NEGOTIATED_RENEWED,
     CURRENCY_CODE_RENEWED,
     UPG_ORIG_SYSTEM_REF,
     UPG_ORIG_SYSTEM_REF_ID,
     DATE_RENEWED,
     ORIG_SYSTEM_SOURCE_CODE,  -- CHECK IF THIS NEED TO BE POPULATED
     p_old_line_id ORIG_SYSTEM_ID1,
     ORIG_SYSTEM_REFERENCE1,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     REQUEST_ID,
     PRICE_LIST_ID,
     PRICE_LIST_LINE_ID,
     LINE_LIST_PRICE,
     ITEM_TO_PRICE_YN,
     PRICING_DATE,
     PRICE_BASIS_YN,
     CONFIG_HEADER_ID,
     CONFIG_REVISION_NUMBER,
     CONFIG_COMPLETE_YN,
     CONFIG_VALID_YN,
     CONFIG_TOP_MODEL_LINE_ID,
     CONFIG_ITEM_TYPE,
     CONFIG_ITEM_ID,
     SERVICE_ITEM_YN,
     PH_PRICING_TYPE,
     PH_PRICE_BREAK_BASIS,
     PH_MIN_QTY,
     PH_MIN_AMT,
     PH_QP_REFERENCE_ID,
     PH_VALUE,
     PH_ENFORCE_PRICE_LIST_YN,
     PH_ADJUSTMENT,
     PH_INTEGRATED_WITH_QP,
     CUST_ACCT_ID,
     BILL_TO_SITE_USE_ID,
     INV_RULE_ID,
     LINE_RENEWAL_TYPE_CODE,
     SHIP_TO_SITE_USE_ID,
     PAYMENT_TERM_ID,
     DATE_CANCELLED,
  -- CANC_REASON_CODE,
  -- TRXN_EXTENSION_ID,
     TERM_CANCEL_SOURCE,
     ANNUALIZED_FACTOR
  FROM okc_k_lines_b
 WHERE id = p_old_line_id;

INSERT INTO okc_k_lines_tl
   ( ID,
     LANGUAGE,
     SOURCE_LANG,
     SFWT_FLAG,
      NAME,
     COMMENTS,
     ITEM_DESCRIPTION,
     BLOCK23TEXT,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     SECURITY_GROUP_ID,
     OKE_BOE_DESCRIPTION,
     COGNOMEN )
SELECT
     p_new_line_id ID,
     LANGUAGE,
     SOURCE_LANG,
     SFWT_FLAG,
     l_coverage_name NAME,
     COMMENTS,
     ITEM_DESCRIPTION,
     BLOCK23TEXT,
     FND_GLOBAL.USER_ID CREATED_BY,
     SYSDATE CREATION_DATE,
     FND_GLOBAL.USER_ID LAST_UPDATED_BY,
     SYSDATE LAST_UPDATE_DATE,
     FND_GLOBAL.LOGIN_ID LAST_UPDATE_LOGIN,
     SECURITY_GROUP_ID,
     OKE_BOE_DESCRIPTION,
     COGNOMEN
  FROM okc_k_lines_tl
  where id=p_old_line_id;


RETURN x_return_status;

EXCEPTION
when others then
OKC_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
return x_return_status;

END CREATE_OKC_LINE;


-- This function is called by copy_standard_coverage for insertion into okc_k_items table
FUNCTION CREATE_OKC_ITEM(p_new_item_id NUMBER,
                         p_old_item_id NUMBER,
                         p_cle_id      NUMBER) return VARCHAR2 IS

x_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

 INSERT INTO okc_k_items
   ( ID,
     CLE_ID,
     CHR_ID,
     CLE_ID_FOR,
     DNZ_CHR_ID,
     OBJECT1_ID1,
     OBJECT1_ID2,
     JTOT_OBJECT1_CODE,
     UOM_CODE,
     EXCEPTION_YN,
     NUMBER_OF_ITEMS,
     PRICED_ITEM_YN,
     OBJECT_VERSION_NUMBER,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     SECURITY_GROUP_ID,
     UPG_ORIG_SYSTEM_REF,
     UPG_ORIG_SYSTEM_REF_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     REQUEST_ID )
  SELECT
     p_new_item_id ID,
     p_cle_id CLE_ID,
     CHR_ID,
     CLE_ID_FOR,
     DNZ_CHR_ID,
     OBJECT1_ID1,
     OBJECT1_ID2,
     JTOT_OBJECT1_CODE,
     UOM_CODE,
     EXCEPTION_YN,
     NUMBER_OF_ITEMS,
     PRICED_ITEM_YN,
     1 OBJECT_VERSION_NUMBER,
     FND_GLOBAL.USER_ID CREATED_BY,
     SYSDATE CREATION_DATE,
     FND_GLOBAL.USER_ID LAST_UPDATED_BY,
     SYSDATE LAST_UPDATE_DATE,
     FND_GLOBAL.LOGIN_ID LAST_UPDATE_LOGIN,
     SECURITY_GROUP_ID,
     UPG_ORIG_SYSTEM_REF,
     p_old_item_id UPG_ORIG_SYSTEM_REF_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     REQUEST_ID
  FROM OKC_K_ITEMS
  WHERE ID= p_old_item_id;

RETURN x_return_status;

EXCEPTION
when others then
x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
OKC_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);

return x_return_status;

END CREATE_OKC_ITEM;

-- This function is called by copy_standard_coverage for insertion into okc_k_party_roles_b table
FUNCTION CREATE_OKC_PARTY(p_new_party_id NUMBER,
                          p_old_party_id NUMBER,
                          p_cle_id      NUMBER) return VARCHAR2 IS

x_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

 INSERT INTO okc_k_party_roles_b
   ( ID,
     CHR_ID,
     CLE_ID,
     DNZ_CHR_ID,
     RLE_CODE,
     OBJECT1_ID1,
     OBJECT1_ID2,
     JTOT_OBJECT1_CODE,
     OBJECT_VERSION_NUMBER,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     CODE,
     FACILITY,
     MINORITY_GROUP_LOOKUP_CODE,
     SMALL_BUSINESS_FLAG,
     WOMEN_OWNED_FLAG,
     LAST_UPDATE_LOGIN,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8,
     ATTRIBUTE9,
     ATTRIBUTE10,
     ATTRIBUTE11,
     ATTRIBUTE12,
     ATTRIBUTE13,
     ATTRIBUTE14,
     ATTRIBUTE15,
     SECURITY_GROUP_ID,
     CPL_ID,
     PRIMARY_YN,
     BILL_TO_SITE_USE_ID,
     CUST_ACCT_ID,
     ORIG_SYSTEM_ID1,
     ORIG_SYSTEM_REFERENCE1,
     ORIG_SYSTEM_SOURCE_CODE)
  SELECT
     p_new_party_id ID,
     CHR_ID,
     p_cle_id CLE_ID,
     DNZ_CHR_ID,
     RLE_CODE,
     OBJECT1_ID1,
     OBJECT1_ID2,
     JTOT_OBJECT1_CODE,
     OBJECT_VERSION_NUMBER,
     FND_GLOBAL.USER_ID CREATED_BY,
     SYSDATE CREATION_DATE,
     FND_GLOBAL.USER_ID LAST_UPDATED_BY,
     SYSDATE LAST_UPDATE_DATE,
     CODE,
     FACILITY,
     MINORITY_GROUP_LOOKUP_CODE,
     SMALL_BUSINESS_FLAG,
     WOMEN_OWNED_FLAG,
     FND_GLOBAL.LOGIN_ID LAST_UPDATE_LOGIN,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8,
     ATTRIBUTE9,
     ATTRIBUTE10,
     ATTRIBUTE11,
     ATTRIBUTE12,
     ATTRIBUTE13,
     ATTRIBUTE14,
     ATTRIBUTE15,
     SECURITY_GROUP_ID,
     CPL_ID,
     PRIMARY_YN,
     BILL_TO_SITE_USE_ID,
     CUST_ACCT_ID,
     p_old_party_id ORIG_SYSTEM_ID1,
     ORIG_SYSTEM_REFERENCE1,
     ORIG_SYSTEM_SOURCE_CODE
  FROM OKC_K_PARTY_ROLES_B
  WHERE ID= p_old_party_id;

 -- insert into tl table
  INSERT INTO okc_k_party_roles_tl
   ( ID,
     LANGUAGE,
     SOURCE_LANG,
     SFWT_FLAG,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     COGNOMEN,
     ALIAS,
     LAST_UPDATE_LOGIN,
     SECURITY_GROUP_ID
      )
SELECT
     p_new_party_id ID,
     LANGUAGE,
     SOURCE_LANG,
     SFWT_FLAG,
     FND_GLOBAL.USER_ID CREATED_BY,
     SYSDATE CREATION_DATE,
     FND_GLOBAL.USER_ID LAST_UPDATED_BY,
     SYSDATE LAST_UPDATE_DATE,
     COGNOMEN,
     ALIAS,
     FND_GLOBAL.LOGIN_ID LAST_UPDATE_LOGIN,
     SECURITY_GROUP_ID
  FROM okc_k_party_roles_tl
  where id=p_old_party_id;

RETURN x_return_status;

EXCEPTION
when others then
OKC_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
return x_return_status;
END CREATE_OKC_PARTY;

-- This function is called by copy_standard_coverage for insertion into okc_contacts table
FUNCTION CREATE_OKC_CONTACT(p_new_cpl_id NUMBER,
                            p_old_cpl_id NUMBER) return VARCHAR2 IS


x_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

/*cgopinee bugfix for 6882512-Addded dnz_ste_code*/

 INSERT INTO okc_contacts
   ( ID,
     CPL_ID,
     CRO_CODE,
     DNZ_CHR_ID,
     OBJECT1_ID1,
     OBJECT1_ID2,
     JTOT_OBJECT1_CODE,
     OBJECT_VERSION_NUMBER,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     CONTACT_SEQUENCE,
     LAST_UPDATE_LOGIN,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8,
     ATTRIBUTE9,
     ATTRIBUTE10,
     ATTRIBUTE11,
     ATTRIBUTE12,
     ATTRIBUTE13,
     ATTRIBUTE14,
     ATTRIBUTE15,
     SECURITY_GROUP_ID,
     START_DATE,
     END_DATE,
     PRIMARY_YN,
     RESOURCE_CLASS,
     SALES_GROUP_ID,
     DNZ_STE_CODE)
     --ORIG_SYSTEM_ID)
  SELECT
     okc_p_util.raw_to_number(sys_guid()),
     p_new_cpl_id CPL_ID, -- new party id (CPL_ID)
     CRO_CODE,
     DNZ_CHR_ID,
     OBJECT1_ID1,
     OBJECT1_ID2,
     JTOT_OBJECT1_CODE,
     OBJECT_VERSION_NUMBER,
     FND_GLOBAL.USER_ID CREATED_BY,
     SYSDATE CREATION_DATE,
     FND_GLOBAL.USER_ID LAST_UPDATED_BY,
     SYSDATE LAST_UPDATE_DATE,
     CONTACT_SEQUENCE,
     FND_GLOBAL.LOGIN_ID LAST_UPDATE_LOGIN,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8,
     ATTRIBUTE9,
     ATTRIBUTE10,
     ATTRIBUTE11,
     ATTRIBUTE12,
     ATTRIBUTE13,
     ATTRIBUTE14,
     ATTRIBUTE15,
     SECURITY_GROUP_ID,
     START_DATE,
     END_DATE,
     PRIMARY_YN,
     RESOURCE_CLASS,
     SALES_GROUP_ID,
     DNZ_STE_CODE
     --ID --ORIG_SYSTEM_ID
 FROM OKC_CONTACTS
 WHERE cpl_id = p_old_cpl_id;


RETURN x_return_status;

EXCEPTION
WHEN others THEN
OKC_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
return x_return_status;

END CREATE_OKC_CONTACT;


BEGIN

SAVEPOINT copy_standard_coverage;
 l_old_coverage_id := P_old_coverage_id;

 IF (G_DEBUG_ENABLED = 'Y') THEN
      okc_debug.Set_Indentation('Copy_Standard_Coverage');
      okc_debug.log('BEGIN COPY_STANDARD_COVERAGE'||l_return_status, 2);
 END IF;

 -- Create Coverage line
 l_new_coverage_id :=okc_p_util.raw_to_number(sys_guid());
 l_cov_flag :=1;
 l_return_status := CREATE_OKC_LINE(l_new_coverage_id,l_old_coverage_id,l_cov_flag);
  IF (G_DEBUG_ENABLED = 'Y') THEN
      okc_debug.log('AFTER CREATE_OKC_LINE FOR COVERAGE'||l_return_status, 2);
 END IF;

 IF l_return_status <> OKC_API.G_RET_STS_SUCCESS
 THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
 END IF;

 -- Create business process line
FOR Childline_Rec1 IN Cur_Childline(l_old_coverage_id)    --Loop1
LOOP
    l_old_bp_id := ChildLine_rec1.Id;
    l_new_bp_id := okc_p_util.raw_to_number(sys_guid());
    l_cov_flag := 2;
    l_return_status := CREATE_OKC_LINE(l_new_bp_id,l_old_bp_id,l_cov_flag,l_new_coverage_id);
    IF (G_DEBUG_ENABLED = 'Y') THEN
      okc_debug.log('AFTER CREATE_OKC_LINE FOR BP'||l_return_status, 2);
    END IF;

    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS
    THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

     -- Create  a Contract ITEM FOR BUSINESS PROCESS
    open CUR_ItemDet(l_old_bp_id);
    fetch CUR_ItemDet into l_old_bp_item_id;
    close CUR_ItemDet;
    l_new_bp_item_id :=okc_p_util.raw_to_number(sys_guid());
    l_return_status := CREATE_OKC_ITEM(l_new_bp_item_id,l_old_bp_item_id,l_new_bp_id);
    IF (G_DEBUG_ENABLED = 'Y') THEN
      okc_debug.log('AFTER CREATE_OKC_ITEM'||l_return_status, 2);
    END IF;

    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS
    THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- Done Business Process

     -- Create Reaction times line  Billtypes
    FOR tmp_crt_rec IN Cur_ChildLine1(l_old_bp_id)
    LOOP
       l_old_rt_id := tmp_crt_rec.ID;
       l_new_rt_id := okc_p_util.raw_to_number(sys_guid());
       l_cov_flag := 3;
       l_return_status := CREATE_OKC_LINE(l_new_rt_id,l_old_rt_id,l_cov_flag,l_new_bp_id);
       IF (G_DEBUG_ENABLED = 'Y') THEN
       okc_debug.log('AFTER CREATE_OKC_LINE FOR RT'||l_return_status, 2);
       END IF;

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS
       THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       IF tmp_crt_rec.lse_id in (5,59) -- For Billtypes
       THEN
         --Create entry in okc_k_items
         open CUR_ItemDet(l_old_rt_id);
         fetch CUR_ItemDet into l_old_rt_item_id;
         close CUR_ItemDet;
         l_new_rt_item_id :=okc_p_util.raw_to_number(sys_guid());
         l_return_status := CREATE_OKC_ITEM(l_new_rt_item_id,l_old_rt_item_id,l_new_rt_id);
	 IF (G_DEBUG_ENABLED = 'Y') THEN
         okc_debug.log('AFTER CREATE_OKC_ITEM FOR RT'||l_return_status, 2);
         END IF;

         IF l_return_status <> OKC_API.G_RET_STS_SUCCESS
         THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
         --Create bill rate lines
         FOR tmp_br_Rec IN Cur_ChildLine_br(l_old_rt_id)
         LOOP
            l_old_br_id := tmp_br_Rec.ID;
            IF NOT l_old_br_id IS NULL
            THEN
               l_new_br_id := okc_p_util.raw_to_number(sys_guid());
               l_cov_flag := 4;
               l_return_status := CREATE_OKC_LINE(l_new_br_id,l_old_br_id,l_cov_flag,l_new_rt_id);
	       IF (G_DEBUG_ENABLED = 'Y') THEN
                   okc_debug.log('AFTER CREATE_OKC_LINE FOR BR'||l_return_status, 2);
               END IF;

               IF l_return_status <> OKC_API.G_RET_STS_SUCCESS
               THEN
                  RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;
             END IF;
         END LOOP;   --End loop for billrates
       END IF;
    END LOOP;
        -- Done Reaction times  billtypes

    -- Preferred Engineers
    OPEN Cur_PTRLDet(l_old_bp_id,'VENDOR');
    FETCH Cur_PTRLDet INTO cr_ptrl_det;
    IF Cur_PTRLDet % FOUND
    THEN
        l_old_party_id := cr_ptrl_det.id;
        l_new_party_id :=okc_p_util.raw_to_number(sys_guid());
        l_return_status := CREATE_OKC_PARTY(l_new_party_id,l_old_party_id,l_new_bp_id);
        IF (G_DEBUG_ENABLED = 'Y') THEN
            okc_debug.log('AFTER CREATE_OKC_PARTY'||l_return_status, 2);
        END IF;

        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
           RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
           -- okc_contacts
        l_return_status := CREATE_OKC_CONTACT(l_new_party_id,l_old_party_id);
        IF (G_DEBUG_ENABLED = 'Y') THEN
            okc_debug.log('AFTER CREATE_OKC_CONTACT'||l_return_status, 2);
        END IF;

        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
           RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    END IF;
    CLOSE Cur_PTRLDet;

        -- Done Preferred Engineers


END LOOP;  -- End loop for bp
-- Create oks components
          Copy_Coverage
         (p_api_version       => 1.0,
          p_init_msg_list     => OKC_API.G_FALSE,
          x_return_status     => l_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data,
          p_contract_line_id  => l_new_coverage_id);

 IF (G_DEBUG_ENABLED = 'Y') THEN
     okc_debug.log('AFTER Copy_Coverage'||l_return_status, 2);
 END IF;


 IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
             Raise G_EXCEPTION_HALT_VALIDATION;
 End If;

 x_new_coverage_id := l_new_coverage_id;
 x_return_status   := l_return_status;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
        x_return_status := l_return_status ;
        ROLLBACK  to copy_standard_coverage;
  WHEN OTHERS THEN
       OKC_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       ROLLBACK  to copy_standard_coverage;

 END COPY_STANDARD_COVERAGE;
END OKS_COVERAGES_PVT;


/
