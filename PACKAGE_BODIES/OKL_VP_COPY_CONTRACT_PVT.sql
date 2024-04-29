--------------------------------------------------------
--  DDL for Package Body OKL_VP_COPY_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_COPY_CONTRACT_PVT" as
 /*$Header: OKLRCPXB.pls 120.8 2008/02/15 11:03:00 abhsaxen noship $*/

SUBTYPE gvev_rec_type  IS OKC_CONTRACT_PUB.gvev_rec_type;
SUBTYPE chrv_rec_type    IS OKC_CONTRACT_PUB.chrv_rec_type;
--fmiao copy pa associations--
subtype vasv_rec_type is okl_vas_pvt.vasv_rec_type;
subtype vasv_tbl_type is okl_vas_pvt.vasv_tbl_type;

-- abindal --
SUBTYPE ech_rec_type IS okl_ech_pvt.okl_ech_rec;
SUBTYPE ecl_tbl_type IS okl_ecl_pvt.okl_ecl_tbl;
SUBTYPE ecv_tbl_type IS okl_ecv_pvt.okl_ecv_tbl;
SUBTYPE rgr_tbl_type IS okl_rgrp_rules_process_pvt.rgr_tbl_type;

G_VENDOR_PROGRAM_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'VENDOR_PROGRAM';

--------------------------------------------------------------------------
  --Procedure copy_governances - Makes a copy of the okc_governances.
  --------------------------------------------------------------------------
  PROCEDURE copy_governances(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_chr_id                  IN NUMBER,
    p_to_chr_id                    IN NUMBER) IS

    l_gvev_rec 	gvev_rec_type;
    x_gvev_rec 	gvev_rec_type;
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    CURSOR 	c_governances IS
    SELECT 	id
    FROM 		okc_governances_v
    WHERE 	dnz_chr_id = p_from_chr_id
    AND		cle_id is null;

  ----------------------------------------------------------------------------
  --Function to populate the contract governance record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION get_gvev_rec(p_gve_id IN NUMBER,
				      x_gvev_rec OUT NOCOPY gvev_rec_type)
    RETURN  VARCHAR2 IS
      l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_gvev_rec IS
      SELECT DNZ_CHR_ID,
             ISA_AGREEMENT_ID,
             CHR_ID,
             CLE_ID,
             CHR_ID_REFERRED,
             CLE_ID_REFERRED,
             COPIED_ONLY_YN
        FROM OKC_GOVERNANCES
       WHERE ID = p_gve_id;
    BEGIN
      OPEN c_gvev_rec;
      FETCH c_gvev_rec
      INTO x_gvev_rec.DNZ_CHR_ID,
      x_gvev_rec.ISA_AGREEMENT_ID,
      x_gvev_rec.CHR_ID,
      x_gvev_rec.CLE_ID,
      x_gvev_rec.CHR_ID_REFERRED,
      x_gvev_rec.CLE_ID_REFERRED,
      x_gvev_rec.COPIED_ONLY_YN;

      l_no_data_found := c_gvev_rec%NOTFOUND;
      CLOSE c_gvev_rec;
      IF l_no_data_found THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKL_API.SET_MESSAGE(p_app_name	=> g_app_name,
					     p_msg_name	=> g_unexpected_error,
					     p_token1		=> g_sqlcode_token,
					     p_token1_value	=> SQLCODE,
					     p_token2		=> g_sqlerrm_token,
					     p_token2_value	=> SQLERRM);

        -- notify caller of an UNEXPECTED error
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_gvev_rec;
  BEGIN
    x_return_status := l_return_status;
    FOR l_c_governances IN c_governances LOOP
      l_return_status := get_gvev_rec(	p_gve_id 	 => l_c_governances.id,
					               x_gvev_rec => l_gvev_rec);
      l_gvev_rec.chr_id := p_to_chr_id;
      l_gvev_rec.dnz_chr_id := p_to_chr_id;
      IF(l_return_status = OKL_API.G_RET_STS_SUCCESS)THEN
        OKC_CONTRACT_PUB.create_governance(
             p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> l_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_gvev_rec		=> l_gvev_rec,
             x_gvev_rec		=> x_gvev_rec);
        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name	=> g_app_name,
					     p_msg_name	=> g_unexpected_error,
					     p_token1		=> g_sqlcode_token,
					     p_token1_value	=> SQLCODE,
					     p_token2		=> g_sqlerrm_token,
					     p_token2_value	=> SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END copy_governances;


 FUNCTION is_copy_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2 DEFAULT NULL) RETURN varchar2 IS

    l_count		NUMBER;
    l_template_yn	VARCHAR2(3);
    l_return_value	VARCHAR2(3) := 'Y';


    CURSOR c_template IS
    SELECT template_yn
    FROM okc_k_headers_b
    WHERE id = p_chr_id;

    CURSOR invalid_template IS
    SELECT count(*)
    FROM okc_k_headers_b
    WHERE template_yn = 'Y'
	AND sysdate between start_date and nvl(end_date, sysdate)
	AND id = p_chr_id;
  BEGIN
    OPEN c_template;
    FETCH c_template INTO l_template_yn;
    CLOSE c_template;

    If l_template_yn = 'Y' Then
      OPEN invalid_template;
      FETCH invalid_template INTO l_count;
      CLOSE invalid_template;

      If l_count>0 Then
	   l_return_value := 'Y';
        RETURN(l_return_value);
      Else
	   l_return_value := 'N';
       RETURN(l_return_value);
      End If;
   Else
	  l_return_value := 'Y';
        RETURN(l_return_value);
  End If;
    RETURN(l_return_value);
  END is_copy_allowed;


PROCEDURE copy_contract(p_api_version          IN               NUMBER,
                        p_init_msg_list        IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        x_return_status        OUT              NOCOPY VARCHAR2,
                        x_msg_count            OUT              NOCOPY NUMBER,
                        x_msg_data             OUT              NOCOPY VARCHAR2,
                        p_copy_rec             IN               copy_header_rec_type,
                        x_new_contract_id      OUT NOCOPY              NUMBER)IS

  l_copy_allowed varchar2(1);
  l_contract_id  number;
  l_sts_code varchar2(30);
  l_governances number;
  l_return_value	number;
  l_chr_id number;
  l_api_version  number := 1.0;

  l_api_name  CONSTANT VARCHAR2(30) := 'copy_contract';

  l_from_agreement_number varchar2(120);
  l_to_agreement_number varchar2(120);
  l_template_yn varchar2(3);
  l1_return_status varchar2(3);
  l2_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_dummy             VARCHAR2(1);
  l_found             BOOLEAN;
  l_process_id NUMBER;

  l_line_id NUMBER;
  l_cpl_id NUMBER;
  l_rrd_id NUMBER;
  l_authoring_org_id NUMBER; --CDUBEY l_authoring_org_id added for MOAC

  l1_header_rec  chrv_rec_type;
  l2_header_rec  chrv_rec_type;
  l_cpsv_rec OKC_CONTRACT_PUB.cpsv_rec_type;

  CURSOR cur_k_header(p_id number)  IS
  SELECT contract_number,sts_code,authoring_org_id FROM okc_k_headers_v
  WHERE id=p_id;


  CURSOR count_governances(p_from_chr_id number) IS
  SELECT id
  FROM okc_governances_v
  WHERE dnz_chr_id = p_from_chr_id;

  CURSOR l_chr_csr2(contract_no varchar2,contract_no_modifier varchar2) IS
  SELECT 'x'
  FROM okc_k_headers_b
  WHERE contract_number = contract_no
  AND   contract_number_modifier = contract_no_modifier;

  CURSOR cur_contract_process(p_chr_id NUMBER) IS
  SELECT id FROM okc_k_processes WHERE chr_id = p_chr_id;

-- begin of block

--fmiao copy pa associations
  CURSOR copy_pa_assoc_csr (p_chr_id NUMBER) IS
  SELECT id
  FROM okl_vp_associations
  WHERE chr_id = p_chr_id
  AND crs_id IS NULL;

  -- cursor for fetching the rules group.
  CURSOR c_get_rules_csr (cp_chr_id okc_k_headers_b.id%TYPE) IS
  SELECT rle.id,
         rle.rgp_id,
         rle.dnz_chr_id,
         rle.std_template_yn,
         rle.warn_yn,
         rle.rule_information_category,
         prl.id rule_information1,
         rle.rule_information2,
         rle.template_yn,
         rle.comments,
         rlg.rgd_code
  FROM okc_rules_b rle,
       okc_k_party_roles_b prl,
       okc_k_party_roles_b prl1,
       okc_rule_groups_b rlg
  WHERE rle.dnz_chr_id = cp_chr_id
  AND   prl.dnz_chr_id = cp_chr_id
  AND   prl.rle_code = prl1.rle_code
  AND   prl1.id = rle.rule_information1
  AND   rle.rule_information_category = 'VGLRSP'
  AND   rle.rgp_id = rlg.id;


-- abindal start --
  CURSOR c_get_agrmt_dates_csr(cp_chr_id okc_k_headers_b.id%TYPE) IS
  SELECT start_date
        ,end_date
  FROM okc_k_headers_b
  WHERE id = cp_chr_id;

   --abhsxen bug 6481995 start
   CURSOR cur_k_party_roles(contract_id NUMBER) IS
   SELECT id FROM okc_k_party_roles_v
   WHERE chr_id = contract_id
   AND   rle_code = 'OKL_VENDOR';

   l_party_id NUMBER;
   l_kplv_rec  okl_kpl_pvt.kplv_rec_type;
   x_kplv_rec  okl_kpl_pvt.kplv_rec_type;
   --abhsxen bug 6487870 end

   cv_get_agrmnt_dates c_get_agrmt_dates_csr%ROWTYPE;

  lx_ech_rec ech_rec_type;
  lx_ecl_tbl ecl_tbl_type;
  lx_ecv_tbl ecv_tbl_type;

  x_ech_rec ech_rec_type;
  x_ecl_tbl ecl_tbl_type;
  x_ecv_tbl ecv_tbl_type;
-- abindal end --

  l_rgr_tbl_type rgr_tbl_type;
  l_vasv_tbl vasv_tbl_type;
  xl_vasv_tbl vasv_tbl_type;
  l_vasv_rec vasv_rec_type;
  i NUMBER;
  j NUMBER;

BEGIN
   x_return_status := OKL_API.START_ACTIVITY(p_api_name      => l_api_name
                                             ,p_init_msg_list => p_init_msg_list
                                             ,p_api_type      => '_PVT'
                                             ,x_return_status => x_return_status
                                             );
   IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  IF((p_copy_rec.p_to_agreement_number = OKL_API.G_MISS_CHAR) OR (p_copy_rec.p_to_agreement_number IS NULL)) THEN
    OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_COPY_TO_NO_REQD');
    x_return_status :=okl_api.g_ret_sts_error;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  l_contract_id  :=p_copy_rec.p_id;
  l_to_agreement_number   :=p_copy_rec.p_to_agreement_number;
  l_template_yn :=p_copy_rec.p_template_yn;

  open cur_k_header(l_contract_id);
  fetch cur_k_header into l_from_agreement_number,l_sts_code,l_authoring_org_id; --CDUBEY l_authoring_org_id added for MOAC

   if (cur_k_header%found) then
     -- to check whether the new contract you want to create already exists
     open l_chr_csr2(p_copy_rec.p_to_agreement_number,'1.0');
     fetch l_chr_csr2 into l_dummy;
     l_found := l_chr_csr2%FOUND;
     close l_chr_csr2;

     If (l_found) Then
      OKL_API.SET_MESSAGE(p_app_name		=> g_app_name,
         p_msg_name  	=> 'OKL_VP_CONTRACT_EXISTS',
         p_token1    	=> 'NUMBER',
         p_token1_value	=> p_copy_rec.p_to_agreement_number
         );
        RAISE OKL_API.G_EXCEPTION_ERROR;
     end if;

     l_copy_allowed :=is_copy_allowed(l_contract_id,l_sts_code);

     -- COMMENTING TO BE TAKEN OUT LATER AS PACKAGE OKL_COPY_CONTRACT_PUB HAS NOT BEEN CHECKED IN

     if(l_copy_allowed='Y')then
       okl_copy_contract_pub.copy_contract(
                       p_api_version => l_api_version,
                       p_init_msg_list => OKC_API.G_TRUE,
                       x_return_status => x_return_status,
                       x_msg_count  => x_msg_count,
                       x_msg_data   => x_msg_data,
                       p_commit     =>okc_api.g_false,
                       p_chr_id     =>l_contract_id,
                       p_contract_number =>l_to_agreement_number,
                       p_contract_number_modifier => '1.0',
                       p_to_template_yn  => l_template_yn,
                       p_renew_ref_yn  => 'N',
                       p_override_org  => 'Y',
                       x_chr_id  => l_chr_id);
       IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

	 --abhsxen bug 6487870 start

	 OPEN cur_k_party_roles(l_chr_id);
	 FETCH cur_k_party_roles INTO l_party_id;
	 IF (cur_k_party_roles%NOTFOUND) THEN
	   CLOSE cur_k_party_roles;
	       OKL_API.set_message(p_app_name      => g_app_name,
		       p_msg_name      => 'OKL_JTOT_CODE_NOT_FOUND'
		       );
	     RAISE OKL_API.G_EXCEPTION_ERROR;
	 END IF;
	 CLOSE cur_k_party_roles;

	 l_kplv_rec.ID :=l_party_id;

	 OKL_KPL_PVT.insert_row(
	      p_api_version     => p_api_version,
	      p_init_msg_list   => p_init_msg_list,
	      x_return_status   => x_return_status,
	      x_msg_count       => x_msg_count,
	      x_msg_data         => x_msg_data,
	      p_kplv_rec        => l_kplv_rec,
	      x_kplv_rec        => x_kplv_rec);

	  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	 ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
	     RAISE OKL_API.G_EXCEPTION_ERROR;
	  END IF;
     --abhsxen bug 6487870 end

       -- copy governances
       copy_governances(
           p_api_version   => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => x_return_status
          ,x_msg_count     => x_msg_count
          ,x_msg_data      => x_msg_data
          ,p_from_chr_id   => l_contract_id
          ,p_to_chr_id     => l_chr_id
       );
       IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- fmiao copy pa associations --
       OPEN copy_pa_assoc_csr (l_contract_id);
       LOOP
         FETCH copy_pa_assoc_csr INTO l_vasv_rec.id;
         EXIT WHEN copy_pa_assoc_csr%NOTFOUND;
         i := copy_pa_assoc_csr%RowCount;
         l_vasv_rec.chr_id := l_chr_id;
         l_vasv_tbl(i) := l_vasv_rec;
       END LOOP;
       CLOSE copy_pa_assoc_csr;

       IF(l_vasv_tbl.count <> 0) THEN
         okl_vp_associations_pvt.copy_vp_associations(
           p_api_version                  => p_api_version,
           p_init_msg_list                => p_init_msg_list,
           x_return_status                => x_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_vasv_tbl                     => l_vasv_tbl,
           x_vasv_tbl                     => xl_vasv_tbl
         );
       END IF;

       -- end fmiao copy pa associations --

       -- updating the rules group record of the new contract created.--
       j := 0;
       FOR rules_rec IN c_get_rules_csr(l_chr_id) LOOP
          j := j + 1;
          l_rgr_tbl_type(j).rule_id := rules_rec.id;
          l_rgr_tbl_type(j).rgp_id := rules_rec.rgp_id;
          l_rgr_tbl_type(j).dnz_chr_id := rules_rec.dnz_chr_id;
          l_rgr_tbl_type(j).std_template_yn := rules_rec.std_template_yn;
          l_rgr_tbl_type(j).warn_yn := rules_rec.warn_yn;
          l_rgr_tbl_type(j).rule_information_category := rules_rec.rule_information_category;
          l_rgr_tbl_type(j).rule_information1 := rules_rec.rule_information1;
          l_rgr_tbl_type(j).rule_information2 := rules_rec.rule_information2;
          l_rgr_tbl_type(j).template_yn := rules_rec.template_yn;
          l_rgr_tbl_type(j).comments := rules_rec.comments;
          l_rgr_tbl_type(j).rgd_code := rules_rec.rgd_code;
      END LOOP;
      IF(j > 0) THEN
        okl_rgrp_rules_process_pvt.process_rule_group_rules( p_api_version   => p_api_version
                                                            ,p_init_msg_list => p_init_msg_list
                                                            ,x_return_status => x_return_status
                                                            ,x_msg_count     => x_msg_count
                                                            ,x_msg_data      => x_msg_data
                                                            ,p_chr_id        => l_chr_id
                                                            ,p_line_id       => l_line_id
                                                            ,p_cpl_id        => l_cpl_id
                                                            ,p_rrd_id        => l_rrd_id
                                                            ,p_rgr_tbl       => l_rgr_tbl_type
                                                           );
        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
     -- end rules group updation --

       -- abindal start copy eligibility criteria --
       OPEN c_get_agrmt_dates_csr(l_chr_id);
       FETCH c_get_agrmt_dates_csr INTO cv_get_agrmnt_dates;
       CLOSE c_get_agrmt_dates_csr;

       okl_ecc_values_pvt.get_eligibility_criteria(p_api_version    => p_api_version
                                               ,p_init_msg_list  => p_init_msg_list
                                               ,x_return_status  => x_return_status
                                               ,x_msg_count      => x_msg_count
                                               ,x_msg_data       => x_msg_data
                                               ,p_source_id      => l_contract_id
                                               ,p_source_type    => G_VENDOR_PROGRAM_CODE
                                               ,x_ech_rec        => lx_ech_rec
                                               ,x_ecl_tbl        => lx_ecl_tbl
                                               ,x_ecv_tbl        => lx_ecv_tbl
                                               );

       IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF(lx_ecl_tbl.count > 0)THEN
         -- set the eligibility criteria headers id to the original agreement id
         -- and the source to VENDOR_PROGRAM
         lx_ech_rec.source_id := l_chr_id;
         lx_ech_rec.source_object_code := G_VENDOR_PROGRAM_CODE;

         -- pass the criteria set id as null to indicate creation of the eligibility criteria on the original agreement
         lx_ech_rec.criteria_set_id := NULL;

         FOR i IN lx_ecl_tbl.FIRST..lx_ecl_tbl.LAST LOOP
           -- is_new_flag = Y indicates create mode
           lx_ecl_tbl(i).is_new_flag := 'Y';
         END LOOP;

         FOR i IN lx_ecv_tbl.FIRST..lx_ecv_tbl.LAST LOOP
           lx_ecv_tbl(i).criterion_value_id := NULL;
           -- validate_record = N indicates that the values in crit_cat_value1 and crit_cat_value2 will not be
           -- validated again. since this is the case of synchronization, the validation would have happened while
           -- saving the criteria values on the change request
           lx_ecv_tbl(i).validate_record := 'N';
         END LOOP;

         --call handle_eligibility_criteria
         okl_ecc_values_pvt.handle_eligibility_criteria(p_api_version     => p_api_version
                                                       ,p_init_msg_list   => p_init_msg_list
                                                       ,x_return_status   => x_return_status
                                                       ,x_msg_count       => x_msg_count
                                                       ,x_msg_data        => x_msg_data
                                                       ,p_source_eff_from => cv_get_agrmnt_dates.start_date
                                                       ,p_source_eff_to   => cv_get_agrmnt_dates.end_date
                                                       ,x_ech_rec         => x_ech_rec -- OUT
                                                       ,x_ecl_tbl         => x_ecl_tbl -- OUT
                                                       ,x_ecv_tbl         => x_ecv_tbl -- OUT
                                                       ,p_ech_rec         => lx_ech_rec -- IN
                                                       ,p_ecl_tbl         => lx_ecl_tbl -- IN
                                                       ,p_ecv_tbl         => lx_ecv_tbl -- IN
                                                        );
         IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       -- abindal end copy eligibility criteria --


       -- Murthy commented out code for count governances
       IF(x_return_status = OKL_API.G_RET_STS_SUCCESS) Then
         x_new_contract_id  :=l_chr_id;
         -- updating to set new contract to status NEW

	 l1_header_rec.id := l_chr_id;
         l1_header_rec.sts_code := 'NEW';
         l1_header_rec.org_id :=l_authoring_org_id; --CDUBEY added for MOAC


         OKC_CONTRACT_PUB.update_contract_header(
                          p_api_version	=> l_api_version,
                          x_return_status	=> x_return_status,
                          p_init_msg_list     => OKL_API.G_TRUE,
                          x_msg_count		=> x_msg_count,
                          x_msg_data		=> x_msg_data,
                          p_restricted_update	=> OKL_API.G_FALSE,
                          p_chrv_rec		=> l1_header_rec,
                          x_chrv_rec		=> l2_header_rec);
         IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         IF (l_template_yn = 'Y') THEN
           -- If template is yes, do not create workflow process. Since it
           -- is already created in call to copy_contract, delete the
           -- workflow process for this copied template.
           OPEN cur_contract_process(l_chr_id);
           FETCH cur_contract_process INTO l_process_id;
           IF(cur_contract_process%found) THEN
             CLOSE cur_contract_process;
             l_cpsv_rec.id := l_process_id;
             l_cpsv_rec.chr_id := l_chr_id;
             OKC_CONTRACT_PVT.delete_contract_process(
                            p_api_version       => p_api_version,
                            p_init_msg_list	=> p_init_msg_list,
                            x_return_status 	=> x_return_status,
                            x_msg_count     	=> x_msg_count,
                            x_msg_data      	=> x_msg_data,
                            p_cpsv_rec		=> l_cpsv_rec);
             -- okl delete contract process api failed
             IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
           END IF;
         END IF;
       ELSE
         -- okl copy contract api failed
         IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
     ELSE
       -- copy is not allowed as it is a template
	      x_return_status :=OKL_API.G_RET_STS_ERROR;
       OKC_API.SET_MESSAGE('OKL','OKL_INVALID_TEMPLATE');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE cur_k_header;
  ELSE
     NULL;
     CLOSE cur_k_header;
  END IF;
  OKL_API.END_ACTIVITY(x_msg_count     => x_msg_count ,x_msg_data      => x_msg_data );

  EXCEPTION
   WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
                              (p_api_name  => l_api_name
                              ,p_pkg_name  => G_PKG_NAME
                              ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                              ,x_msg_count => x_msg_count
                              ,x_msg_data  => x_msg_data
                              ,p_api_type  => '_PVT'
                              );

   WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                          ,g_pkg_name
                          ,'OKL_API.G_RET_STS_ERROR'
                          ,x_msg_count
                          ,x_msg_data
                          ,'_PVT'
                          );
   WHEN OTHERS THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                         ,g_pkg_name
                         ,'OTHERS'
                         ,x_msg_count
                         ,x_msg_data
                         ,'_PVT'
                         );
    -- end of function copy contract
  END copy_contract;
END okl_vp_copy_contract_pvt;

/
