--------------------------------------------------------
--  DDL for Package Body OKL_STREAM_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STREAM_MIGRATION_PVT" AS
/* $Header: OKLRSMGB.pls 120.9 2006/07/18 10:55:51 dkagrawa noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE create_strm_gen_template
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_strm_gen_template
  -- Description     : Procedure to create new stream templates and lines
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE create_strm_gen_template(p_api_version     IN  NUMBER
                    		   ,p_init_msg_list  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    		   ,x_return_status  OUT NOCOPY VARCHAR2
                    		   ,x_msg_count      OUT NOCOPY NUMBER
                    		   ,x_msg_data       OUT NOCOPY VARCHAR2
                    		   ,p_gtsv_rec       IN  gtsv_rec_type
                    		   ,p_gttv_rec       IN  gttv_rec_type
                    		   ,p_gtpv_tbl       IN  gtpv_tbl_type
                    		   ,p_gtlv_tbl       IN  gtlv_tbl_type
                    		   ,x_gttv_rec       OUT NOCOPY gttv_rec_type  -- Return the Template Info
) IS

l_api_name          CONSTANT VARCHAR2(40) := 'create_strm_gen_template';
l_api_version       CONSTANT NUMBER       := 1.0;
l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

l_init_msg_list     VARCHAR2(1);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);

l_gtsv_rec_in  gtsv_rec_type;
l_gttv_rec_in  gttv_rec_type;
l_gtpv_tbl_in  gtpv_tbl_type;
l_gtlv_tbl_in  gtlv_tbl_type;

l_gtsv_rec_out  gtsv_rec_type;
l_gttv_rec_out  gttv_rec_type;
l_gtpv_tbl_out  gtpv_tbl_type;
l_gtlv_tbl_out  gtlv_tbl_type;
i               NUMBER;

BEGIN
    -- Perform the Initializations
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_return_status := Okl_Api.START_ACTIVITY( l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);
   IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
   END IF;

   l_gtsv_rec_in  := p_gtsv_rec;
   -- Call the insert method of the Stream Generation Template Sets
   Okl_Gts_Pvt.insert_row(
        p_api_version => l_api_version
        ,p_init_msg_list  => p_init_msg_list
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
        ,p_gtsv_rec => l_gtsv_rec_in
        ,x_gtsv_rec => l_gtsv_rec_out
   );
   IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
   END IF;

   -- Populate the Stream Generate Template Records GTS_ID
   -- with the ID returned into the l_gtsv_rec_out
   l_gttv_rec_in := p_gttv_rec;
   l_gttv_rec_in.gts_id := l_gtsv_rec_out.id;
   l_gttv_rec_in.version := '1.0';
   l_gttv_rec_in.tmpt_status := 'NEW';

   -- Call the insert method of the Stream Generation Template
   Okl_Gtt_Pvt.insert_row(
        p_api_version => l_api_version
        ,p_init_msg_list  => p_init_msg_list
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
        ,p_gttv_rec => l_gttv_rec_in
        ,x_gttv_rec => l_gttv_rec_out
   );
   IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
   END IF;


   -- Now Need to loop through the entire table and update the gtt_id
   -- in the pricing parameters.
   -- Making sure PL/SQL table has records in it before passing
   IF (p_gtpv_tbl.COUNT > 0) THEN

      i := p_gtpv_tbl.FIRST;
      LOOP
        l_gtpv_tbl_in(i) := p_gtpv_tbl(i);
        l_gtpv_tbl_in(i).gtt_id := l_gttv_rec_out.id;
        EXIT WHEN (i = p_gtpv_tbl.LAST);
        i := p_gtpv_tbl.NEXT(i);
      END LOOP;

      -- Call the TAPI Procedcure to perform the actual inserts
      Okl_Gtp_Pvt.insert_row(
            p_api_version   => l_api_version
            ,p_init_msg_list => p_init_msg_list
            ,x_return_status => l_return_status
            ,x_msg_count => l_msg_count
            ,x_msg_data => l_msg_data
            ,p_gtpv_tbl => l_gtpv_tbl_in
            ,x_gtpv_tbl => l_gtpv_tbl_out
      );
      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
   END IF;

   -- Making sure PL/SQL table has records in it before passing
   IF (p_gtlv_tbl.COUNT > 0) THEN
      i := p_gtlv_tbl.FIRST;
      LOOP
        l_gtlv_tbl_in(i) := p_gtlv_tbl(i);
        l_gtlv_tbl_in(i).gtt_id := l_gttv_rec_out.id;

-- Commented out by santonyr
--     l_gtlv_tbl_in(i).primary_yn := G_INIT_PRIMARY_YN_YES;

       EXIT WHEN (i = p_gtlv_tbl.LAST);
        i := p_gtlv_tbl.NEXT(i);
      END LOOP;

      -- Call the TAPI Procedcure to perform the actual inserts
      Okl_Gtl_Pvt.insert_row(
            p_api_version   => l_api_version
            ,p_init_msg_list => p_init_msg_list
            ,x_return_status => l_return_status
            ,x_msg_count => l_msg_count
            ,x_msg_data => l_msg_data
            ,p_gtlv_tbl => l_gtlv_tbl_in
            ,x_gtlv_tbl => l_gtlv_tbl_out
      );
      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
   END IF;

   x_gttv_rec := l_gttv_rec_out;
   x_return_status := l_return_status;
   Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);


EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');

END create_strm_gen_template;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_template_lines
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : insert_template_lines
  -- Description     : Procedure to create/update stream templates and lines
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------


PROCEDURE insert_template_lines(p_api_version     IN  NUMBER
				,p_init_msg_list  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
				,x_return_status  OUT NOCOPY VARCHAR2
				,x_msg_count      OUT NOCOPY NUMBER
				,x_msg_data       OUT NOCOPY VARCHAR2
				,p_gtlv_tbl       IN  gtlv_tbl_type)
IS

l_api_name          CONSTANT VARCHAR2(40) := 'create_strm_gen_template';
l_api_version       CONSTANT NUMBER       := 1.0;
l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

l_init_msg_list     VARCHAR2(1);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);

l_gtlv_tbl_in  gtlv_tbl_type;
l_gtlv_tbl_out gtlv_tbl_type;

i               NUMBER;

BEGIN
    -- Perform the Initializations
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_return_status := Okl_Api.START_ACTIVITY( l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);
   IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
   END IF;

   -- Making sure PL/SQL table has records in it before passing
   IF (p_gtlv_tbl.COUNT > 0) THEN
      i := p_gtlv_tbl.FIRST;
      LOOP
        l_gtlv_tbl_in(i) := p_gtlv_tbl(i);
        EXIT WHEN (i = p_gtlv_tbl.LAST);
        i := p_gtlv_tbl.NEXT(i);
      END LOOP;

      -- Call the TAPI Procedcure to perform the actual inserts
      Okl_Gtl_Pvt.insert_row(
            p_api_version   => l_api_version
            ,p_init_msg_list => p_init_msg_list
            ,x_return_status => l_return_status
            ,x_msg_count => l_msg_count
            ,x_msg_data => l_msg_data
            ,p_gtlv_tbl => l_gtlv_tbl_in
            ,x_gtlv_tbl => l_gtlv_tbl_out);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
   END IF;

   x_return_status := l_return_status;
   Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);


EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');

END insert_template_lines;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate_Sty_Fee_Line
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Migrate_Sty_Fee_Line
  -- Description     : Procedure to migrate Feel Line stream types
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------


PROCEDURE Migrate_Sty_Fee_Line (p_sty_id 	NUMBER,
			        x_sty_purpose 	OUT NOCOPY VARCHAR2)
IS

l_sty_used_in_pth_fee 	   VARCHAR2(1);
l_sty_used_in_non_pth_fee  VARCHAR2(1);
l_sty_used_in_pth_service  VARCHAR2(1);
l_dummy_id 		   NUMBER;
l_new_sty_purpose 	   VARCHAR2(100);
l_fee_type 		   VARCHAR2(100);

-- Cursor to find if a stream type is used in Fee Lines.

CURSOR fee_pth_csr (l_sty_id NUMBER) IS
SELECT
  DISTINCT
  kle.fee_type
FROM
  okc_k_items       cim,
  okl_k_lines kle,
  okc_k_lines_b     cleb,
  okc_line_styles_b lseb,
  okc_k_headers_b   chrb,
  okl_k_headers khr,
  okl_product_parameters_v pdt
WHERE
  cim.cle_id = cleb.id  AND
  cleb.lse_id = lseb.id  AND
  lseb.lty_code = 'FEE'  AND
  cleb.chr_id = chrb.id  AND
  kle.id = cleb.id  AND
  chrb.scs_code IN ('LEASE','QUOTE') AND
  kle.fee_type = 'PASSTHROUGH' AND
  chrb.id = khr.id AND
  khr.pdt_id = pdt.id AND
  cim.object1_id1 = l_sty_id AND
  pdt.DEAL_TYPE IN ('LEASEOP', 'LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING', 'SALE') AND
  pdt.TAX_OWNER IN ('LESSOR', 'LESSEE');


CURSOR fee_non_pth_csr (l_sty_id NUMBER) IS
SELECT
  DISTINCT
  kle.fee_type
FROM
  okc_k_items       cim,
  okl_k_lines kle,
  okc_k_lines_b     cleb,
  okc_line_styles_b lseb,
  okc_k_headers_b   chrb,
  okl_k_headers khr,
  okl_product_parameters_v pdt
WHERE
  cim.cle_id = cleb.id  AND
  cleb.lse_id = lseb.id  AND
  lseb.lty_code = 'FEE'  AND
  cleb.chr_id = chrb.id  AND
  kle.id = cleb.id  AND
  chrb.scs_code IN ('LEASE','QUOTE') AND
  kle.fee_type <> 'PASSTHROUGH' AND
  chrb.id = khr.id AND
  khr.pdt_id = pdt.id AND
  cim.object1_id1 = l_sty_id AND
  pdt.DEAL_TYPE IN ('LEASEOP', 'LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING', 'SALE') AND
  pdt.TAX_OWNER IN ('LESSOR', 'LESSEE');

  -- Cursor to find if a stream type is used in Passthrough service

CURSOR pth_service_csr (l_sty_id NUMBER )
IS
SELECT rul.object1_id1
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_lines_b     cleb,
       okc_line_styles_b lseb,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.cle_id = cleb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASTRM'
AND    rgp.dnz_chr_id = chrb.id
AND rgp.rgd_code = 'LAPSTH'
AND    rul.dnz_chr_id = chrb.id
AND    cleb.lse_id = lseb.id
AND    lseb.lty_code = 'SOLD_SERVICE'
AND    cleb.chr_id = chrb.id
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND rul.object1_id1 = l_sty_id
AND  pdt.DEAL_TYPE IN ('LEASEOP', 'LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING', 'SALE')
AND  pdt.TAX_OWNER IN ('LESSOR', 'LESSEE');

BEGIN

     OPEN fee_pth_csr (p_sty_id) ;
     FETCH fee_pth_csr INTO l_fee_type;
     IF fee_pth_csr%NOTFOUND THEN
       l_sty_used_in_pth_fee := 'N';
     ELSE
	l_sty_used_in_pth_fee := 'Y';
     END IF;
     CLOSE fee_pth_csr;

     OPEN fee_non_pth_csr (p_sty_id);
     FETCH fee_non_pth_csr INTO l_fee_type;
     IF fee_non_pth_csr%NOTFOUND THEN
       l_sty_used_in_non_pth_fee  := 'N';
     ELSE
       l_sty_used_in_non_pth_fee  := 'Y';
     END IF;
     CLOSE fee_non_pth_csr;

     OPEN pth_service_csr (p_sty_id);
     FETCH pth_service_csr INTO l_dummy_id;
     IF pth_service_csr%NOTFOUND THEN
        l_sty_used_in_pth_service  := 'N';
     ELSE
        l_sty_used_in_pth_service  := 'Y';
     END IF;
     CLOSE pth_service_csr;

	IF l_sty_used_in_pth_fee = 'Y' AND
	   l_sty_used_in_non_pth_fee = 'N' AND
	   l_sty_used_in_pth_service = 'N' THEN
	   l_new_sty_purpose := 'PASS_THROUGH_FEE';
	ELSIF l_sty_used_in_pth_fee = 'N' AND
	   l_sty_used_in_non_pth_fee = 'Y' AND
	   l_sty_used_in_pth_service = 'N' THEN
	   l_new_sty_purpose := 'EXPENSE';
	ELSIF l_sty_used_in_pth_fee = 'N' AND
	   l_sty_used_in_non_pth_fee = 'N' AND
	   l_sty_used_in_pth_service = 'Y' THEN
	   l_new_sty_purpose := 'PASS_THROUGH_SERVICE';
	ELSIF l_sty_used_in_pth_fee = 'N' AND
	   l_sty_used_in_non_pth_fee  = 'N' AND
	   l_sty_used_in_pth_service = 'N' THEN
	   l_new_sty_purpose := NULL;
	ELSE
	   l_new_sty_purpose := 'GENERAL';
	END IF;

    x_sty_purpose := l_new_sty_purpose;

EXCEPTION
  WHEN OTHERS THEN
    Fnd_File.put_line(Fnd_File.LOG, SQLERRM);

END Migrate_Sty_Fee_Line;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate_Sty_Subsidy
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Migrate_Sty_Subsidy
  -- Description     : Procedure to migrate Subsidy stream types
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Migrate_Sty_Subsidy (p_sty_id 	NUMBER,
			       x_sty_purpose   	OUT NOCOPY VARCHAR2)
IS

l_dummy 	VARCHAR2(100);

-- Cursor to find if a stream type is used in Subsidy.

CURSOR subsidy_csr (l_sty_id NUMBER) IS
SELECT stream_type_class
FROM okl_strm_type_v
WHERE stream_type_class = 'SUBSIDY'
AND id = l_sty_id;

BEGIN

OPEN subsidy_csr (p_sty_id);
FETCH subsidy_csr INTO l_dummy;
IF subsidy_csr%FOUND THEN
    x_sty_purpose := 'SUBSIDY';
END IF;
CLOSE subsidy_csr;

EXCEPTION
  WHEN OTHERS THEN
    Fnd_File.put_line(Fnd_File.LOG, SQLERRM);

END Migrate_Sty_Subsidy;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate_Sty_Subsidy_Income
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Migrate_Sty_Subsidy_Income
  -- Description     : Procedure to migrate Subsidy Income stream types
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Migrate_Sty_Subsidy_Income(p_sty_id 		NUMBER,
				     x_sty_purpose 	OUT NOCOPY VARCHAR2)
IS

l_dummy 	VARCHAR2(100);

-- Cursor to find if a stream type is used in Subsidy.

CURSOR subsidy_inc_csr (l_sty_id NUMBER) IS
SELECT '1'
FROM okl_sgn_translations sgn
WHERE sgn.jtot_object1_code = 'OKL_STRMTYP'   AND
sgn.value = TO_CHAR(l_sty_id);

BEGIN

OPEN subsidy_inc_csr (p_sty_id);
FETCH subsidy_inc_csr INTO l_dummy;
IF subsidy_inc_csr%FOUND THEN
    x_sty_purpose := 'SUBSIDY_INCOME';
END IF;
CLOSE subsidy_inc_csr;

EXCEPTION
  WHEN OTHERS THEN
    Fnd_File.put_line(Fnd_File.LOG, SQLERRM);

END Migrate_Sty_Subsidy_Income;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate_Sty_Payments
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Migrate_Sty_Payments
  -- Description     : Procedure to migrate Payment stream types
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------


PROCEDURE Migrate_Sty_Payments (p_sty_id 	NUMBER,
				x_sty_purpose 	OUT NOCOPY VARCHAR2)
IS

l_sty_used_in_fee_pmt VARCHAR2(1);
l_sty_used_in_srv_pmt VARCHAR2(1);
l_dummy_id 	      NUMBER;
l_new_sty_purpose     VARCHAR2(100);

-- Cursor to find if a stream type is used in Fee Lines.

CURSOR srv_pmt_csr (l_sty_id NUMBER) IS
--Service Payments
SELECT rul.object1_id1 --strm_type_id,
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_lines_b     cleb,
       okc_line_styles_b lseb,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.cle_id = cleb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASLH'
AND    rgp.dnz_chr_id = chrb.id
AND    rul.dnz_chr_id = chrb.id
AND    rgp.rgd_code = 'LALEVL'
AND    cleb.lse_id = lseb.id
AND    lseb.lty_code = 'SOLD_SERVICE'
AND    cleb.chr_id = chrb.id
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND   rul.object1_id1 = l_sty_id
AND   pdt.deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING', 'SALE')
AND   pdt.tax_owner IN ('LESSOR', 'LESSEE')
UNION ALL
--Link Service Payments
SELECT rul.object1_id1 --strm_type_id,
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_lines_b     cleb,
       okc_line_styles_b lseb,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.cle_id = cleb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASLH'
AND    rgp.dnz_chr_id = chrb.id
AND    rul.dnz_chr_id = chrb.id
AND    rgp.rgd_code = 'LALEVL'
AND    cleb.lse_id = lseb.id
AND    lseb.lty_code = 'LINK_SERV_ASSET'
AND    cleb.dnz_chr_id = chrb.id
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND   rul.object1_id1 = l_sty_id
AND   pdt.deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING', 'SALE')
AND   pdt.tax_owner IN ('LESSOR', 'LESSEE');



CURSOR fee_pmt_csr (l_sty_id NUMBER) IS
--Fee Payments
SELECT rul.object1_id1 --strm_type_id,
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_lines_b     cleb,
       okc_line_styles_b lseb,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.cle_id = cleb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASLH'
AND    rgp.dnz_chr_id = chrb.id
AND    rul.dnz_chr_id = chrb.id
AND    rgp.rgd_code = 'LALEVL'
AND    cleb.lse_id = lseb.id
AND    lseb.lty_code = 'FEE'
AND    cleb.chr_id = chrb.id
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND   rul.object1_id1 = l_sty_id
AND   pdt.deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING', 'SALE')
AND   pdt.tax_owner IN ('LESSOR', 'LESSEE')
UNION ALL
--Link Fee Payments
SELECT rul.object1_id1 --strm_type_id,
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_lines_b     cleb,
       okc_line_styles_b lseb,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.cle_id = cleb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASLH'
AND    rgp.dnz_chr_id = chrb.id
AND    rul.dnz_chr_id = chrb.id
AND    rgp.rgd_code = 'LALEVL'
AND    cleb.lse_id = lseb.id
AND    lseb.lty_code = 'LINK_FEE_ASSET'
AND    cleb.dnz_chr_id = chrb.id
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND   rul.object1_id1 = l_sty_id
AND   pdt.deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING', 'SALE')
AND   pdt.tax_owner IN ('LESSOR', 'LESSEE')
UNION ALL
--Contract level payments
SELECT rul.object1_id1 --strm_type_id,
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.chr_id = chrb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASLH'
AND    rgp.dnz_chr_id = chrb.id
AND    rul.dnz_chr_id = chrb.id
AND    rgp.rgd_code = 'LALEVL'
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND   rul.object1_id1 = l_sty_id
AND   pdt.deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING', 'SALE')
AND   pdt.tax_owner IN ('LESSOR', 'LESSEE')
UNION ALL
--Asset level payments not RENT
SELECT rul.object1_id1 --strm_type_id,
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_lines_b     cleb,
       okc_line_styles_b lseb,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.cle_id = cleb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASLH'
AND    rgp.dnz_chr_id = chrb.id
AND    rul.dnz_chr_id = chrb.id
AND    rgp.rgd_code = 'LALEVL'
AND    cleb.lse_id = lseb.id
AND    lseb.lty_code = 'FREE_FORM1'
AND    cleb.chr_id = chrb.id
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND    rul.object1_id1 NOT IN (SELECT id FROM
okl_strm_type_b WHERE code = 'RENT')
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND   rul.object1_id1 = l_sty_id
AND   pdt.deal_type IN ('LEASEOP', 'LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING', 'SALE')
AND   pdt.tax_owner IN ('LESSOR', 'LESSEE');


BEGIN

     OPEN srv_pmt_csr (p_sty_id);
     FETCH srv_pmt_csr INTO l_dummy_id;
     IF srv_pmt_csr%NOTFOUND THEN
       l_sty_used_in_srv_pmt := 'N';
     ELSE
	l_sty_used_in_srv_pmt := 'Y';
     END IF;
     CLOSE srv_pmt_csr;

     OPEN fee_pmt_csr (p_sty_id);
     FETCH fee_pmt_csr INTO l_dummy_id;
     IF fee_pmt_csr%NOTFOUND THEN
       l_sty_used_in_fee_pmt := 'N';
     ELSE
	l_sty_used_in_fee_pmt := 'Y';
     END IF;
     CLOSE fee_pmt_csr;


	IF l_sty_used_in_srv_pmt = 'Y' AND
	   l_sty_used_in_fee_pmt = 'N' THEN
	   x_sty_purpose := 'SERVICE_PAYMENT';
	ELSIF l_sty_used_in_srv_pmt = 'N' AND
	   l_sty_used_in_fee_pmt = 'Y' THEN
	   x_sty_purpose := 'FEE_PAYMENT';
	ELSIF l_sty_used_in_srv_pmt = 'Y' AND
	   l_sty_used_in_fee_pmt = 'Y' THEN
	   x_sty_purpose := 'GENERAL';
	END IF;

EXCEPTION
  WHEN OTHERS THEN
    Fnd_File.put_line(Fnd_File.LOG, SQLERRM);

END Migrate_Sty_Payments;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate_Stream_Types
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Migrate_Stream_Types
  -- Description     : Procedure to migrate stream types
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Migrate_Stream_Types(x_return_status OUT NOCOPY VARCHAR2)
IS

-- Cursor to get all the stream types avilable in the system

CURSOR strm_type_csr  IS
SELECT
  id,
  name,
  code,
  stream_type_subclass,
  stream_type_purpose,
  start_date,
  stream_type_class
FROM
  okl_strm_type_v
WHERE
  short_description IS NULL;

l_new_sty_purpose VARCHAR2(100);
l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

BEGIN

   Fnd_File.put_line(Fnd_File.LOG,'Migrating Stream Types ');
   Fnd_File.put_line(Fnd_File.LOG,'-----------------------');

   FOR strm_type_rec IN strm_type_csr  LOOP
     l_new_sty_purpose := NULL;

     IF strm_type_rec.name = 'SECURITY DEPOSIT' THEN
       l_new_sty_purpose := 'SECURITY_DEPOSIT';

     ELSIF strm_type_rec.name = 'USAGE CHARGE' THEN
        l_new_sty_purpose := 'USAGE_PAYMENT';

     ELSE
     	IF strm_type_rec.stream_type_class = 'SUBSIDY' THEN
          Migrate_Sty_Subsidy (p_sty_id => strm_type_rec.id,
     			      x_sty_purpose => l_new_sty_purpose) ;

        ELSIF strm_type_rec.stream_type_class = 'EXPENSE' THEN
          Migrate_Sty_Fee_Line (p_sty_id => strm_type_rec.id,
     			      x_sty_purpose => l_new_sty_purpose);

        ELSIF strm_type_rec.stream_type_class = 'FEE' THEN
          Migrate_Sty_Payments (p_sty_id => strm_type_rec.id,
     			      x_sty_purpose => l_new_sty_purpose);

        ELSIF strm_type_rec.stream_type_class = 'ACCRUAL' THEN
	  Migrate_Sty_Subsidy_Income (p_sty_id => strm_type_rec.id,
     			      x_sty_purpose => l_new_sty_purpose) ;
        END IF;
     END IF;

     -- Update stream type with proper purpose
     IF  l_new_sty_purpose IS NOT NULL THEN
     	  Fnd_File.put_line(Fnd_File.LOG,'Updating Stream Type Purpose of Stream Type - ' || strm_type_rec.name || ' to - ' || l_new_sty_purpose);
          BEGIN
              UPDATE OKL_STRM_TYPE_B
              SET    STREAM_TYPE_PURPOSE =l_new_sty_purpose,
                     LAST_UPDATE_DATE = SYSDATE,
                     LAST_UPDATE_LOGIN = Fnd_Global.login_id
               WHERE ID = strm_type_rec.id;

             EXCEPTION
               WHEN OTHERS THEN
                 l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
                 Fnd_File.PUT_LINE(Fnd_File.LOG, SQLERRM);
             END;
     END IF;

     -- Update stream type if it has been upgraded

     Fnd_File.put_line(Fnd_File.LOG,'Updating Short Description of Stream Type - ' || strm_type_rec.name);

     BEGIN
       UPDATE OKL_STRM_TYPE_TL
       SET    SHORT_DESCRIPTION ='UPGRADED SUCCESSFULLY',
              LAST_UPDATE_DATE = SYSDATE,
              LAST_UPDATE_LOGIN = Fnd_Global.login_id
       WHERE ID = strm_type_rec.id
       AND   LANGUAGE = USERENV('LANG');

       EXCEPTION
         WHEN OTHERS THEN
          l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
          Fnd_File.PUT_LINE(Fnd_File.LOG, SQLERRM);
      END;

   END LOOP; -- End for strm_type_csr

   x_return_status := l_return_status;


EXCEPTION
  WHEN OTHERS THEN
    Fnd_File.put_line(Fnd_File.LOG, SQLERRM);
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END Migrate_Stream_Types;

  ---------------------------------------------------------------------------
  -- PROCEDURE Check_If_Used
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Check_If_Used
  -- Description     : Procedure to check if a stream type is used on a contract
  --   		       of a specific deal type
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

FUNCTION Check_If_Used (p_sty_id IN NUMBER,
		        p_book_class IN VARCHAR2,
			p_tax_owner IN VARCHAR2)
RETURN VARCHAR2

IS

CURSOR st_gen_tmpt_csr IS
SELECT
  'Y'
FROM
  okl_st_gen_tmpt_lns gtl,
  okl_st_gen_templates gtt,
  okl_st_gen_tmpt_sets gts
WHERE
  gtl.primary_sty_id = p_sty_id AND
  gtl.gtt_id = gtt.id AND
  gtt.gts_id = gts.id AND
  gts.name =  p_book_class || '-' || p_tax_owner;


CURSOR passthru_fee_csr IS
SELECT
  'Y'
FROM
  okc_k_items       cim,
  okl_k_lines kle,
  okc_k_lines_b     cleb,
  okc_line_styles_b lseb,
  okc_k_headers_b   chrb,
  okl_k_headers khr,
  okl_product_parameters_v pdt
WHERE
  cim.cle_id = cleb.id  AND
  cleb.lse_id = lseb.id  AND
  lseb.lty_code = 'FEE'  AND
  cleb.chr_id = chrb.id  AND
  kle.id = cleb.id  AND
  chrb.scs_code IN ('LEASE','QUOTE') AND
  kle.fee_type = 'PASSTHROUGH' AND
  chrb.id = khr.id AND
  khr.pdt_id = pdt.id AND
  cim.object1_id1 = p_sty_id AND
  pdt.DEAL_TYPE = p_book_class AND
  pdt.TAX_OWNER = p_tax_owner;


CURSOR fee_non_pth_csr  IS
SELECT
   'Y'
FROM
  okc_k_items       cim,
  okl_k_lines kle,
  okc_k_lines_b     cleb,
  okc_line_styles_b lseb,
  okc_k_headers_b   chrb,
  okl_k_headers khr,
  okl_product_parameters_v pdt
WHERE
  cim.cle_id = cleb.id  AND
  cleb.lse_id = lseb.id  AND
  lseb.lty_code = 'FEE'  AND
  cleb.chr_id = chrb.id  AND
  kle.id = cleb.id  AND
  chrb.scs_code IN ('LEASE','QUOTE') AND
  kle.fee_type <> 'PASSTHROUGH' AND
  chrb.id = khr.id AND
  khr.pdt_id = pdt.id AND
  cim.object1_id1 = p_sty_id AND
  pdt.DEAL_TYPE = p_book_class AND
  pdt.TAX_OWNER = p_tax_owner;



  -- Cursor to find if a stream type is used in Passthrough service

CURSOR pth_service_csr
IS
SELECT 'Y'
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_lines_b     cleb,
       okc_line_styles_b lseb,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.cle_id = cleb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASTRM'
AND    rgp.dnz_chr_id = chrb.id
AND rgp.rgd_code = 'LAPSTH'
AND    rul.dnz_chr_id = chrb.id
AND    cleb.lse_id = lseb.id
AND    lseb.lty_code = 'SOLD_SERVICE'
AND    cleb.chr_id = chrb.id
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND 	rul.object1_id1 = p_sty_id
AND    pdt.DEAL_TYPE = p_book_class
AND    pdt.TAX_OWNER = p_tax_owner;


CURSOR srv_pmt_csr  IS
--Service Payments
SELECT 'Y'
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_lines_b     cleb,
       okc_line_styles_b lseb,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.cle_id = cleb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASLH'
AND    rgp.dnz_chr_id = chrb.id
AND    rul.dnz_chr_id = chrb.id
AND    rgp.rgd_code = 'LALEVL'
AND    cleb.lse_id = lseb.id
AND    lseb.lty_code = 'SOLD_SERVICE'
AND    cleb.chr_id = chrb.id
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND   rul.object1_id1 = p_sty_id
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND    pdt.DEAL_TYPE = p_book_class
AND    pdt.TAX_OWNER = p_tax_owner
UNION ALL
--Link Service Payments
SELECT 'Y'
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_lines_b     cleb,
       okc_line_styles_b lseb,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.cle_id = cleb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASLH'
AND    rgp.dnz_chr_id = chrb.id
AND    rul.dnz_chr_id = chrb.id
AND    rgp.rgd_code = 'LALEVL'
AND    cleb.lse_id = lseb.id
AND    lseb.lty_code = 'LINK_SERV_ASSET'
AND    cleb.dnz_chr_id = chrb.id
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND   rul.object1_id1 = p_sty_id
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND    pdt.DEAL_TYPE = p_book_class
AND    pdt.TAX_OWNER = p_tax_owner;



CURSOR fee_pmt_csr  IS
--Fee Payments
SELECT 'Y'
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_lines_b     cleb,
       okc_line_styles_b lseb,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.cle_id = cleb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASLH'
AND    rgp.dnz_chr_id = chrb.id
AND    rul.dnz_chr_id = chrb.id
AND    rgp.rgd_code = 'LALEVL'
AND    cleb.lse_id = lseb.id
AND    lseb.lty_code = 'FEE'
AND    cleb.chr_id = chrb.id
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND   rul.object1_id1 = p_sty_id
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND    pdt.DEAL_TYPE = p_book_class
AND    pdt.TAX_OWNER = p_tax_owner
UNION ALL
--Link Fee Payments
SELECT 'Y'
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_lines_b     cleb,
       okc_line_styles_b lseb,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.cle_id = cleb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASLH'
AND    rgp.dnz_chr_id = chrb.id
AND    rul.dnz_chr_id = chrb.id
AND    rgp.rgd_code = 'LALEVL'
AND    cleb.lse_id = lseb.id
AND    lseb.lty_code = 'LINK_FEE_ASSET'
AND    cleb.dnz_chr_id = chrb.id
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND   rul.object1_id1 = p_sty_id
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND    pdt.DEAL_TYPE = p_book_class
AND    pdt.TAX_OWNER = p_tax_owner
UNION ALL
--Contract level payments
SELECT 'Y'
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.chr_id = chrb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASLH'
AND    rgp.dnz_chr_id = chrb.id
AND    rul.dnz_chr_id = chrb.id
AND    rgp.rgd_code = 'LALEVL'
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND   rul.object1_id1 = p_sty_id
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND    pdt.DEAL_TYPE = p_book_class
AND    pdt.TAX_OWNER = p_tax_owner
UNION ALL
--Asset level payments not RENT
SELECT 'Y'
FROM   okc_rules_b rul,
       okc_rule_groups_b       rgp,
       okc_k_lines_b     cleb,
       okc_line_styles_b lseb,
       okc_k_headers_b   chrb,
       okl_k_headers khr,
       okl_product_parameters_v pdt
WHERE  rgp.cle_id = cleb.id
AND    rul.rgp_id = rgp.id
AND    rul.rule_information_category = 'LASLH'
AND    rgp.dnz_chr_id = chrb.id
AND    rul.dnz_chr_id = chrb.id
AND    rgp.rgd_code = 'LALEVL'
AND    cleb.lse_id = lseb.id
AND    lseb.lty_code = 'FREE_FORM1'
AND    cleb.chr_id = chrb.id
AND    chrb.scs_code IN ('LEASE','QUOTE')
AND    rul.object1_id1 NOT IN (SELECT id FROM
okl_strm_type_b WHERE code = 'RENT')
AND   rul.object1_id1 = p_sty_id
AND    chrb.id = khr.id
AND    khr.pdt_id = pdt.id
AND    pdt.DEAL_TYPE = p_book_class
AND    pdt.TAX_OWNER = p_tax_owner;

CURSOR subsidy_csr IS
SELECT 'Y'
FROM okl_subsidies_v sub
WHERE sub.stream_type_id = p_sty_id;

l_sty_code VARCHAR2(100);
l_sty_added VARCHAR2(1) := 'N';

BEGIN

OPEN st_gen_tmpt_csr;
FETCH st_gen_tmpt_csr INTO l_sty_added;
CLOSE st_gen_tmpt_csr;

IF l_sty_added = 'Y' THEN
   RETURN G_FALSE;
ELSE

  OPEN passthru_fee_csr;
  FETCH passthru_fee_csr INTO l_sty_added;
  CLOSE passthru_fee_csr;

  IF l_sty_added = 'Y' THEN
     RETURN G_TRUE;
  END IF;

  OPEN fee_non_pth_csr;
  FETCH fee_non_pth_csr INTO l_sty_added;
  CLOSE fee_non_pth_csr;

  IF l_sty_added = 'Y' THEN
     RETURN G_TRUE;
  END IF;

  OPEN pth_service_csr;
  FETCH pth_service_csr INTO l_sty_added;
  CLOSE pth_service_csr;

  IF l_sty_added = 'Y' THEN
     RETURN G_TRUE;
  END IF;

  OPEN srv_pmt_csr;
  FETCH srv_pmt_csr INTO l_sty_added;
  CLOSE srv_pmt_csr;

  IF l_sty_added = 'Y' THEN
     RETURN G_TRUE;
  END IF;

  OPEN fee_pmt_csr;
  FETCH fee_pmt_csr INTO l_sty_added;
  CLOSE fee_pmt_csr;

  IF l_sty_added = 'Y' THEN
     RETURN G_TRUE;
  END IF;

  OPEN subsidy_csr;
  FETCH subsidy_csr INTO l_sty_added;
  CLOSE subsidy_csr;

  IF l_sty_added = 'Y' THEN
     RETURN G_TRUE;
  END IF;

  RETURN G_FALSE;

END IF;

EXCEPTION
  WHEN OTHERS THEN
    Fnd_File.put_line(Fnd_File.LOG, SQLERRM);
    RETURN G_FALSE;


END Check_If_Used;

  ---------------------------------------------------------------------------
  -- PROCEDURE Get_Pricing_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Get_Pricing_Name
  -- Description     : Function to return the pricing name for a stream type
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------


FUNCTION Get_Pricing_Name (p_sty_code IN VARCHAR2)
RETURN VARCHAR2

IS
l_pricing_name okl_st_gen_tmpt_lns.pricing_name%TYPE;
BEGIN

IF p_sty_code = 'PRE-TAX INCOME' THEN
   l_pricing_name := 'Single Rent Accrual';
ELSIF p_sty_code = 'INTEREST INCOME' THEN
   l_pricing_name := 'Single Lending Loan Accrual';
ELSIF p_sty_code = 'RENT' THEN
   l_pricing_name := 'Rent';
ELSIF p_sty_code = 'PRINCIPAL BALANCE' THEN
   l_pricing_name := 'Lending Loans Balance';
ELSIF p_sty_code = 'INTEREST PAYMENT' THEN
   l_pricing_name := 'Lending Loans Interest';
ELSIF p_sty_code = 'PRINCIPAL PAYMENT' THEN
   l_pricing_name := 'Lending Loans Principal';
ELSIF p_sty_code = 'RENTAL ACCRUAL' THEN
   l_pricing_name := 'Single Rent Accrual';
ELSIF p_sty_code = 'TERMINATION VALUE' THEN
   l_pricing_name := 'Termination Value';
ELSIF p_sty_code = 'STIP LOSS VALUE' THEN
   l_pricing_name := 'StipLoss Value';
ELSIF p_sty_code = 'BOOK DEPRECIATION' THEN
   l_pricing_name := 'Book Depreciation';
ELSIF p_sty_code = 'FEDERAL DEPRECIATION' THEN
   l_pricing_name := 'Federal Depreciation';
ELSIF p_sty_code = 'STATE DEPRECIATION' THEN
   l_pricing_name := 'State Depreciation';
ELSIF p_sty_code = 'LOAN PAYMENT' THEN
   l_pricing_name := 'Lending Loans Debt Service';
-- Santonyr Bug 4107753
ELSIF p_sty_code = 'SECURITY DEPOSIT' THEN
   l_pricing_name := 'Security Deposits';
ELSIF p_sty_code = 'UNSCHEDULED PRINCIPAL PAYMENT' THEN
   l_pricing_name := 'Principal Paydowns';
ELSE
   l_pricing_name := NULL;
END IF;

RETURN l_pricing_name;

EXCEPTION
  WHEN OTHERS THEN
    Fnd_File.put_line(Fnd_File.LOG, SQLERRM);
    RETURN NULL;

END Get_Pricing_Name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Get_dependent_sty
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Get_dependent_sty
  -- Description     : Procedure to get the dependent stream types for a primary
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------


PROCEDURE Get_dependent_sty (p_sty_id IN VARCHAR2,
			     p_book_class IN VARCHAR2,
			     x_dep_sty_tbl   OUT NOCOPY dep_sty_tbl)
IS

CURSOR primary_sty_csr IS
SELECT id, code, stream_type_purpose
FROM okl_strm_type_b
WHERE id = p_sty_id;

CURSOR act_prpty_tax_csr IS
SELECT ID, CODE , stream_type_purpose
FROM OKL_STRM_TYPE_V
WHERE CODE IN
('ADJUSTED PROPERTY TAX');

CURSOR est_prpty_tax_csr IS
SELECT ID, CODE , stream_type_purpose
FROM OKL_STRM_TYPE_V
WHERE CODE IN
('RENEWAL PROPERTY TAX');

CURSOR expense_csr IS
SELECT ID, CODE , stream_type_purpose
FROM OKL_STRM_TYPE_V
WHERE CODE IN
('ACCRUED FEE EXPENSE',
'AMORTIZED EXPENSE');

CURSOR fee_payment_csr IS
SELECT ID, CODE , stream_type_purpose
FROM OKL_STRM_TYPE_V
WHERE CODE IN
(
'FEE INCOME',
'AMORTIZED FEE INCOME',
'FEE RENEWAL',
'PASS THROUGH EXPENSE ACCRUAL',
'PASS THROUGH EVERGREEN FEE',
'LOAN PAYMENT',
'PRINCIPAL PAYMENT',
'INTEREST PAYMENT',
'PRINCIPAL BALANCE',
'INTEREST INCOME',
'PASS THROUGH REVENUE ACCRUAL');

CURSOR passthru_srv_csr IS
SELECT ID, CODE , stream_type_purpose
FROM OKL_STRM_TYPE_V
WHERE CODE IN
('PASS THROUGH SERVICE EXPENSE ACCRUAL');

CURSOR srv_payment_csr IS
SELECT ID, CODE , stream_type_purpose
FROM OKL_STRM_TYPE_V
WHERE CODE IN
('PASS THROUGH EVERGREEN SERVICE',
'PASS THROUGH SERVICE REVENUE ACCRUAL',
'SERVICE INCOME',
'SERVICE AND MAINTENANCE EVERGREEN');

CURSOR subsidy_csr IS
SELECT STY.ID, STY.CODE , STY.stream_type_purpose
FROM OKL_STRM_TYPE_V STY, okl_sgn_translations sgn
WHERE sgn.object1_id1 = TO_CHAR(p_sty_id)
AND sgn.value = TO_CHAR(sty.id);

l_dep_sty_tbl dep_sty_tbl;
l_sty_purpose OKL_STRM_TYPE_B.stream_type_purpose%TYPE;

j NUMBER := 0;

BEGIN


  FOR primary_sty_rec IN primary_sty_csr LOOP
    l_sty_purpose := primary_sty_rec.stream_type_purpose;
  END LOOP;

   IF l_sty_purpose = 'ACTUAL_PROPERTY_TAX' THEN

     FOR act_prpty_tax_rec IN act_prpty_tax_csr LOOP
	j := j + 1;
	l_dep_sty_tbl(j).sty_id := act_prpty_tax_rec.id;
 	l_dep_sty_tbl(j).sty_code := act_prpty_tax_rec.code;
	l_dep_sty_tbl(j).stream_type_purpose := act_prpty_tax_rec.stream_type_purpose;
     END LOOP;

  ELSIF l_sty_purpose = 'ESTIMATED_PROPERTY_TAX' THEN

     FOR est_prpty_tax_rec IN est_prpty_tax_csr LOOP
	j := j + 1;
	l_dep_sty_tbl(j).sty_id := est_prpty_tax_rec.id;
        l_dep_sty_tbl(j).sty_code := est_prpty_tax_rec.code;
	l_dep_sty_tbl(j).stream_type_purpose := est_prpty_tax_rec.stream_type_purpose;
     END LOOP;


  ELSIF l_sty_purpose = 'EXPENSE' THEN

     FOR expense_rec IN expense_csr LOOP
	j := j + 1;
	l_dep_sty_tbl(j).sty_id := expense_rec.id;
        l_dep_sty_tbl(j).sty_code := expense_rec.code;
	l_dep_sty_tbl(j).stream_type_purpose := expense_rec.stream_type_purpose;
     END LOOP;


  ELSIF l_sty_purpose = 'FEE_PAYMENT' THEN

     FOR fee_payment_rec IN fee_payment_csr LOOP
     	IF p_book_class = 'LOAN' AND fee_payment_rec.code = 'FEE RENEWAL' THEN
     	  NULL;
     	ELSE
	  j := j + 1;
	  l_dep_sty_tbl(j).sty_id := fee_payment_rec.id;
          l_dep_sty_tbl(j).sty_code := fee_payment_rec.code;
	  l_dep_sty_tbl(j).stream_type_purpose := fee_payment_rec.stream_type_purpose;
	END IF;
     END LOOP;


  ELSIF l_sty_purpose = 'PASS_THROUGH_SERVICE' THEN

     FOR passthru_srv_rec IN passthru_srv_csr LOOP
	j := j + 1;
	l_dep_sty_tbl(j).sty_id := passthru_srv_rec.id;
        l_dep_sty_tbl(j).sty_code := passthru_srv_rec.code;
	l_dep_sty_tbl(j).stream_type_purpose := passthru_srv_rec.stream_type_purpose;
     END LOOP;


  ELSIF l_sty_purpose = 'SERVICE_PAYMENT' THEN

     FOR srv_payment_rec IN srv_payment_csr LOOP
	j := j + 1;
	l_dep_sty_tbl(j).sty_id := srv_payment_rec.id;
        l_dep_sty_tbl(j).sty_code := srv_payment_rec.code;
	l_dep_sty_tbl(j).stream_type_purpose := srv_payment_rec.stream_type_purpose;
     END LOOP;

  ELSIF l_sty_purpose = 'SUBSIDY' THEN
---------------------------------------------------------------------
  -- Need to change the cursor
---------------------------------------------------------------------

     FOR subsidy_rec IN subsidy_csr LOOP
	j := j + 1;
	l_dep_sty_tbl(j).sty_id := subsidy_rec.id;
        l_dep_sty_tbl(j).sty_code := subsidy_rec.code;
	l_dep_sty_tbl(j).stream_type_purpose := subsidy_rec.stream_type_purpose;
     END LOOP;

  END IF;

  x_dep_sty_tbl := l_dep_sty_tbl;

EXCEPTION
  WHEN OTHERS THEN
    Fnd_File.put_line(Fnd_File.LOG, SQLERRM);

END Get_dependent_sty;


  ---------------------------------------------------------------------------
  -- PROCEDURE Get_Sty_Purpose_Prc_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Get_Sty_Purpose_Prc_Name
  -- Description     : Function to return the pricing name for a stream type purpose
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------


FUNCTION Get_Sty_Purpose_Prc_Name (p_sty_purpose IN VARCHAR2)
RETURN VARCHAR2

IS
l_pricing_name okl_st_gen_tmpt_lns.pricing_name%TYPE;
BEGIN

IF p_sty_purpose = 'FEE_PAYMENT' THEN
   l_pricing_name := 'Periodic Income';
ELSIF p_sty_purpose = 'SUBSIDY_INCOME' THEN
   l_pricing_name := 'Single Subsidy Accrual';
END IF;

RETURN l_pricing_name;

EXCEPTION
  WHEN OTHERS THEN
    Fnd_File.put_line(Fnd_File.LOG, SQLERRM);
    RETURN NULL;


END Get_Sty_Purpose_Prc_Name;


  ---------------------------------------------------------------------------
  -- PROCEDURE Get_Sty_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Get_Sty_Id
  -- Description     : Procedure to return sty_id for a sty code
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------


FUNCTION Get_Sty_Id (p_sty_code IN VARCHAR2,
		     p_sty_purpose IN VARCHAR2)
RETURN NUMBER
IS

CURSOR sty_id_csr IS
SELECT id
FROM okl_strm_type_b
WHERE code = p_sty_code
AND stream_type_purpose = p_sty_purpose;

l_sty_id NUMBER;

BEGIN

  OPEN sty_id_csr;
  FETCH sty_id_csr INTO l_sty_id;
  CLOSE sty_id_csr;

  RETURN l_sty_id;

END Get_Sty_Id;



  ---------------------------------------------------------------------------
  -- PROCEDURE Add_Mandatory
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Add_Mandatory
  -- Description     : Procedure to add the mandatory primary and dependent
  --   		       stream template lines to a stream template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------


PROCEDURE Add_Mandatory (p_book_class IN VARCHAR2,
			p_gttv_rec    IN gttv_rec_type,
		  	x_gtlv_tbl    OUT NOCOPY  gtlv_tbl_type)
IS

-- Cursor to fetch the mandatory stream type for a lease contract

CURSOR lease_primary_csr (l_gtt_id NUMBER) IS
SELECT id, code, stream_type_purpose FROM okl_strm_type_v
WHERE id NOT IN
(SELECT primary_sty_id FROM okl_st_gen_tmpt_lns WHERE gtt_id = l_gtt_id)
AND code IN (
'ASSET REPAIR CHARGE',
'BILLING ADJUSTMENT',
'BOOK DEPRECIATION',
'CURE',
'DOCUMENT REQUEST FEE - AMORTIZATION SCHEDULE',
'DOCUMENT REQUEST FEE - AUDIT LETTER',
'EQUIPMENT EXCHANGE REQUEST FEE',
'INTEREST RATE CONVERSION FEE',
'DOCUMENTS REQUEST FEE - INVOICE ON DEMAND',
'DOCUMENTS REQUEST FEE - INVOICE REPRINT',
'PAYMENT SETUP CHANGE FEES',
'RESTRUCTURE REQUEST FEE',
'TERMINATION REQUEST FEE',
'TRANSFER FEE',
'DOCUMENT REQUEST FEE - VARIABLE RATE STATEMENT',
'DOCUMENT REQUEST FEE - VAT SCHEDULE',
'SERVICE FEE - DOCUMENT REQUEST',
'SERVICE FEE',
'FEDERAL DEPRECIATION',
'FUNDING',
'INSURANCE ADJUSTMENT',
'INSURANCE ACCRUAL ADJUSTMENT',
'INSURANCE EXPENSE',
'INSURANCE INCOME',
'INSURANCE PAYABLE',
'INSURANCE RECEIVABLE',
'INSURANCE REFUND',
'INTEREST RATE CONVERSION FEE',
'INVESTOR PRE-TAX INCOME',
'INVESTOR RENTAL ACCRUAL',
'LATE FEE',
'LATE INTEREST',
'PRE-FUNDING',
'RENT',
'RESIDUAL VALUE',
'STATE DEPRECIATION',
'INTERIM INTEREST')
AND created_by = 1;


-- Cursor to fetch the mandatory stream type for a loan contract

CURSOR loan_csr (l_gtt_id NUMBER) IS
SELECT id, code, stream_type_purpose FROM okl_strm_type_v
WHERE id NOT IN
(SELECT primary_sty_id FROM okl_st_gen_tmpt_lns WHERE gtt_id = l_gtt_id)
AND code IN (
'BILLING ADJUSTMENT',
'CURE',
'FUNDING',
'INSURANCE ADJUSTMENT',
'INSURANCE ACCRUAL ADJUSTMENT',
'INSURANCE EXPENSE',
'INSURANCE INCOME',
'INSURANCE PAYABLE',
'INSURANCE RECEIVABLE',
'INSURANCE REFUND',
'LATE FEE',
'LATE INTEREST',
'PRE-FUNDING',
'VARIABLE INTEREST SCHEDULE',
'ASSET REPAIR CHARGE',
'DOCUMENT REQUEST FEE - AMORTIZATION SCHEDULE',
'DOCUMENT REQUEST FEE - AUDIT LETTER',
'EQUIPMENT EXCHANGE REQUEST FEE',
'INTEREST RATE CONVERSION FEE',
'DOCUMENTS REQUEST FEE - INVOICE ON DEMAND',
'DOCUMENTS REQUEST FEE - INVOICE REPRINT',
'PAYMENT SETUP CHANGE FEES',
'RESTRUCTURE REQUEST FEE',
'TERMINATION REQUEST FEE',
'TRANSFER FEE',
'DOCUMENT REQUEST FEE - VARIABLE RATE STATEMENT',
'DOCUMENT REQUEST FEE - VAT SCHEDULE',
'SERVICE FEE - DOCUMENT REQUEST',
'SERVICE FEE',
'RENT',
'VARIABLE INTEREST CHARGE',
'INTERIM INTEREST')
AND created_by = 1;

-- Cursor to fetch the mandatory stream type for a investor contract

CURSOR investor_csr (l_gtt_id NUMBER) IS
SELECT id, code FROM okl_strm_type_v
WHERE id NOT IN
(SELECT primary_sty_id FROM okl_st_gen_tmpt_lns WHERE gtt_id = l_gtt_id)
AND code IN (
'INVESTOR CONTRACT OBLIGATION PAYABLE',
'INVESTOR DISBURSEMENT ADJUSTMENT',
'INVESTOR EVERGREEN RENT PAYABLE',
'INVESTOR INTEREST PAYABLE',
'INVESTOR LATE FEE PAYABLE',
'INVESTOR LATE INTEREST PAYABLE',
'INVESTOR PAYABLE',
'INVESTOR PRINCIPAL PAYABLE',
'INVESTOR RECEIVABLE',
'INVESTOR RENT BUYBACK',
'INVESTOR RENT DISBURSEMENT BASIS',
'INVESTOR RENT PAYABLE',
'INVESTOR RESIDUAL BUYBACK',
'INVESTOR RESIDUAL DISBURSEMENT BASIS',
'INVESTOR RESIDUAL PAYABLE',
'PRESENT VALUE SECURITIZED RENT',
'PRESENT VALUE SECURITIZED RESIDUAL')
AND created_by = 1;

-- Cursor to fetch the dependent stream type for a leaseop  contract

CURSOR leaseop_dep_csr (l_gtt_id NUMBER) IS
SELECT id, code FROM okl_strm_type_v
WHERE id NOT IN
(SELECT dependent_sty_id FROM okl_st_gen_tmpt_lns WHERE gtt_id = l_gtt_id)
AND code IN (
'RENTAL ACCRUAL',
'ADVANCED RENTALS',
'PRESENT VALUE RENT',
'EVERGREEN RENT',
'PASS THROUGH RENEWAL RENT',
'STIP LOSS VALUE',
'TERMINATION VALUE',
'PRESENT VALUE RESIDUAL',
'GUARANTEED RESIDUAL THIRD PARTY',
--'GUARANTEED RESIDUAL INSURED',
--'PV GUARANTEE',
--'PV UNGUARANTEED RESIDUAL',
'PV GUARANTEED RESIDUAL',
'RESIDUAL VALUE INSURANCE PREMIUM',
'PRESENT VALUE UNINSURED RESIDUAL',
'PRESENT VALUE INSURED RESIDUAL',
'PRESENT VALUE UNGUARANTEED RESIDUAL')
AND created_by = 1;

-- Cursor to fetch the dependent stream type for a leasest/leasedf  contract

CURSOR leasedf_st_dep_csr (l_gtt_id NUMBER) IS
SELECT id, code FROM okl_strm_type_v
WHERE id NOT IN
(SELECT dependent_sty_id FROM okl_st_gen_tmpt_lns WHERE gtt_id = l_gtt_id)
AND code IN (
'ADVANCED RENTALS',
'PRESENT VALUE RENT',
'EVERGREEN RENT',
'STIP LOSS VALUE',
'TERMINATION VALUE',
'PRE-TAX INCOME',
'PASS THROUGH RENEWAL RENT',
'PRESENT VALUE RESIDUAL',
--'GUARANTEED RESIDUAL INSURED',
--'PV GUARANTEE',
--'PV UNGUARANTEED RESIDUAL',
'GUARANTEED RESIDUAL THIRD PARTY',
'PV GUARANTEED RESIDUAL',
'RESIDUAL VALUE INSURANCE PREMIUM',
'PRESENT VALUE INSURED RESIDUAL',
'PRESENT VALUE UNINSURED RESIDUAL',
'PRESENT VALUE UNGUARANTEED RESIDUAL')
AND created_by = 1;

-- Cursor to fetch the dependent stream type for a loan contract

CURSOR loan_dep_csr (l_gtt_id NUMBER) IS
SELECT id, code FROM okl_strm_type_v
WHERE id NOT IN
(SELECT dependent_sty_id FROM okl_st_gen_tmpt_lns WHERE gtt_id = l_gtt_id)
AND code IN (
'VARIABLE INCOME NON-ACCRUAL',
'VARIABLE INCOME ACCRUAL',
'ADVANCED RENTALS',
'PRINCIPAL CATCH UP',
'INTEREST INCOME',
'INTEREST PAYMENT',
'LOAN PAYMENT',
'UNSCHEDULED PRINCIPAL PAYMENT',
'PRINCIPAL BALANCE',
'PRINCIPAL PAYMENT')
AND created_by = 1;

l_gtlv_tbl 	gtlv_tbl_type;
l_rent_sty_id 	NUMBER;
l_rv_sty_id 	NUMBER;
l_variable_sty_id NUMBER;
j 		NUMBER := 0;


BEGIN

j := 0;

-- Add mandatory stream type for a lease contract

IF p_book_class IN ('LEASEOP', 'LEASEDF', 'LEASEST') THEN
  FOR lease_primary_rec IN lease_primary_csr (p_gttv_rec.id) LOOP
    IF lease_primary_rec.code = 'RENT' THEN
       l_rent_sty_id := lease_primary_rec.id;
    ELSIF lease_primary_rec.code ='RESIDUAL VALUE'  THEN
       l_rv_sty_id := lease_primary_rec.id;
    END IF;

    j := j +1;

    IF lease_primary_rec.code = 'DOCUMENT REQUEST FEE - AMORTIZATION SCHEDULE' AND
       lease_primary_rec.stream_type_purpose <> 'SERVICE_FEE_AMORT_SCHEDULE' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - AMORTIZATION SCHEDULE', 'SERVICE_FEE_AMORT_SCHEDULE');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF lease_primary_rec.code = 'DOCUMENT REQUEST FEE - AUDIT LETTER' AND
      lease_primary_rec.stream_type_purpose <> 'SERVICE_FEE_AUDIT_LETTER' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - AUDIT LETTER', 'SERVICE_FEE_AUDIT_LETTER');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF lease_primary_rec.code = 'EQUIPMENT EXCHANGE REQUEST FEE' AND
      lease_primary_rec.stream_type_purpose <> 'SERVICE_FEE_EXCHG_REQUEST' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - EXCHANGE REQUEST', 'SERVICE_FEE_EXCHG_REQUEST');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF lease_primary_rec.code = 'SERVICE FEE' AND
      lease_primary_rec.stream_type_purpose <> 'SERVICE_FEE_GENERAL' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - GENERAL', 'SERVICE_FEE_GENERAL');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF lease_primary_rec.code = 'INTEREST RATE CONVERSION FEE' AND
      lease_primary_rec.stream_type_purpose <> 'SERVICE_FEE_INTEREST_CONV' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - INTEREST CONVERSION', 'SERVICE_FEE_INTEREST_CONV');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF lease_primary_rec.code = 'DOCUMENTS REQUEST FEE - INVOICE ON DEMAND' AND
      lease_primary_rec.stream_type_purpose <> 'SERVICE_FEE_INVOICE_DEMAND' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - INVOICE ON DEMAND', 'SERVICE_FEE_INVOICE_DEMAND');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF lease_primary_rec.code = 'DOCUMENTS REQUEST FEE - INVOICE REPRINT' AND
      lease_primary_rec.stream_type_purpose <> 'SERVICE_FEE_INVOICE_REPRINT' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - INVOICE REPRINT', 'SERVICE_FEE_INVOICE_REPRINT');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF lease_primary_rec.code = 'PAYMENT SETUP CHANGE FEES' AND
      lease_primary_rec.stream_type_purpose <> 'SERVICE_FEE_PMT_CHANGE' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - PAYMENT CHANGE', 'SERVICE_FEE_PMT_CHANGE');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF lease_primary_rec.code = 'RESTRUCTURE REQUEST FEE' AND
      lease_primary_rec.stream_type_purpose <> 'SERVICE_FEE_REST_REQUEST' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - RESTRUCTURE REQUEST', 'SERVICE_FEE_REST_REQUEST');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF lease_primary_rec.code = 'TERMINATION REQUEST FEE' AND
      lease_primary_rec.stream_type_purpose <> 'SERVICE_FEE_TERM_REQUEST' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - TERMINATION REQUEST', 'SERVICE_FEE_TERM_REQUEST');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF lease_primary_rec.code = 'TRANSFER FEE' AND
      lease_primary_rec.stream_type_purpose <> 'SERVICE_FEE_TRANS_REQUEST' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - TRANSFER REQUEST', 'SERVICE_FEE_TRANS_REQUEST');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF lease_primary_rec.code = 'DOCUMENT REQUEST FEE - VARIABLE RATE STATEMENT' AND
      lease_primary_rec.stream_type_purpose <> 'SERVICE_FEE_VAR_RATE_STMNT' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - VARIABLE RATE STATEMENT', 'SERVICE_FEE_VAR_RATE_STMNT');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF lease_primary_rec.code = 'DOCUMENT REQUEST FEE - VAT SCHEDULE' AND
      lease_primary_rec.stream_type_purpose <> 'SERVICE_FEE_VAT_SCHEDULE' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - VAT SCHEDULE', 'SERVICE_FEE_VAT_SCHEDULE');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSE
      l_gtlv_tbl(j).primary_sty_id        := lease_primary_rec.id;
      l_gtlv_tbl(j).pricing_name          := Get_Pricing_Name(lease_primary_rec.code);
    END IF;

    l_gtlv_tbl(j).object_version_number := 1;
    l_gtlv_tbl(j).primary_yn            := 'Y';
    l_gtlv_tbl(j).dependent_sty_id      := NULL;
    l_gtlv_tbl(j).gtt_id          := p_gttv_rec.id;

  END LOOP; -- End for lease_primary_rec

-- Add mandatory stream type for a loan contract

ELSIF p_book_class IN ('LOAN', 'LOAN-REVOLVING') THEN
  FOR loan_rec IN loan_csr (p_gttv_rec.id) LOOP
    IF loan_rec.code = 'RENT' THEN
      l_rent_sty_id := loan_rec.id;
    ELSIF loan_rec.code ='VARIABLE INTEREST CHARGE'  THEN
      l_variable_sty_id := loan_rec.id;
    END IF;

    j := j +1;

    IF loan_rec.code = 'DOCUMENT REQUEST FEE - AMORTIZATION SCHEDULE' AND
       loan_rec.stream_type_purpose <> 'SERVICE_FEE_AMORT_SCHEDULE' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - AMORTIZATION SCHEDULE', 'SERVICE_FEE_AMORT_SCHEDULE');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF loan_rec.code = 'DOCUMENT REQUEST FEE - AUDIT LETTER' AND
      loan_rec.stream_type_purpose <> 'SERVICE_FEE_AUDIT_LETTER' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - AUDIT LETTER', 'SERVICE_FEE_AUDIT_LETTER');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF loan_rec.code = 'EQUIPMENT EXCHANGE REQUEST FEE' AND
      loan_rec.stream_type_purpose <> 'SERVICE_FEE_EXCHG_REQUEST' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - EXCHANGE REQUEST', 'SERVICE_FEE_EXCHG_REQUEST');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF loan_rec.code = 'SERVICE FEE' AND
      loan_rec.stream_type_purpose <> 'SERVICE_FEE_GENERAL' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - GENERAL', 'SERVICE_FEE_GENERAL');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF loan_rec.code = 'INTEREST RATE CONVERSION FEE' AND
      loan_rec.stream_type_purpose <> 'SERVICE_FEE_INTEREST_CONV' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - INTEREST CONVERSION', 'SERVICE_FEE_INTEREST_CONV');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF loan_rec.code = 'DOCUMENTS REQUEST FEE - INVOICE ON DEMAND' AND
      loan_rec.stream_type_purpose <> 'SERVICE_FEE_INVOICE_DEMAND' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - INVOICE ON DEMAND', 'SERVICE_FEE_INVOICE_DEMAND');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF loan_rec.code = 'DOCUMENTS REQUEST FEE - INVOICE REPRINT' AND
      loan_rec.stream_type_purpose <> 'SERVICE_FEE_INVOICE_REPRINT' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - INVOICE REPRINT', 'SERVICE_FEE_INVOICE_REPRINT');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF loan_rec.code = 'PAYMENT SETUP CHANGE FEES' AND
      loan_rec.stream_type_purpose <> 'SERVICE_FEE_PMT_CHANGE' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - PAYMENT CHANGE', 'SERVICE_FEE_PMT_CHANGE');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF loan_rec.code = 'RESTRUCTURE REQUEST FEE' AND
      loan_rec.stream_type_purpose <> 'SERVICE_FEE_REST_REQUEST' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - RESTRUCTURE REQUEST', 'SERVICE_FEE_REST_REQUEST');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF loan_rec.code = 'TERMINATION REQUEST FEE' AND
      loan_rec.stream_type_purpose <> 'SERVICE_FEE_TERM_REQUEST' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - TERMINATION REQUEST', 'SERVICE_FEE_TERM_REQUEST');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF loan_rec.code = 'TRANSFER FEE' AND
      loan_rec.stream_type_purpose <> 'SERVICE_FEE_TRANS_REQUEST' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - TRANSFER REQUEST', 'SERVICE_FEE_TRANS_REQUEST');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF loan_rec.code = 'DOCUMENT REQUEST FEE - VARIABLE RATE STATEMENT' AND
      loan_rec.stream_type_purpose <> 'SERVICE_FEE_VAR_RATE_STMNT' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - VARIABLE RATE STATEMENT', 'SERVICE_FEE_VAR_RATE_STMNT');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSIF loan_rec.code = 'DOCUMENT REQUEST FEE - VAT SCHEDULE' AND
      loan_rec.stream_type_purpose <> 'SERVICE_FEE_VAT_SCHEDULE' THEN
         l_gtlv_tbl(j).primary_sty_id := Get_Sty_Id('SERVICE FEE - VAT SCHEDULE', 'SERVICE_FEE_VAT_SCHEDULE');
         l_gtlv_tbl(j).pricing_name          := NULL;
    ELSE
      l_gtlv_tbl(j).primary_sty_id        := loan_rec.id;
      l_gtlv_tbl(j).pricing_name          := Get_Pricing_Name(loan_rec.code);
    END IF;

    l_gtlv_tbl(j).object_version_number := 1;
    l_gtlv_tbl(j).primary_yn            := 'Y';
    l_gtlv_tbl(j).dependent_sty_id      := NULL;
    l_gtlv_tbl(j).gtt_id          := p_gttv_rec.id;
  END LOOP; -- End for lease_primary_rec

-- Add mandatory stream type for a investor contract

ELSIF p_book_class IN ('SALE') THEN
  FOR investor_rec IN investor_csr (p_gttv_rec.id) LOOP

    j := j +1;
    l_gtlv_tbl(j).object_version_number := 1;
    l_gtlv_tbl(j).primary_yn            := 'Y';
    l_gtlv_tbl(j).primary_sty_id        := investor_rec.id;
    l_gtlv_tbl(j).dependent_sty_id      := NULL;
    l_gtlv_tbl(j).pricing_name          := NULL;
    l_gtlv_tbl(j).gtt_id          := p_gttv_rec.id;
  END LOOP; -- End for lease_primary_rec
END IF; -- For book class


-- Add dependent stream type for a leaseop contract

IF p_book_class IN ('LEASEOP') THEN
 FOR leaseop_dep_rec IN leaseop_dep_csr (p_gttv_rec.id)LOOP
    j := j +1;
    IF leaseop_dep_rec.code IN ('RENTAL ACCRUAL', 'ADVANCED RENTALS',
	   			'PRESENT VALUE RENT', 'EVERGREEN RENT',
				'STIP LOSS VALUE', 'TERMINATION VALUE',
				'PASS THROUGH RENEWAL RENT') THEN
       l_gtlv_tbl(j).primary_sty_id        := l_rent_sty_id;

    ELSIF leaseop_dep_rec.code IN  ('PRESENT VALUE RESIDUAL',
		  		'GUARANTEED RESIDUAL INSURED',
		  		'GUARANTEED RESIDUAL THIRD PARTY',
		  		'PV GUARANTEE',
		  		'PV GUARANTEED RESIDUAL',
				'RESIDUAL VALUE INSURANCE PREMIUM',
		  		'PRESENT VALUE INSURED RESIDUAL',
				'PRESENT VALUE UNINSURED RESIDUAL',
		  		'PRESENT VALUE UNGUARANTEED RESIDUAL',
		  		'PV UNGUARANTEED RESIDUAL') THEN
      l_gtlv_tbl(j).primary_sty_id        := l_rv_sty_id;
    END IF;


    l_gtlv_tbl(j).object_version_number := 1;
    l_gtlv_tbl(j).primary_yn            := 'N';
    l_gtlv_tbl(j).dependent_sty_id      := leaseop_dep_rec.id;
    l_gtlv_tbl(j).pricing_name          := Get_Pricing_Name(leaseop_dep_rec.code);
    l_gtlv_tbl(j).gtt_id          := p_gttv_rec.id;
  END LOOP; -- End for leaseop_rec

-- Add dependent stream type for a leasest/leasedf contract

ELSIF p_book_class IN ('LEASEDF', 'LEASEST') THEN
  FOR leasedf_st_dep_rec IN leasedf_st_dep_csr (p_gttv_rec.id)LOOP
    j := j +1;
    IF leasedf_st_dep_rec.code IN ('ADVANCED RENTALS',
				   'PRESENT VALUE RENT',
				   'EVERGREEN RENT',
				   'STIP LOSS VALUE',
				   'TERMINATION VALUE',
				   'PASS THROUGH RENEWAL RENT',
				   'PRE-TAX INCOME') THEN
        l_gtlv_tbl(j).primary_sty_id        := l_rent_sty_id;

    ELSIF leasedf_st_dep_rec.code IN  ('PRESENT VALUE RESIDUAL',
  					   'GUARANTEED RESIDUAL INSURED',
					   'GUARANTEED RESIDUAL THIRD PARTY',
					   'PV GUARANTEE',
					   'PV GUARANTEED RESIDUAL',
					   'RESIDUAL VALUE INSURANCE PREMIUM',
					   'PRESENT VALUE INSURED RESIDUAL',
					   'PRESENT VALUE UNINSURED RESIDUAL',
					   'PRESENT VALUE UNGUARANTEED RESIDUAL',
					   'PV UNGUARANTEED RESIDUAL') THEN
        l_gtlv_tbl(j).primary_sty_id        := l_rv_sty_id;
    END IF;

    l_gtlv_tbl(j).object_version_number := 1;
    l_gtlv_tbl(j).primary_yn            := 'N';
    l_gtlv_tbl(j).dependent_sty_id      := leasedf_st_dep_rec.id;
    l_gtlv_tbl(j).pricing_name          := Get_Pricing_Name(leasedf_st_dep_rec.code);
    l_gtlv_tbl(j).gtt_id          := p_gttv_rec.id;
  END LOOP; -- End for leaseop_rec

-- Add dependent stream type for a loan contract

ELSIF p_book_class IN ('LOAN', 'LOAN-REVOLVING') THEN
 FOR loan_dep_rec IN loan_dep_csr (p_gttv_rec.id)LOOP

    j := j +1;
    IF loan_dep_rec.code IN ('ADVANCED RENTALS',
				   'PRINCIPAL CATCH UP',
				   'INTEREST INCOME',
				   'INTEREST PAYMENT',
				   'UNSCHEDULED PRINCIPAL PAYMENT',
				   'INTERIM INTEREST',
				   'LOAN PAYMENT',
				   'PRINCIPAL BALANCE',
				   'PRINCIPAL PAYMENT') THEN
        l_gtlv_tbl(j).primary_sty_id        := l_rent_sty_id;

     ELSIF loan_dep_rec.code IN  ('VARIABLE INCOME NON-ACCRUAL',
					   'VARIABLE INCOME ACCRUAL') THEN
        l_gtlv_tbl(j).primary_sty_id        := l_variable_sty_id;
     END IF;
     l_gtlv_tbl(j).object_version_number := 1;
     l_gtlv_tbl(j).primary_yn            := 'N';
     l_gtlv_tbl(j).dependent_sty_id      := loan_dep_rec.id;
     l_gtlv_tbl(j).pricing_name          := Get_Pricing_Name(loan_dep_rec.code);
     l_gtlv_tbl(j).gtt_id          := p_gttv_rec.id;
  END LOOP; -- End for leaseop_rec

END IF; -- End If for book class

x_gtlv_tbl := l_gtlv_tbl;

EXCEPTION
  WHEN OTHERS THEN
    Fnd_File.put_line(Fnd_File.LOG, SQLERRM);

END Add_Mandatory;


  ---------------------------------------------------------------------------
  -- PROCEDURE Add_Used_Stream_Types
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Add_Used_Stream_Types
  -- Description     : Procedure to identify the used stream types for a contract
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------


PROCEDURE Add_Used_Stream_Types (p_book_class 	IN VARCHAR2,
  				 p_tax_owner 	IN VARCHAR2,
  				 p_gttv_rec    	IN gttv_rec_type,
		  		 x_gtlv_tbl    	OUT NOCOPY  gtlv_tbl_type)
IS

CURSOR strm_type_csr  IS
SELECT
  id,
  name,
  code,
  stream_type_subclass,
  stream_type_purpose,
  start_date,
  stream_type_class
FROM
  okl_strm_type_v;

l_gtlv_tbl 	gtlv_tbl_type;
l_rent_sty_id 	NUMBER;
l_rv_sty_id 	NUMBER;
l_variable_sty_id NUMBER;
j 		NUMBER := 0;

l_sty_used 		VARCHAR2(1) := G_FALSE;
l_primary_yn 		okl_st_gen_tmpt_lns.primary_yn%TYPE;
l_primary_sty_id 	okl_st_gen_tmpt_lns.primary_sty_id%TYPE;
l_dependent_sty_id 	okl_st_gen_tmpt_lns.dependent_sty_id%TYPE;
l_pricing_name 		okl_st_gen_tmpt_lns.pricing_name%TYPE;
l_dep_sty_tbl 		dep_sty_tbl;

BEGIN

     FOR strm_type_rec IN strm_type_csr LOOP

      l_sty_used := Check_If_Used(p_sty_id => strm_type_rec.id,
	  			  p_book_class =>  p_book_class,
				  p_tax_owner => p_tax_owner);

      IF l_sty_used = G_TRUE THEN

        j := j+1;
--        Fnd_File.put_line(Fnd_File.LOG,'Populating the Stream Template Line - '  || strm_type_rec.id  || ' from Check If Used' );
        l_gtlv_tbl(j).object_version_number := 1;
        l_gtlv_tbl(j).primary_yn            := 'Y';
        l_gtlv_tbl(j).primary_sty_id        := strm_type_rec.id;
        l_gtlv_tbl(j).dependent_sty_id      := NULL;
        l_gtlv_tbl(j).gtt_id          	    := p_gttv_rec.id;


	IF strm_type_rec.stream_type_purpose = 'FEE_PAYMENT'  THEN
  	  l_gtlv_tbl(j).pricing_name          := 'Periodic Income';
	ELSE
     	  l_gtlv_tbl(j).pricing_name          := Get_Pricing_Name(strm_type_rec.code);
	END IF;

	l_dep_sty_tbl.DELETE;
	Get_dependent_Sty(strm_type_rec.id, p_book_class, l_dep_sty_tbl);

	IF l_dep_sty_tbl.COUNT > 0 THEN
	  FOR i IN l_dep_sty_tbl.first..l_dep_sty_tbl.last LOOP
            j:= j+1;
            l_gtlv_tbl(j).object_version_number := 1;
            l_gtlv_tbl(j).primary_yn            := 'N';
            l_gtlv_tbl(j).primary_sty_id        := strm_type_rec.id;
            l_gtlv_tbl(j).dependent_sty_id      := l_dep_sty_tbl(i).sty_id;
            l_gtlv_tbl(j).gtt_id          	:= p_gttv_rec.id;

 	    IF l_dep_sty_tbl(i).stream_type_purpose = 'SUBSIDY_INCOME' THEN
   	       l_gtlv_tbl(j).pricing_name          := 'Single Subsidy Accrual';
 	    ELSE
               l_gtlv_tbl(j).pricing_name          := Get_Pricing_Name(l_dep_sty_tbl(i).sty_code);
 	    END IF;

          END LOOP;
	END IF;

      END IF;

     END LOOP; -- End for strm_type_csr

     x_gtlv_tbl := l_gtlv_tbl;

EXCEPTION
  WHEN OTHERS THEN
    Fnd_File.put_line(Fnd_File.LOG, SQLERRM);

END Add_Used_Stream_Types;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate_Streams_Process
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Migrate_Streams_Process
  -- Description     : Migrate Streams Process
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------


PROCEDURE Migrate_Streams_Process(p_stream_generator IN   VARCHAR2)
IS

l_gttv_rec gttv_rec_type;
l_gtsv_rec gtsv_rec_type;
l_gtlv_rec gtlv_rec_type;
l_gtpv_rec gtpv_rec_type;

l_gttv_tbl gttv_tbl_type;
l_gtsv_tbl gtsv_tbl_type;
l_gtlv_tbl gtlv_tbl_type;
l_gtpv_tbl gtpv_tbl_type;

x_gttv_rec gttv_rec_type;
x_gtsv_rec gtsv_rec_type;
x_gtlv_rec gtlv_rec_type;
x_gtpv_rec gtpv_rec_type;

x_gttv_tbl gttv_tbl_type;
x_gtsv_tbl gtsv_tbl_type;
x_gtlv_tbl gtlv_tbl_type;
x_gtpv_tbl gtpv_tbl_type;

l_error_msg_rec     Okl_Accounting_Util.ERROR_MESSAGE_TYPE;
l_error_msgs_tbl    error_msgs_tbl_type;

l_gts_id  OKL_ST_GEN_TMPT_SETS.id%TYPE;
l_gts_name  OKL_ST_GEN_TMPT_SETS.name%TYPE;
l_gtt_id  OKL_ST_GEN_TEMPLATES.id%TYPE;
l_gtt_status  OKL_ST_GEN_TEMPLATES.tmpt_status%TYPE;
l_gtt_out_status OKL_ST_GEN_TEMPLATES.tmpt_status%TYPE;
l_gts_found  VARCHAR2(1);

l_api_version    NUMBER DEFAULT 1.0;
l_init_msg_list  VARCHAR2(1) DEFAULT Okl_Api.g_false;
x_return_status  VARCHAR2(1) := Okl_Api.g_ret_sts_success;
x_msg_count      NUMBER;
x_msg_data       VARCHAR2(2000);

l_sty_migrated    VARCHAR2(1) := G_FALSE;
l_api_name       CONSTANT VARCHAR2(40) := 'migrate_stream_process';

-- Cursor to select all existing products and its values

CURSOR bc_to_csr IS
SELECT
DISTINCT
  q1.value deal_type,
  q2.value tax_owner
FROM
  okl_products_v p,
  okl_pdt_pqy_vals_uv q1,
  okl_pdt_pqy_vals_uv q2
WHERE
  p.id = q1.pdt_id AND q1.name = 'LEASE'  AND q1.value IS NOT NULL AND
  p.id = q2.pdt_id AND q2.name = 'TAXOWNER' AND q2.value IS NOT NULL
UNION
SELECT
 DISTINCT
  q1.value deal_type,
  'LESSEE' tax_owner
FROM
  okl_products_v p,
  okl_pdt_pqy_vals_uv q1
WHERE
  p.id = q1.pdt_id AND q1.name = 'INVESTOR' AND q1.value IS NOT NULL;


-- Cursor to get all the stream templates for the unique combination
-- of deal type and tax owner.

CURSOR st_tmpt_csr (l_name VARCHAR2) IS
SELECT
    gts.id gts_id,
    gts.name,
    gtt.id gtt_id,
    gtt.tmpt_status
FROM
    OKL_ST_GEN_TMPT_SETS gts,
    OKL_ST_GEN_TEMPLATES gtt
WHERE
    gts.id = gtt.gts_id     AND
    gts.name = l_name;

-- Cursor to get all the stream types avilable in the system

CURSOR strm_type_csr  IS
SELECT
  id,
  name,
  code,
  stream_type_subclass,
  stream_type_purpose,
  start_date,
  stream_type_class
FROM
  okl_strm_type_v;

-- Cursor to find out if the stream types have been migrated or not.

CURSOR sty_mig_csr IS
SELECT '1'
FROM OKL_STRM_TYPE_V STY
WHERE STY.SHORT_DESCRIPTION <> 'UPGRADED SUCCESSFULLY';

-- Cusrsor to get the distinct operating units in the system

CURSOR org_csr (l_deal_type IN VARCHAR2, l_tax_owner IN VARCHAR2) IS
SELECT
   DISTINCT aes.org_id
FROM
  okl_products_v p,
  okl_ae_tmpt_sets aes,
  okl_pdt_pqy_vals_uv q1,
  okl_pdt_pqy_vals_uv q2
WHERE
  p.aes_id = aes.id AND
  p.id = q1.pdt_id AND q1.name = 'LEASE'  AND q1.value = l_deal_type AND
  p.id = q2.pdt_id AND q2.name = 'TAXOWNER' AND q2.value = l_tax_owner
UNION
SELECT
   DISTINCT aes.org_id
FROM
  okl_products_v p,
  okl_pdt_pqy_vals_uv q1,
  okl_ae_tmpt_sets aes
WHERE
  p.aes_id = aes.id AND
  p.id = q1.pdt_id AND q1.name = 'INVESTOR'  AND q1.value = l_deal_type;


-- Cursor to fetch the organization namd for a org id.

CURSOR org_name_csr (l_org_id IN NUMBER) IS
SELECT name
FROM   hr_operating_units
WHERE  organization_id = l_org_id;


CURSOR gtt_start_date_csr IS
SELECT MIN(aes.start_date)
FROM   okl_ae_tmpt_sets aes;

j NUMBER;
l_new_gts_name VARCHAR2(100);
l_org_name    VARCHAR2(150);

BEGIN
  x_return_status := Okl_Api.START_ACTIVITY (
                                l_api_name
                               ,l_init_msg_list
                               ,'_PVT'
                               ,x_return_status);

  -- Check if activity started successfully
  IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    Fnd_File.PUT_LINE(Fnd_File.LOG, 'Error at start activity' );
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    Fnd_File.PUT_LINE(Fnd_File.LOG, 'Error at start activity' );
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  -- Check if stream types are migrated
  OPEN sty_mig_csr;
  FETCH sty_mig_csr INTO l_sty_migrated;
  CLOSE sty_mig_csr;

  IF l_sty_migrated IS NOT NULL
  THEN
     Fnd_File.put_line(Fnd_File.LOG,'Updating the Stream Types with stream type purposes based on its usage...');
     -- If stream types are not migrated, migrate the stream types.
     Migrate_Stream_Types(x_return_status);
     IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR)
     THEN
       Fnd_File.PUT_LINE(Fnd_File.LOG, 'The following errors occured while upgrading the stream types.' );
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       Fnd_File.PUT_LINE(Fnd_File.LOG, 'The following errors occured while upgrading the stream types.' );
       RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;
  ELSE
     Fnd_File.put_line(Fnd_File.LOG,'Stream Types have been migrated... ');
  END IF;
  -- Loop through the unique combination of book class and tax owner.
  FOR bc_to_rec IN bc_to_csr
  LOOP
    -- Loop through operating unit.
    FOR org_rec IN org_csr (bc_to_rec.deal_type, bc_to_rec.tax_owner)
    LOOP
      mo_global.set_policy_context('S',org_rec.org_id);  --dkagrawa changed for MOAC
      Fnd_File.put_line(Fnd_File.LOG,' ');
      --   Fnd_File.put_line(Fnd_File.LOG,'Creating Stream Templates for the combination of Deal Type - ' || bc_to_rec.deal_type || ', Tax Owner  - ' || bc_to_rec.tax_owner || ', Org Id - ' || org_rec.org_id);
      FOR org_name_rec IN org_name_csr (org_rec.org_id) LOOP
        l_org_name := org_name_rec.name;
      END LOOP;
      Fnd_File.put_line(Fnd_File.LOG,'Operating Unit : ' || l_org_name);
      Fnd_File.put_line(Fnd_File.LOG,'Creating Stream Templates for the combination of Deal Type - ' || bc_to_rec.deal_type || ', Tax Owner  - ' || bc_to_rec.tax_owner );
      --     Fnd_File.put_line(Fnd_File.LOG,'Setting Org id to ' || org_rec.org_id);
      -- Check if stream templates are available for for the combination of
      -- deal type and tax owner.
      IF bc_to_rec.deal_type = 'SALE'
      THEN
        l_new_gts_name := bc_to_rec.deal_type || '-'|| 'LESSEE';
      ELSE
        l_new_gts_name := bc_to_rec.deal_type || '-'|| bc_to_rec.tax_owner;
      END IF;
      OPEN  st_tmpt_csr (l_new_gts_name);
      FETCH st_tmpt_csr INTO  l_gts_id, l_gts_name, l_gtt_id, l_gtt_status;
      IF st_tmpt_csr%NOTFOUND THEN
        l_gts_found := 'N';
      ELSE
        l_gts_found := 'Y';
      END IF;
      CLOSE st_tmpt_csr;
      -- If stream template is found
      IF l_gts_found = 'Y'
      THEN
        Fnd_File.put_line(Fnd_File.LOG, l_gtt_status  ||  ' Stream Template ' ||  l_gts_name  || ' has been found for the combination of ' ||
          'Deal Type ' || bc_to_rec.deal_type || ', Tax Owner - ' || bc_to_rec.tax_owner || ', Org Id - ' || org_rec.org_id);
         -- If stream template is not active
         IF l_gtt_status <>  'ACTIVE'
         THEN
           -- validate stream template
           IF l_gtt_status <>  'COMPLETE'
           THEN
             Fnd_File.put_line(Fnd_File.LOG,'Validating the Stream Template - '  || l_gts_name );
             Okl_Strm_Gen_Template_Pub.validate_template(
               p_api_version       => l_api_version,
               p_init_msg_list     => l_init_msg_list,
               x_return_status     => x_return_status,
               x_msg_count         => x_msg_count,
               x_msg_data          => x_msg_data,
               p_gtt_id            => l_gtt_id,
               x_error_msgs_tbl    => l_error_msgs_tbl,
               x_return_tmpt_status=> l_gtt_out_status,
               p_during_upd_flag   => 'N' );
             IF (l_gtt_out_status = 'INCOMPLETE')
             THEN
               Fnd_File.PUT_LINE(Fnd_File.LOG, 'The following errors occured while validating the stream template - ' || l_gts_name );
               IF l_error_msgs_tbl.COUNT > 0
               THEN
                 FOR i IN l_error_msgs_tbl.FIRST .. l_error_msgs_tbl.LAST
                 LOOP
                   Fnd_File.PUT_LINE(Fnd_File.LOG, l_error_msgs_tbl(i).Error_Message);
                 END LOOP;
               END IF;
             END IF; -- (l_gtt_out_status = 'INCOMPLETE')
           END IF;  -- IF l_gtt_status <>  'COMPLETE' THEN
           IF (l_gtt_out_status = 'COMPLETE') OR (l_gtt_status =  'COMPLETE')
           THEN
             -- activate stream template
             Fnd_File.put_line(Fnd_File.LOG,'Activating the Stream Template - '  || l_gts_name );
             Okl_Strm_Gen_Template_Pub.activate_template(
               p_api_version       => l_api_version,
               p_init_msg_list     => l_init_msg_list,
               x_return_status     => x_return_status,
               x_msg_count         => x_msg_count,
               x_msg_data          => x_msg_data,
               p_gtt_id            => l_gtt_id  );
             IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
             THEN
               Fnd_File.PUT_LINE(Fnd_File.LOG, 'The following errors occured while activating the template - ' || l_gts_name );
               Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
               IF (l_error_msg_rec.COUNT > 0)
               THEN
                 FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST
                 LOOP
                   IF l_error_msg_rec(m) IS NOT NULL
                   THEN
                     Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
                   END IF;
                 END LOOP;
               END IF;
             END IF;
           END IF; -- IF (l_gtt_out_status = 'COMPLETE') THEN
         END IF;     -- l_gtt_status <>  'ACTIVE' THEN
       ELSE -- -- l_gts_exists = 'Y' THEN
        l_gtsv_rec := NULL;
        l_gttv_rec := NULL;
        l_gtlv_tbl.DELETE;
        -- Populate Stream Generation Template set details.
        l_gtsv_rec.object_version_number := 1;
        l_gtsv_rec.deal_type     := bc_to_rec.deal_type;
        l_gtsv_rec.pricing_engine   := UPPER(p_stream_generator);
        IF bc_to_rec.deal_type = 'SALE'
        THEN
          l_gtsv_rec.name           := bc_to_rec.deal_type || '-' || 'LESSEE';
          l_gtsv_rec.description         := 'Seeded Template for ' || bc_to_rec.deal_type || ' - ' || 'LESSEE';
          l_gtsv_rec.tax_owner     := 'LESSEE';
        ELSE
          l_gtsv_rec.name           := bc_to_rec.deal_type || '-' || bc_to_rec.tax_owner;
          l_gtsv_rec.description         := 'Seeded Template for ' || bc_to_rec.deal_type || ' - ' || bc_to_rec.tax_owner;
          l_gtsv_rec.tax_owner     := bc_to_rec.tax_owner;
        END IF;
        IF bc_to_rec.deal_type = 'SALE'
        THEN
          l_gtsv_rec.product_type      := 'INVESTOR';
        ELSE
          l_gtsv_rec.product_type      := 'FINANCIAL';
        END IF;
        -- Populate Stream Generation Template details.
        l_gttv_rec.object_version_number := 1;
        l_gttv_rec.version               := '1.0';
        l_gttv_rec.tmpt_status           := 'NEW';
        OPEN gtt_start_date_csr;
        FETCH gtt_start_date_csr INTO l_gttv_rec.start_date;
        CLOSE gtt_start_date_csr;
        -- Call the API to create stream template set, template and lines
        Fnd_File.put_line(Fnd_File.LOG,'Creating the Stream Template set - '  || l_gtsv_rec.name );
        create_strm_gen_template(
          p_api_version       => l_api_version,
          p_init_msg_list     => l_init_msg_list,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data,
          p_gtsv_rec          => l_gtsv_rec,
          p_gttv_rec          => l_gttv_rec,
          p_gtpv_tbl          => l_gtpv_tbl,
          p_gtlv_tbl          => l_gtlv_tbl,
          x_gttv_rec          => x_gttv_rec);
        IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
        THEN
          Fnd_File.PUT_LINE(Fnd_File.LOG, 'The following errors occured while creating stream template ' || l_gtsv_rec.name );
          Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
          IF (l_error_msg_rec.COUNT > 0)
          THEN
            FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST
            LOOP
              IF l_error_msg_rec(m) IS NOT NULL
              THEN
                Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
              END IF;
            END LOOP;
          END IF;
        END IF;
        Fnd_File.PUT_LINE(Fnd_File.LOG, 'Adding mandatory primary and dependent stream types for the stream template ' || l_gtsv_rec.name );
        Add_Mandatory (p_book_class => bc_to_rec.deal_type,
          p_gttv_rec   => x_gttv_rec,
          x_gtlv_tbl   => l_gtlv_tbl);
        IF l_gtlv_tbl.COUNT > 0
        THEN
          --       Fnd_File.PUT_LINE(Fnd_File.LOG, 'Adding Template Lines for ' || bc_to_rec.deal_type || '-' || bc_to_rec.tax_owner );
          insert_template_lines(
            p_api_version       => l_api_version,
            p_init_msg_list     => l_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_gtlv_tbl          => l_gtlv_tbl);
         IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
         THEN
           Fnd_File.PUT_LINE(Fnd_File.LOG, 'The following errors occured while adding mandatory template lines ' );
           Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
           IF (l_error_msg_rec.COUNT > 0)
           THEN
             FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
               IF l_error_msg_rec(m) IS NOT NULL THEN
                 Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
               END IF;
             END LOOP;
           END IF;
         END IF;
       END IF;  -- IF  l_gtlv_tbl.COUNT > 0 THEN
       IF  bc_to_rec.deal_type <> 'SALE'
       THEN
         Fnd_File.PUT_LINE(Fnd_File.LOG, 'Adding primary and dependent stream types for the stream template ' || l_gtsv_rec.name  || ' based on usage. ');
         l_gtlv_tbl.DELETE;
         Add_Used_Stream_Types (
           p_book_class => bc_to_rec.deal_type,
           p_tax_owner => bc_to_rec.tax_owner,
           p_gttv_rec   => x_gttv_rec,
           x_gtlv_tbl   => l_gtlv_tbl);
         IF l_gtlv_tbl.COUNT > 0
         THEN
           insert_template_lines(
             p_api_version       => l_api_version,
             p_init_msg_list     => l_init_msg_list,
             x_return_status     => x_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,
             p_gtlv_tbl          => l_gtlv_tbl);
           IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
           THEN
             Fnd_File.PUT_LINE(Fnd_File.LOG, 'The following errors occured while adding used template lines ' );
             Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
             IF (l_error_msg_rec.COUNT > 0) THEN
               FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
                 IF l_error_msg_rec(m) IS NOT NULL THEN
                   Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
                  END IF;
               END LOOP;
             END IF;
           END IF;
         END IF;  -- IF  l_gtlv_tbl.COUNT > 0 THEN
       END IF;
       -- validate stream template
       Fnd_File.PUT_LINE(Fnd_File.LOG, 'Validating the template - ' || l_gtsv_rec.name );
       Okl_Strm_Gen_Template_Pub.validate_template(
         p_api_version       => l_api_version,
         p_init_msg_list     => l_init_msg_list,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         p_gtt_id            => x_gttv_rec.id,
         x_error_msgs_tbl    => l_error_msgs_tbl,
         x_return_tmpt_status=> l_gtt_out_status,
         p_during_upd_flag   => 'N' );
       IF (l_gtt_out_status = 'INCOMPLETE')
       THEN
         Fnd_File.PUT_LINE(Fnd_File.LOG, 'The following errors occured  while validating the stream template - ' || l_gtsv_rec.name );
         IF l_error_msgs_tbl.COUNT > 0
         THEN
           FOR i IN l_error_msgs_tbl.FIRST .. l_error_msgs_tbl.LAST LOOP
             Fnd_File.PUT_LINE(Fnd_File.LOG, l_error_msgs_tbl(i).Error_Message);
           END LOOP;
         END IF;
       ELSE -- (l_gtt_out_status = 'INCOMPLETE')
         -- activate stream template
         Fnd_File.PUT_LINE(Fnd_File.LOG, 'Activating the template - ' || l_gtsv_rec.name );
         Okl_Strm_Gen_Template_Pub.activate_template(
           p_api_version       => l_api_version,
           p_init_msg_list     => l_init_msg_list,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_gtt_id            => x_gttv_rec.id  );
         IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
         THEN
           Fnd_File.PUT_LINE(Fnd_File.LOG, 'The following errors occured  while activating the template - ' || l_gtsv_rec.name );
           Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
           IF (l_error_msg_rec.COUNT > 0)
           THEN
             FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
               IF l_error_msg_rec(m) IS NOT NULL THEN
                 Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
               END IF;
             END LOOP;
           END IF;
         END IF;
       END IF;
     END IF; -- l_gts_exists = 'Y' THEN
   END LOOP; -- End of org csr
  END LOOP; -- End of pdt_csr
  Okl_Api.END_ACTIVITY (x_msg_count, x_msg_data );
EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
      IF (l_error_msg_rec.COUNT > 0) THEN
        FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
          IF l_error_msg_rec(m) IS NOT NULL THEN
            Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
          END IF;
        END LOOP;
      END IF;

   WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
      IF (l_error_msg_rec.COUNT > 0) THEN
        FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
          IF l_error_msg_rec(m) IS NOT NULL THEN
            Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
          END IF;
        END LOOP;
      END IF;

   WHEN OTHERS THEN
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
      IF (l_error_msg_rec.COUNT > 0) THEN
        FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
          IF l_error_msg_rec(m) IS NOT NULL THEN
            Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
          END IF;
        END LOOP;
      END IF;

END Migrate_Streams_Process;
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate_Accounting_Templates
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Migrate_Accounting_Templates
  -- Description     : Migrate Accounting Templates
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Migrate_Accounting_Templates
IS
l_aesv_rec aesv_rec_type;
l_avlv_rec avlv_rec_type;
l_atlv_rec atlv_rec_type;
l_pdtv_rec pdtv_rec_type;

x_aesv_rec aesv_rec_type;
x_avlv_rec avlv_rec_type;
x_atlv_rec atlv_rec_type;
x_pdtv_rec pdtv_rec_type;

-- Cursor to select all existing org from template sets

CURSOR aes_org_csr IS
SELECT DISTINCT org_id
FROM okl_ae_tmpt_sets;


-- Cursor to select all existing products and its values
CURSOR pdt_csr IS
SELECT
  p.id product_id,
  p.name product_name,
  p.aes_id aes_id,
  p.ptl_id,
  q1.value deal_type,
  q2.value tax_owner,
  aes.name aes_name
FROM
  okl_products_v p,
  okl_ae_tmpt_sets_v aes,
  okl_pdt_pqy_vals_uv q1,
  okl_pdt_pqy_vals_uv q2
WHERE
  p.aes_id = aes.id AND
  aes.gts_id IS NULL AND
  p.id = q1.pdt_id AND q1.name = 'LEASE'  AND q1.value IS NOT NULL AND
  p.id = q2.pdt_id AND q2.name = 'TAXOWNER' AND q2.value IS NOT NULL
UNION
SELECT
  p.id product_id,
  p.name product_name,
  p.aes_id aes_id,
  p.ptl_id,
  q1.value deal_type,
  'LESSEE' tax_owner,
  aes.name aes_name
FROM
  okl_products_v p,
  okl_ae_tmpt_sets_v aes,
  okl_pdt_pqy_vals_uv q1
WHERE
  p.aes_id = aes.id AND
  aes.gts_id IS NULL AND
  p.id = q1.pdt_id AND q1.name = 'INVESTOR' AND q1.value IS NOT NULL
ORDER BY aes_id, deal_type, tax_owner,product_id;


-- Cursor to get all the stream templates for the unique combination
-- of deal type and tax owner.

CURSOR st_tmpt_csr (p_deal_type VARCHAR2, p_tax_owner VARCHAR2, l_name VARCHAR2) IS
SELECT gts.id, gts.name
FROM OKL_ST_GEN_TMPT_SETS gts, OKL_ST_GEN_TEMPLATES gtt
WHERE gts.id = gtt.gts_id AND
gts.deal_type = p_deal_type
AND gts.tax_owner = p_tax_owner AND
gts.name = l_name AND
gtt.tmpt_status = 'ACTIVE';

-- Cursor to check to see if the accounting template set is used by more than one product.


-- Cursor to get aes record from database

CURSOR aesv_pk_csr (p_id IN NUMBER) IS
SELECT
      id,
      object_version_number,
      name,
      description,
      version,
      start_date,
      end_date,
      org_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      gts_id
FROM okl_ae_tmpt_sets_v
WHERE okl_ae_tmpt_sets_v.id = p_id;

-- Cursor to get all the templates for a template set.

CURSOR avlv_pk_csr (p_aes_id IN NUMBER) IS
SELECT
      id,
      object_version_number,
      try_id,
      aes_id,
      sty_id,
      fma_id,
      set_of_books_id,
      fac_code,
      syt_code,
      post_to_gl,
      advance_arrears,
      memo_yn,
      prior_year_yn,
      name,
      description,
      version,
      factoring_synd_flag,
      start_date,
      end_date,
      Accrual_Yn,
      attribute_category,
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
      org_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      inv_code
 FROM OKL_AE_TEMPLATES
 WHERE OKL_AE_TEMPLATES.aes_id = p_aes_id;

-- Cursor to select all template lines for a template

 CURSOR atlv_pk_csr (p_avl_id IN NUMBER) IS
 SELECT
       id,
       object_version_number,
       avl_id,
       crd_code,
       code_combination_id,
       ae_line_type,
       sequence_number,
       description,
       percentage,
       account_builder_yn,
       attribute_category,
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
       org_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login
    FROM OKL_AE_TMPT_LNES
    WHERE OKL_AE_TMPT_LNES.avl_id = p_avl_id;


CURSOR org_name_csr (l_org_id IN NUMBER) IS
SELECT name
FROM   hr_operating_units
WHERE  organization_id = l_org_id;

-- End : Cursors declaration

-- Start : All local variables declaration

l_api_version    NUMBER DEFAULT 1.0;
l_init_msg_list  VARCHAR2(1) DEFAULT Okl_Api.g_false;
x_return_status  VARCHAR2(1) := Okl_Api.g_ret_sts_success;
x_msg_count      NUMBER;
x_msg_data       VARCHAR2(2000);
l_org_name   VARCHAR2(150);

l_product_name  okl_products_v.name%TYPE;
l_product_id    okl_products_v.id%TYPE;
l_ptl_id  okl_products_v.ptl_id%TYPE;
l_aes_id        okl_ae_tmpt_sets.id%TYPE;
l_deal_type  okl_pdt_pqy_vals_uv.value%TYPE;
l_tax_owner  okl_pdt_pqy_vals_uv.value%TYPE;

l_new_aes_id    okl_ae_tmpt_sets.id%TYPE;
l_template_id    okl_ae_templates.id%TYPE;
l_new_template_id    okl_ae_templates.id%TYPE;

l_gts_id  OKL_ST_GEN_TMPT_SETS.id%TYPE;
l_gts_name  OKL_ST_GEN_TMPT_SETS.name%TYPE;
l_old_aes_name   okl_ae_tmpt_sets_v.name%TYPE;

l_row_found      VARCHAR2(1000);
l_template_set_found    VARCHAR2(1);
l_templates_found    VARCHAR2(1);
l_template_lines_found    VARCHAR2(1);
l_used_by_other_products  VARCHAR2(1);

-- variables for utl_file

l_log_file        VARCHAR2(2000);
l_out_file        VARCHAR2(2000);
l_out_file_dir     VARCHAR2(1000);

l_api_name VARCHAR2(100);


l_error_msg_rec   Okl_Accounting_Util.ERROR_MESSAGE_TYPE;
l_prev_deal_type  okl_pdt_pqy_vals_uv.value%TYPE;
l_prev_aes_id     NUMBER;
-- Bug 4938066
l_prev_tax_owner  okl_pdt_pqy_vals_uv.value%TYPE;
l_aes_deal_type  okl_pdt_pqy_vals_uv.value%TYPE;
l_aes_tax_owner  okl_pdt_pqy_vals_uv.value%TYPE;


BEGIN
  x_return_status := Okl_Api.START_ACTIVITY (
                                  l_api_name
                                 ,l_init_msg_list
                                 ,'_PVT'
                                 ,x_return_status);
  -- Check if activity started successfully
  IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR)
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR)
  THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  FOR aes_org_rec IN aes_org_csr
  LOOP
    mo_global.set_policy_context('S',aes_org_rec.org_id); --dkagrawa changed for MOAC
    FOR org_name_rec IN org_name_csr (aes_org_rec.org_id)
    LOOP
      l_org_name := org_name_rec.name;
    END LOOP;
    Fnd_File.put_line(Fnd_File.LOG,' ');
    Fnd_File.put_line(Fnd_File.LOG,'Operating Unit : ' || l_org_name);
    Fnd_File.put_line(Fnd_File.LOG,'======================================');
    Fnd_File.put_line(Fnd_File.LOG,'Migrating Products and Accounting Templates ... ');
    -- Loop through the products in the system
    FOR pdt_rec IN pdt_csr
    LOOP
      l_product_id    := pdt_rec.product_id;
      l_product_name  := pdt_rec.product_name;
      l_aes_id        := pdt_rec.aes_id;
      l_deal_type    := pdt_rec.deal_type;
      l_tax_owner    := pdt_rec.tax_owner;
      l_ptl_id    := pdt_rec.ptl_id;
      Fnd_File.put_line(Fnd_File.LOG,' ');
      Fnd_File.put_line(Fnd_File.LOG,'Processing Product ' || l_product_name || ' ... ');
      Fnd_File.put_line(Fnd_File.LOG,'------------------------------------------------- ');
      -- Check if the stream template exists for a product.
      l_gts_id := NULL;
      l_gts_name := NULL;
      OPEN st_tmpt_csr(l_deal_type, l_tax_owner, l_deal_type || '-' || l_tax_owner);
      FETCH st_tmpt_csr INTO l_gts_id, l_gts_name;
      IF st_tmpt_csr%NOTFOUND
      THEN
        Fnd_File.put_line(Fnd_File.LOG,'Deal Type : ' || l_deal_type );
        Fnd_File.put_line(Fnd_File.LOG,'Tax Owner : ' || l_tax_owner );
        Fnd_File.put_line(Fnd_File.LOG,'Stream Template does not exist for this product ');
      ELSE
        Fnd_File.put_line(Fnd_File.LOG,'Deal Type : ' || l_deal_type );
        Fnd_File.put_line(Fnd_File.LOG,'Tax Owner : ' || l_tax_owner );
        Fnd_File.put_line(Fnd_File.LOG,'Stream Template : ' || l_gts_name );
      END IF;
      CLOSE st_tmpt_csr;

      -- if the stream template exists for a product.
      IF l_gts_id IS NOT NULL
      THEN

        -- Fnd_File.put_line(Fnd_File.LOG,'Stream Template for Deal Type ' || l_deal_type || ' and Tax Owner ' || l_tax_owner || ' is ' || TO_CHAR(l_gts_id));
        l_used_by_other_products := 'N';
        IF (l_prev_deal_type IS NULL AND l_prev_tax_owner IS NULL )
           AND l_prev_aes_id IS NULL
        THEN
          -- For the first product, we have to make l_used_by_other_products should be made to 'N'
          l_used_by_other_products := 'N';
          l_aes_deal_type := l_deal_type;
          l_aes_tax_owner := l_tax_owner;
        ELSIF ( l_prev_deal_type = l_deal_type AND l_prev_tax_owner = l_tax_owner)
               AND l_prev_aes_id = l_aes_id
        THEN
          -- If the current product has the same quality values and AES
          -- as the previous product ..
          -- then use the same AES as it is.
          IF (l_deal_type = l_aes_deal_type AND l_tax_owner = l_aes_tax_owner )
          THEN
            l_used_by_other_products := 'N';
          ELSE
            l_used_by_other_products := 'Y';
          END IF;
        ELSIF ( l_prev_deal_type <> l_deal_type OR l_prev_tax_owner <> l_tax_owner )
              AND l_prev_aes_id = l_aes_id
        THEN
          -- If the current product has the conflicting quality values and AES is the same
          -- as the previous product .. then copy the AES to P-AES
          l_used_by_other_products := 'Y';
        ELSIF l_prev_aes_id <> l_aes_id
              --AND l_prev_deal_type <> l_deal_type
        THEN
           -- Else, if we have control broken on the AES, then it means that we
           --  are actually reached the next set of products for which the AES is the same
          l_used_by_other_products := 'N';
          l_aes_deal_type := l_deal_type;
          l_aes_tax_owner := l_tax_owner;
        END IF;
        l_prev_deal_type := l_deal_type;
        l_prev_tax_owner := l_tax_owner;
        l_prev_aes_id    := l_aes_id;
        --    Fnd_File.put_line(Fnd_File.LOG,'l_used_by_other_products -- ' || l_used_by_other_products);
        IF l_used_by_other_products = 'Y'
        THEN
          -- ============ Start : Create New Template Set for the product ====================
          l_template_set_found := 'Y';
          OPEN aesv_pk_csr (l_aes_id);
          FETCH aesv_pk_csr INTO
                 l_aesv_rec.id,
                 l_aesv_rec.object_version_number,
                 l_aesv_rec.name,
                 l_aesv_rec.description,
                 l_aesv_rec.version,
                 l_aesv_rec.start_date,
                 l_aesv_rec.end_date,
                 l_aesv_rec.org_id,
                 l_aesv_rec.created_by,
                 l_aesv_rec.creation_date,
                 l_aesv_rec.last_updated_by,
                 l_aesv_rec.last_update_date,
                 l_aesv_rec.last_update_login,
                 l_aesv_rec.gts_id;
          IF aesv_pk_csr%NOTFOUND
          THEN
            Fnd_File.put_line(Fnd_File.LOG,'Accounting Template set does not exist for product ' || l_product_name);
            l_template_set_found := 'N';
          END IF;
          CLOSE aesv_pk_csr;
          IF l_template_set_found = 'Y'
          THEN
            -- Set a new name for the new accounting template set.
            l_old_aes_name := l_aesv_rec.name;
            l_aesv_rec.id   := Okl_Api.G_MISS_NUM;
            l_aesv_rec.name   := l_product_name || '-' || l_aesv_rec.name;
            l_aesv_rec.gts_id   := l_gts_id;
            -- Create new template set.
            Fnd_File.put_line(Fnd_File.LOG,'Creating Accounting Template set - ' || l_aesv_rec.name  || ' by copying from - ' || l_old_aes_name);
            Okl_Process_Tmpt_Set_Pub.create_tmpt_set(
              p_api_version       => l_api_version,
              p_init_msg_list     => l_init_msg_list,
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              p_aesv_rec          => l_aesv_rec,
              x_aesv_rec          => x_aesv_rec);
            -- Check if the creation is successful.
            IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
            THEN
              Fnd_File.put_line(Fnd_File.LOG,'The following errors occured while Creating Accounting Template set - ' || l_aesv_rec.name );
              Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
              IF (l_error_msg_rec.COUNT > 0)
              THEN
                FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST
                LOOP
                  IF l_error_msg_rec(m) IS NOT NULL
                  THEN
                    Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
                  END IF;
                END LOOP;
              END IF;
            ELSE
              -- Get the new accounting template set id.
              -- Fnd_File.put_line(Fnd_File.LOG,'Accounting Template set ' || l_aesv_rec.name || ' created ' );
              l_new_aes_id := x_aesv_rec.id;
            END IF;
          END IF; -- l_template_set_found = 'Y' THEN
          -- ============ End : Create New Template Set for the product ====================
          -- ============ Start : Copy Accounting Templates for the Set ====================
          l_templates_found := 'N';
          FOR avlv_pk_rec IN avlv_pk_csr (l_aes_id)
          LOOP
            l_templates_found := 'Y';
            l_template_id               := avlv_pk_rec.id;
            l_avlv_rec.object_version_number   :=  avlv_pk_rec.object_version_number;
            l_avlv_rec.try_id       :=  avlv_pk_rec.try_id;
            l_avlv_rec.aes_id       :=  l_new_aes_id;
            l_avlv_rec.sty_id       :=  avlv_pk_rec.sty_id;
            l_avlv_rec.fma_id       :=  avlv_pk_rec.fma_id;
            l_avlv_rec.set_of_books_id     :=  avlv_pk_rec.set_of_books_id;
            l_avlv_rec.fac_code       :=  avlv_pk_rec.fac_code;
            l_avlv_rec.syt_code       :=  avlv_pk_rec.syt_code;
            l_avlv_rec.post_to_gl       :=  avlv_pk_rec.post_to_gl;
            l_avlv_rec.advance_arrears     :=  avlv_pk_rec.advance_arrears;
            l_avlv_rec.memo_yn       :=  avlv_pk_rec.memo_yn;
            l_avlv_rec.prior_year_yn     :=  avlv_pk_rec.prior_year_yn;
            l_avlv_rec.name       :=  avlv_pk_rec.name;
            l_avlv_rec.description       :=  avlv_pk_rec.description;
            l_avlv_rec.version       :=  avlv_pk_rec.version;
            l_avlv_rec.factoring_synd_flag     :=  avlv_pk_rec.factoring_synd_flag;
            l_avlv_rec.start_date       :=  avlv_pk_rec.start_date;
            l_avlv_rec.end_date       :=  avlv_pk_rec.end_date;
            l_avlv_rec.Accrual_Yn       :=  avlv_pk_rec.Accrual_Yn;
            l_avlv_rec.attribute_category     :=  avlv_pk_rec.attribute_category;
            l_avlv_rec.attribute1       :=  avlv_pk_rec.attribute1;
            l_avlv_rec.attribute2       :=  avlv_pk_rec.attribute2;
            l_avlv_rec.attribute3       :=  avlv_pk_rec.attribute3;
            l_avlv_rec.attribute4       :=  avlv_pk_rec.attribute4;
            l_avlv_rec.attribute5       :=  avlv_pk_rec.attribute5;
            l_avlv_rec.attribute6       :=  avlv_pk_rec.attribute6;
            l_avlv_rec.attribute7       :=  avlv_pk_rec.attribute7;
            l_avlv_rec.attribute8       :=  avlv_pk_rec.attribute8;
            l_avlv_rec.attribute9       :=  avlv_pk_rec.attribute9;
            l_avlv_rec.attribute10      :=  avlv_pk_rec.attribute10;
            l_avlv_rec.attribute11      :=  avlv_pk_rec.attribute11;
            l_avlv_rec.attribute12      :=  avlv_pk_rec.attribute12;
            l_avlv_rec.attribute13      :=  avlv_pk_rec.attribute13;
            l_avlv_rec.attribute14      :=  avlv_pk_rec.attribute14;
            l_avlv_rec.attribute15      :=  avlv_pk_rec.attribute15;
            l_avlv_rec.org_id       :=  avlv_pk_rec.org_id;
            l_avlv_rec.created_by       :=  avlv_pk_rec.created_by;
            l_avlv_rec.creation_date     :=  avlv_pk_rec.creation_date;
            l_avlv_rec.last_updated_by     :=  avlv_pk_rec.last_updated_by;
            l_avlv_rec.last_update_date     :=  avlv_pk_rec.last_update_date;
            l_avlv_rec.last_update_login     :=  avlv_pk_rec.last_update_login;
            l_avlv_rec.inv_code       :=  avlv_pk_rec.inv_code;
            -- Create new template.
            Okl_Process_Tmpt_Set_Pub.create_template(
              p_api_version       => l_api_version,
              p_init_msg_list     => l_init_msg_list,
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              p_avlv_rec          => l_avlv_rec,
              x_avlv_rec          => x_avlv_rec);
            -- Check if the creation is successful.
            IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
            THEN
              Fnd_File.put_line(Fnd_File.LOG,'Accounting Template ' || l_avlv_rec.name ||
                         ' could not be copied because of the following issues ');
              Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
              IF (l_error_msg_rec.COUNT > 0)
              THEN
                FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST
                LOOP
                  IF l_error_msg_rec(m) IS NOT NULL
                  THEN
                    Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
                  END IF;
                END LOOP;
              END IF;
            ELSE
              -- Get the new accounting template set id.
              l_new_template_id := x_avlv_rec.id;
            END IF;
            -- ============ Start : Copy Accounting Template Lines for the template ============
            l_template_lines_found := 'N';
            FOR atlv_pk_rec IN atlv_pk_csr (l_template_id)
            LOOP
              l_template_lines_found := 'Y';
              l_atlv_rec.id       :=  atlv_pk_rec.id;
              l_atlv_rec.object_version_number :=  atlv_pk_rec.object_version_number;
              l_atlv_rec.avl_id     :=  l_new_template_id;
              l_atlv_rec.crd_code     :=  atlv_pk_rec.crd_code;
              l_atlv_rec.code_combination_id   :=  atlv_pk_rec.code_combination_id;
              l_atlv_rec.ae_line_type     :=  atlv_pk_rec.ae_line_type;
              l_atlv_rec.sequence_number   :=  atlv_pk_rec.sequence_number;
              l_atlv_rec.description     :=  atlv_pk_rec.description;
              l_atlv_rec.percentage     :=  atlv_pk_rec.percentage;
              l_atlv_rec.account_builder_yn   :=  atlv_pk_rec.account_builder_yn;
              l_atlv_rec.attribute_category   :=  atlv_pk_rec.attribute_category;
              l_atlv_rec.attribute1     :=  atlv_pk_rec.attribute1;
              l_atlv_rec.attribute2     :=  atlv_pk_rec.attribute2;
              l_atlv_rec.attribute3     :=  atlv_pk_rec.attribute3;
              l_atlv_rec.attribute4     :=  atlv_pk_rec.attribute4;
              l_atlv_rec.attribute5     :=  atlv_pk_rec.attribute5;
              l_atlv_rec.attribute6     :=  atlv_pk_rec.attribute6;
              l_atlv_rec.attribute7     :=  atlv_pk_rec.attribute7;
              l_atlv_rec.attribute8     :=  atlv_pk_rec.attribute8;
              l_atlv_rec.attribute9     :=  atlv_pk_rec.attribute9;
              l_atlv_rec.attribute10     :=  atlv_pk_rec.attribute10;
              l_atlv_rec.attribute11     :=  atlv_pk_rec.attribute11;
              l_atlv_rec.attribute12     :=  atlv_pk_rec.attribute12;
              l_atlv_rec.attribute13     :=  atlv_pk_rec.attribute13;
              l_atlv_rec.attribute14     :=  atlv_pk_rec.attribute14;
              l_atlv_rec.attribute15     :=  atlv_pk_rec.attribute15;
              l_atlv_rec.org_id     :=  atlv_pk_rec.org_id;
              l_atlv_rec.created_by     :=  atlv_pk_rec.created_by;
              l_atlv_rec.creation_date   :=  atlv_pk_rec.creation_date;
              l_atlv_rec.last_updated_by   :=  atlv_pk_rec.last_updated_by;
              l_atlv_rec.last_update_date   :=  atlv_pk_rec.last_update_date;
              l_atlv_rec.last_update_login   :=  atlv_pk_rec.last_update_login;
              -- Create new template.
              Okl_Process_Tmpt_Set_Pub.create_tmpt_lines(
                p_api_version       => l_api_version,
                p_init_msg_list     => l_init_msg_list,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_atlv_rec          => l_atlv_rec,
                x_atlv_rec          => x_atlv_rec );
              -- Check if the creation is successful.
              IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
              THEN
                Fnd_File.put_line(Fnd_File.LOG,'Accounting Template Lines ' || l_atlv_rec.crd_code ||
                      ' could not be copied because of the following issues ');
                Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
                IF (l_error_msg_rec.COUNT > 0)
                THEN
                  FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST
                  LOOP
                    IF l_error_msg_rec(m) IS NOT NULL THEN
                      Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
                    END IF;
                  END LOOP;
                END IF;
              END IF;
            END LOOP; -- End Loop for atlv_pk_csr
          END LOOP; -- End Loop for avlv_pk_csr
          -- ============ End : Copy Accounting Templates for the Set ====================
          -- ============ Start : Update the product with new accounting template set ==============
          -- UPDATE PRODUCT WITH NEW AES_ID
          l_pdtv_rec.id   := l_product_id;
          l_pdtv_rec.aes_id   := l_new_aes_id;
          l_pdtv_rec.ptl_id   := l_ptl_id;
          l_pdtv_rec.product_status_code   := Okl_Setupproducts_Pvt.G_PDT_STS_INVALID;
          Fnd_File.put_line(Fnd_File.LOG,'Associating the product - ' || l_product_name || ' with the new Accounting Template set - ' || l_aesv_rec.name );
          Fnd_File.put_line(Fnd_File.LOG,'Invalidating the product - ' || l_product_name  );
          Okl_Products_Pub.update_products(
            p_api_version       => l_api_version,
            p_init_msg_list     => l_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_pdtv_rec          => l_pdtv_rec,
            x_pdtv_rec          => x_pdtv_rec );
          -- Check if the updation is successful.
          IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
          THEN
            Fnd_File.put_line(Fnd_File.LOG,'The following errors occured while associating the product with new Accounting Template set ' );
            Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
            IF (l_error_msg_rec.COUNT > 0)
            THEN
              FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
                IF l_error_msg_rec(m) IS NOT NULL THEN
                  Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
                END IF;
              END LOOP;
            END IF;
          END IF;
          -- PRODUCT VALIDATIONS
          IF x_return_status = Okl_Api.G_RET_STS_SUCCESS
          THEN
            Fnd_File.put_line(Fnd_File.LOG,'Validating the product - ' || l_product_name  );
            Okl_Setupproducts_Pvt.validate_product(
              p_api_version       => l_api_version,
              p_init_msg_list     => l_init_msg_list,
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              p_pdtv_rec          => l_pdtv_rec,
              x_pdtv_rec          => x_pdtv_rec);
            -- Check if the creation is successful.
            IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
            THEN
              Fnd_File.put_line(Fnd_File.LOG,'The following errors occured while validating the product - ' || l_product_name );
              Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
              IF (l_error_msg_rec.COUNT > 0)
              THEN
                FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
                  IF l_error_msg_rec(m) IS NOT NULL
                  THEN
                    Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
                  END IF;
                END LOOP;
              END IF;
            END IF;
            IF x_pdtv_rec.PRODUCT_STATUS_CODE = 'PASSED'
            THEN
              Fnd_File.put_line(Fnd_File.LOG,'Approving the product - ' || l_product_name  );
              Okl_Setupproducts_Pvt.update_product_status(
                p_api_version       => l_api_version,
                p_init_msg_list     => l_init_msg_list,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_pdt_status        => Okl_Setupproducts_Pvt.G_PDT_STS_APPROVED,
                p_pdt_id            => x_pdtv_rec.id);
              -- Check if the creation is successful.
              IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
              THEN
                Fnd_File.put_line(Fnd_File.LOG,'The following errors occured while approving the product - ' || l_product_name );
                Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
                IF (l_error_msg_rec.COUNT > 0)
                THEN
                  FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST
                  LOOP
                    IF l_error_msg_rec(m) IS NOT NULL THEN
                      Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
                    END IF;
                  END LOOP;
                END IF;
              END IF;
            END IF; -- IF x_pdtv_rec.PRODUCT_STATUS_CODE = 'PASSED' THEN
          END IF; -- x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
          -- ============ End : Update the product with new accounting template set ==============
        ELSIF l_used_by_other_products = 'N' THEN -- l_used_by_other_products = 'Y' THEN
          -- ============ Start : Update Template Set with Stream Template ====================
          l_template_set_found := 'Y';
          OPEN aesv_pk_csr (l_aes_id);
          FETCH aesv_pk_csr INTO
                l_aesv_rec.id,
                l_aesv_rec.object_version_number,
                l_aesv_rec.name,
                l_aesv_rec.description,
                l_aesv_rec.version,
                l_aesv_rec.start_date,
                l_aesv_rec.end_date,
                l_aesv_rec.org_id,
                l_aesv_rec.created_by,
                l_aesv_rec.creation_date,
                l_aesv_rec.last_updated_by,
                l_aesv_rec.last_update_date,
                l_aesv_rec.last_update_login,
                l_aesv_rec.gts_id;
          IF aesv_pk_csr%NOTFOUND
          THEN
            Fnd_File.put_line(Fnd_File.LOG,'Accounting Template set does not exist for product ' || l_product_name);
            l_template_set_found := 'N';
          END IF;
          CLOSE aesv_pk_csr;
          IF l_template_set_found = 'Y'
          THEN
            IF l_aesv_rec.gts_id IS NULL
            THEN
              l_aesv_rec.id   := l_aes_id;
              l_aesv_rec.gts_id := l_gts_id;
              -- Update Accounting Template set with the gts_id.
              Fnd_File.put_line(Fnd_File.LOG,'Updating the accounting template set - ' || l_aesv_rec.name || ' with stream template' );
              Okl_Process_Tmpt_Set_Pub.update_tmpt_set(
                p_api_version       => l_api_version,
                p_init_msg_list     => l_init_msg_list,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_aesv_rec          => l_aesv_rec,
                x_aesv_rec          => x_aesv_rec);
              -- Check if the update is successful.
              IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
              THEN
                Fnd_File.put_line(Fnd_File.LOG,'The following errors occured while updating the accounting template set - ' || l_aesv_rec.name || ' with stream template' );
                Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
                IF (l_error_msg_rec.COUNT > 0)
                THEN
                  FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST
                  LOOP
                  IF l_error_msg_rec(m) IS NOT NULL
                  THEN
                    Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
                  END IF;
                END LOOP;
              END IF;
            END IF;
          END IF; --     IF l_aesv_rec.gts_id IS NULL THEN
          -- INVALIDATE PRODUCT
          l_pdtv_rec.id   := l_product_id;
          l_pdtv_rec.aes_id   := l_aes_id;
          l_pdtv_rec.ptl_id   := l_ptl_id;
          l_pdtv_rec.product_status_code := Okl_Setupproducts_Pvt.G_PDT_STS_INVALID;
          Fnd_File.put_line(Fnd_File.LOG,'Invalidating the product  - ' || l_product_name );
          Okl_Products_Pub.update_products(
            p_api_version       => l_api_version,
            p_init_msg_list     => l_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_pdtv_rec          => l_pdtv_rec,
            x_pdtv_rec          => x_pdtv_rec);
          -- Fnd_File.put_line(Fnd_File.LOG,'product status ' || x_pdtv_rec.product_status_code );
          -- Check if the updation is successful.
          IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
          THEN
            Fnd_File.put_line(Fnd_File.LOG,'The following errors occured while invalidating the product - ' || l_product_name);
            Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
            IF (l_error_msg_rec.COUNT > 0)
            THEN
              FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST
              LOOP
                IF l_error_msg_rec(m) IS NOT NULL
                THEN
                  Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
                END IF;
              END LOOP;
            END IF;
          END IF;
          -- PRODUCT VALIDATIONS
          Fnd_File.put_line(Fnd_File.LOG,'Validating the product - ' || l_product_name );
          Okl_Setupproducts_Pvt.validate_product(
             p_api_version       => l_api_version,
             p_init_msg_list     => l_init_msg_list,
             x_return_status     => x_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,
             p_pdtv_rec          => l_pdtv_rec,
             x_pdtv_rec          => x_pdtv_rec);
          -- Check if the creation is successful.
          IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
          THEN
            Fnd_File.put_line(Fnd_File.LOG,'The following errors occured while validating the product - ' || l_product_name );
            Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
            IF (l_error_msg_rec.COUNT > 0)
            THEN
              FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST
              LOOP
                IF l_error_msg_rec(m) IS NOT NULL
                THEN
                  Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
                END IF;
              END LOOP;
            END IF;
          END IF;
          IF x_pdtv_rec.PRODUCT_STATUS_CODE = 'PASSED'
          THEN
            Fnd_File.put_line(Fnd_File.LOG,'Approving the product - ' || l_product_name );
            Okl_Setupproducts_Pvt.update_product_status(
              p_api_version       => l_api_version,
              p_init_msg_list     => l_init_msg_list,
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              p_pdt_status        => Okl_Setupproducts_Pvt.G_PDT_STS_APPROVED,
              p_pdt_id            => x_pdtv_rec.id);
            -- Check if the creation is successful.
            IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
            THEN
              Fnd_File.put_line(Fnd_File.LOG,'The following errors occured while approving the product - ' || l_product_name);
              Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
              IF (l_error_msg_rec.COUNT > 0)
              THEN
                FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST
                LOOP
                  IF l_error_msg_rec(m) IS NOT NULL
                  THEN
                   Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
                      END IF;
                    END LOOP;
                  END IF;
                END IF;
              END IF; -- IF    x_pdtv_rec.PRODUCT_STATUS_CODE = 'PASSED' THEN
            END IF; -- l_template_set_found = 'Y' THEN
            -- ============ End : Update Template Set with Stream Template ====================
        END IF; -- l_used_by_other_products = 'N' THEN
        -- if the stream template does not exist for a product.
      ELSE -- l_gts_id IS NULL THEN
        Fnd_File.put_line(Fnd_File.LOG,'Stream Template does not exist for Product ' || l_product_name );
        Fnd_File.put_line(Fnd_File.LOG,'Invalidating the product - ' || l_product_name );
        -- UPDATE THE STATUS OF THE PRODUCT TO INVALID
        Okl_Setupproducts_Pvt.update_product_status(
          p_api_version       => l_api_version,
          p_init_msg_list     => l_init_msg_list,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data,
          p_pdt_status        => Okl_Setupproducts_Pvt.G_PDT_STS_INVALID,
          p_pdt_id            => l_product_id);
        -- Check if the creation is successful.
        IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
        THEN
          Fnd_File.put_line(Fnd_File.LOG,'The following errors occured while invalidating the product - ' || l_product_name  );
          Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
          IF (l_error_msg_rec.COUNT > 0)
          THEN
            FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST
            LOOP
              IF l_error_msg_rec(m) IS NOT NULL
              THEN
                Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
              END IF;
            END LOOP;
          END IF;
        END IF;
      END IF; -- l_gts_id IS NOT NULL
    END LOOP; -- pdt_rec IN pdt_csr LOOP
  END LOOP;  -- End for aes_org_csr
  Okl_Api.END_ACTIVITY (x_msg_count, x_msg_data );
 EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
      IF (l_error_msg_rec.COUNT > 0) THEN
        FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
          IF l_error_msg_rec(m) IS NOT NULL THEN
            Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
          END IF;
        END LOOP;
      END IF;

   WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
      IF (l_error_msg_rec.COUNT > 0) THEN
        FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
          IF l_error_msg_rec(m) IS NOT NULL THEN
            Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
          END IF;
        END LOOP;
      END IF;

   WHEN OTHERS THEN
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
      IF (l_error_msg_rec.COUNT > 0) THEN
        FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
          IF l_error_msg_rec(m) IS NOT NULL THEN
            Fnd_File.put_line(Fnd_File.LOG, l_error_msg_rec(m));
          END IF;
        END LOOP;
      END IF;
 END Migrate_Accounting_Templates;
END OKL_STREAM_MIGRATION_PVT;

/
