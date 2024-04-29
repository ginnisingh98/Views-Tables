--------------------------------------------------------
--  DDL for Package Body OKS_CON_COVERAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_CON_COVERAGE_PVT" AS
/* $Header: OKSRACCB.pls 120.4 2006/07/10 20:48:15 hmnair noship $ */

-----------------------------------------------------------------------------------------------------------------------*

--
-- Added for 12.0 Coverage Rearch project (JVARGHES)
--

  FUNCTION Get_BP_Line_Start_Offset
    (P_BPL_Id	              IN NUMBER
    ,P_SVL_Start	              IN DATE
    ,P_BPL_Start                IN DATE
    ,p_Std_Cov_YN               IN VARCHAR2) RETURN DATE
  IS

    CURSOR Lx_Csr_BPL(Cx_BPL_Id IN NUMBER) IS
    SELECT BPL.Offset_Duration
          ,BPL.Offset_period
      FROM Oks_K_Lines_B BPL
     WHERE BPL.Cle_Id = Cx_BPL_Id;

    Lx_BPL_Id                CONSTANT NUMBER := P_BPL_Id;
    Ld_SVL_Start             CONSTANT DATE := P_SVL_Start;

    Ld_BPL_OFS_Start         DATE;
    Ln_BPL_OFS_Duration      NUMBER;
    Lv_BPL_OFS_UOM           VARCHAR2(100);

    Lx_Return_Status         VARCHAR2(10);

  BEGIN

    Lx_Return_Status         := G_RET_STS_SUCCESS;

    IF p_Std_Cov_YN = 'Y' THEN

      OPEN Lx_Csr_BPL(Lx_BPL_Id);
      FETCH Lx_Csr_BPL INTO Ln_BPL_OFS_Duration,Lv_BPL_OFS_UOM;

      CLOSE Lx_Csr_BPL;

      IF (Lv_BPL_OFS_UOM IS NOT NULL) AND (Ln_BPL_OFS_Duration IS NOT NULL) THEN

        Ld_BPL_OFS_Start  := OKC_Time_Util_Pub.Get_EndDate(P_Start_Date => Ld_SVL_Start
                                                        ,P_Timeunit   => Lv_BPL_OFS_UOM
                                                        ,P_Duration   => Ln_BPL_OFS_Duration);
        Ld_BPL_OFS_Start  := Ld_BPL_OFS_Start + 1;

      ELSE

        Ld_BPL_OFS_Start  := Ld_SVL_Start;

      END IF;

    ELSE

       Ld_BPL_OFS_Start  := p_BPL_Start;

    END IF;

    RETURN(Ld_BPL_OFS_Start);

  EXCEPTION

    WHEN OTHERS THEN

      IF Lx_Csr_BPL%ISOPEN THEN
        CLOSE Lx_Csr_BPL;
      END IF;

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME
	,P_Msg_Name	  => G_UNEXPECTED_ERROR
	,P_Token1	  => G_SQLCODE_TOKEN
	,P_Token1_Value	  => SQLCODE
	,P_Token2	  => G_SQLERRM_TOKEN
	,P_Token2_Value   => SQLERRM);


  END Get_BP_Line_Start_Offset;

-----------------------------------------------------------------------------------------------------------------------*

--
-- Added for 12.0 Coverage Rearch project (JVARGHES)
--

  FUNCTION Get_grace_end_Date
    (P_dnz_chr_Id	        IN NUMBER
    ,P_SVL_end       	  IN DATE
    ,P_BPL_end            IN DATE
    ,p_Std_Cov_YN         IN VARCHAR2) RETURN DATE
  IS

   ld_grace_end_date  DATE;
   ld_end_date        DATE;

  BEGIN

    IF p_Std_Cov_YN = 'Y' THEN
      ld_end_date  := P_SVL_end;
    ELSE
      ld_end_date  := P_BPL_end;
    END IF;

    ld_grace_end_date := get_final_end_date(p_dnz_chr_id,ld_end_date);

    RETURN(ld_grace_end_date);

  EXCEPTION

    WHEN OTHERS THEN

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME
	,P_Msg_Name	  => G_UNEXPECTED_ERROR
	,P_Token1	  => G_SQLCODE_TOKEN
	,P_Token1_Value	  => SQLCODE
	,P_Token2	  => G_SQLERRM_TOKEN
	,P_Token2_Value   => SQLERRM);

  END Get_grace_end_Date;


-----------------------------------------------------------------------------------------------------------------------*

  --Function Added For Bug#1409072
  -- commented ; warranty to be opened up for bill types and bill rates


  --Function Added For Bug#1409072
  -- commented ; warranty to be opened up for bill types and bill rates

 FUNCTION Get_Warranty_Flag(p_line_id IN Number) Return Varchar2 Is

    Cursor l_csr Is
    Select 'Y'
    From   okc_k_lines_b
    where  id = p_line_id
--    and    lse_id = 16;
    and    lse_id = 14;


    l_warranty_flag      Varchar2(1);

  BEGIN

    l_warranty_flag      := 'N';

    Open  l_csr;
    Fetch l_csr INTO l_warranty_flag;
    Close l_csr;

    Return(l_warranty_flag);

  END Get_Warranty_Flag;

  FUNCTION Get_Full_Discount(p_line_id IN Number,p_business_process_id in number,p_request_date in date,p_txn_grp_id in number) Return Varchar2 Is

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
/*

    Cursor l_bp_csr Is
    Select nvl(oksbpl.allow_bt_discount,'N') --'Y' -- fixed the 11.5.9 bug 3612660
    From   --okc_rules_b rul,
           --okc_rule_groups_b rgp,
           okc_k_lines_b bpl,
           oks_k_lines_b oksbpl, -- 11.5.10 rule rearchitecture changes
           okc_k_lines_b cov,
           okc_k_lines_b svl,
           okc_k_items cimbp
    where  svl.id = p_line_id
    and    cov.cle_id = svl.id
    and    cov.lse_id in (2,15,20)
    and    bpl.cle_id = cov.id
--    and    rgp.dnz_chr_id = bpl.dnz_chr_id
--    and    rgp.cle_id     = bpl.id
    and    bpl.id   = cimbp.cle_id
    and    cimbp.object1_id1 = to_char(p_business_process_id)
    and    trunc(p_request_date) >= trunc(bpl.start_date)
    and    trunc(p_request_date) <= trunc(get_final_end_date(bpl.dnz_chr_id,bpl.end_date))
    and    bpl.id    = oksbpl.cle_id;
--    and    oksbpl.allow_bt_discount is not null;
--    and    rgp.id = rul.rgp_id
--    and    rul.rule_information_category = 'BTD'

-- new cursor added as part of bug 3141819 to take care of backward compatibility
-- related to p_txn_grp_id

    Cursor l_txn_grp_csr Is
    Select nvl(oksbpl.allow_bt_discount,'N') --'Y' -- fixed the 11.5.9 bug 3612660
    From   --okc_rules_b rul,
           --okc_rule_groups_b rgp,
           okc_k_lines_b bpl,
           oks_k_lines_b oksbpl, -- 11.5.10 rule rearchitecture changes
           okc_k_lines_b cov,
           okc_k_lines_b svl
    where  svl.id = p_line_id
    and    cov.cle_id = svl.id
    and    cov.lse_id in (2,15,20)
    and    bpl.cle_id = cov.id
--    and    rgp.dnz_chr_id = bpl.dnz_chr_id
--    and    rgp.cle_id     = bpl.id
    and    bpl.id         = p_txn_grp_id --bug 3141819
    and    trunc(p_request_date) >= trunc(bpl.start_date)
    and    trunc(p_request_date) <= trunc(get_final_end_date(bpl.dnz_chr_id,bpl.end_date))
    and    bpl.id    = oksbpl.cle_id;
--    and    oksbpl.allow_bt_discount is not null;
--    and    rgp.id = rul.rgp_id
--    and    rul.rule_information_category = 'BTD'

*/

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
    -- Bug Fix #5369536. Added  hint.
    Cursor l_bp_csr Is
    Select /*+ leading(svl) use_nl(svl ksl bpl cimbp oksbpl) index(cimbp okc_k_items_n1) */
           nvl(oksbpl.allow_bt_discount,'N') --'Y' -- fixed the 11.5.9 bug 3612660
    From   okc_k_lines_b svl,
           oks_k_Lines_b ksl,
           okc_k_lines_b bpl,
           okc_k_items cimbp,
           oks_k_lines_b oksbpl -- 11.5.10 rule rearchitecture changes
    where  svl.id = p_line_id
    and    svl.lse_id in (1,14,19)
    and    ksl.cle_id = svl.id
    and    bpl.cle_id = ksl.coverage_id
    and    bpl.id   = cimbp.cle_id
    and    cimbp.object1_id1 = to_char(p_business_process_id)
    and    trunc(p_request_date) >= trunc(Get_BP_Line_Start_Offset(bpl.id,svl.start_date,bpl.start_date,ksl.Standard_Cov_YN))
    and    trunc(p_request_date) <= trunc(Get_grace_end_Date(ksl.dnz_chr_id,svl.end_date,bpl.end_date,ksl.Standard_Cov_YN))
    and    bpl.id    = oksbpl.cle_id;

-- new cursor added as part of bug 3141819 to take care of backward compatibility
-- related to p_txn_grp_id

    Cursor l_txn_grp_csr Is
    Select nvl(oksbpl.allow_bt_discount,'N') --'Y' -- fixed the 11.5.9 bug 3612660
    From   okc_k_lines_b bpl,
           oks_k_lines_b oksbpl, -- 11.5.10 rule rearchitecture changes
           okc_k_lines_b svl,
           oks_k_Lines_b ksl
    where  svl.id = p_line_id
    and    svl.lse_id in (1,14,19)
    and    ksl.cle_id = svl.id
    and    bpl.cle_id = ksl.coverage_id
    and    bpl.id         = p_txn_grp_id --bug 3141819
    and    trunc(p_request_date) >= trunc(Get_BP_Line_Start_Offset(bpl.id,svl.start_date,bpl.start_date,ksl.Standard_Cov_YN))
    and    trunc(p_request_date) <= trunc(Get_grace_end_Date(ksl.dnz_chr_id,svl.end_date,bpl.end_date,ksl.Standard_Cov_YN))
    and    bpl.id    = oksbpl.cle_id;

--
--
    l_full_discount_flag      Varchar2(1);

  BEGIN

    l_full_discount_flag      := 'N';


  -- new If clause added as part of bug 3141819 to take care of backward compatibility
  -- related to p_txn_grp_id

   if p_business_process_id is not null and p_request_date is not null then

    Open  l_bp_csr;
    Fetch l_bp_csr INTO l_full_discount_flag;
    Close l_bp_csr;

    Return(l_full_discount_flag);

   else

    Open  l_txn_grp_csr;
    Fetch l_txn_grp_csr INTO l_full_discount_flag;
    Close l_txn_grp_csr;

    Return(l_full_discount_flag);

   end if;

  END Get_Full_Discount;

  PROCEDURE populate_return_table(x_return_status 	OUT NOCOPY	 Varchar2,
					    p_as_tbl		IN	 g_work_tbl,
					    p_cover_disc	      OUT NOCOPY    cov_tbl_type)
  IS
	j 	Number;
  BEGIN
	j 	:= 1;

      x_return_status := G_RET_STS_SUCCESS;

	FOR i in p_as_tbl.FIRST..p_as_tbl.LAST
	LOOP
		p_cover_disc(j).charges_line_number	:= p_as_tbl(i).charges_line_number;
		p_cover_disc(j).estimate_detail_id	:= p_as_tbl(i).estimate_detail_id;
		p_cover_disc(j).contract_line_id	:= p_as_tbl(i).contract_line_id;
		p_cover_disc(j).txn_group_id		:= p_as_tbl(i).txn_group_id;
		p_cover_disc(j).billing_type_id	    := p_as_tbl(i).billing_type_id;
		p_cover_disc(j).discounted_amount	:= p_as_tbl(i).discounted_amount;
        p_cover_disc(j).status              := p_as_tbl(j).status;

        p_cover_disc(j).business_process_id	:= p_as_tbl(i).business_process_id;
        p_cover_disc(j).request_date        := p_as_tbl(j).request_date;

		j := j + 1;
	END LOOP;
  EXCEPTION
	WHEN OTHERS THEN
	  OKC_API.SET_MESSAGE( p_app_name	=> G_APP_NAME
				  ,p_msg_name	=> G_UNEXPECTED_ERROR
				  ,p_token1		=> G_SQLCODE_TOKEN
				  ,p_token1_value	=> SQLcode
				  ,p_token2		=> G_SQLERRM_TOKEN
				  ,p_token2_value	=> SQLerrm);

	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END populate_return_table;

  PROCEDURE populate_bt_table(x_return_status	OUT NOCOPY     Varchar2,
					          p_txngrp_id		IN  	 Number,
                              p_bill_type_id     IN     Number,
                              p_contract_line_id in number,
                              p_business_process_id IN number,
                              p_request_date        IN date,
					          x_out_tbl		IN OUT NOCOPY g_out_tbl)
  IS

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
/*
  CURSOR l_bp_bt_csr IS
   select   btl.ID		BTYPE_ID,
	    btl.CLE_ID	       	TXNGRP_ID,
	    oksbtl.discount_amount	UPTO_AMT,
	    oksbtl.discount_percent PER_CVD
   from     okc_k_lines_b svl,
            okc_k_lines_b cov,
            okc_k_lines_b bpl,
            okc_k_lines_b btl,
            oks_k_lines_b oksbtl, --11.5.10 rule reachitecture changes
            okc_k_items   cimbp,
            okc_k_items   cimbt
--            okc_rule_groups_b rgp,
--            okc_rules_b rul
    where   svl.id = p_contract_line_id
    and     cov.cle_id = svl.id
    and     cov.lse_id in (2,15,20)
    and     bpl.cle_id = cov.id
    and     bpl.id   = cimbp.cle_id
    and     cimbp.object1_id1 = to_char(p_business_process_id)
    and     trunc(p_request_date) >= trunc(bpl.start_date)
    and     trunc(p_request_date) <= trunc(get_final_end_date(bpl.dnz_chr_id,bpl.end_date))
    and     btl.cle_id = bpl.id
    and     btl.id    = cimbt.cle_id
    and     cimbt.object1_id1 = to_char(p_bill_type_id)
    and     oksbtl.cle_id  = btl.id; --11.5.10 addition
--    and     btl.id = rgp.cle_id
--    and     rgp.id = rul.rgp_id
--    and     rul.rule_information_category  = 'LMT';

  CURSOR l_txngrp_bt_csr IS
   select   btl.ID	BTYPE_ID,
	    btl.CLE_ID	      	TXNGRP_ID,
	    oksbtl.discount_amount	UPTO_AMT,
	    oksbtl.discount_percent PER_CVD
   from     okc_k_lines_b svl,
            okc_k_lines_b cov,
            okc_k_lines_b bpl,
            okc_k_lines_b btl,
            oks_k_lines_b oksbtl, --11.5.10 rule reachitecture changes
            okc_k_items   cimbt
--            okc_rule_groups_b rgp,
--            okc_rules_b rul
    where   svl.id = p_contract_line_id
    and     cov.cle_id = svl.id
    and     cov.lse_id in (2,15,20)
    and     bpl.cle_id = cov.id
    and     bpl.id   = p_txngrp_id
    and     trunc(p_request_date) >= trunc(bpl.start_date)
    and     trunc(p_request_date) <= trunc(get_final_end_date(bpl.dnz_chr_id,bpl.end_date))
    and     btl.cle_id = bpl.id
    and     btl.id    = cimbt.cle_id
    and     cimbt.object1_id1 = to_char(p_bill_type_id)
    and     oksbtl.cle_id  = btl.id; --11.5.10 addition
--    and     btl.id = rgp.cle_id
--    and     rgp.id = rul.rgp_id
--    and     rul.rule_information_category  = 'LMT';

*/

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--


  CURSOR l_bp_bt_csr IS
   select   btl.ID		BTYPE_ID,
	    btl.CLE_ID	       	TXNGRP_ID,
	    oksbtl.discount_amount	UPTO_AMT,
	    oksbtl.discount_percent PER_CVD
   from     okc_k_lines_b svl,
            okc_k_lines_b bpl,
            okc_k_lines_b btl,
            oks_k_lines_b oksbtl, --11.5.10 rule reachitecture changes
            okc_k_items   cimbp,
            okc_k_items   cimbt
            ,OKS_K_LINES_B ksl

    where   svl.id = p_contract_line_id
    and     svl.lse_id in (1,14,19)
    and     ksl.cle_id = svl.id
    and     bpl.cle_id = ksl.coverage_id
    and     bpl.id   = cimbp.cle_id
    and     cimbp.object1_id1 = to_char(p_business_process_id)
    and     trunc(p_request_date) >= trunc(Get_BP_Line_Start_Offset(bpl.id, svl.start_date, bpl.start_date, KSL.Standard_Cov_YN))
    and     trunc(p_request_date) <= trunc(Get_grace_end_Date(svl.dnz_chr_id, svl.end_date, bpl.end_date,KSL.Standard_Cov_YN))
    and     btl.cle_id = bpl.id
    and     btl.id    = cimbt.cle_id
    and     cimbt.object1_id1 = to_char(p_bill_type_id)
    and     oksbtl.cle_id  = btl.id; --11.5.10 addition

  CURSOR l_txngrp_bt_csr IS
   select   btl.ID	BTYPE_ID,
	    btl.CLE_ID	      	TXNGRP_ID,
	    oksbtl.discount_amount	UPTO_AMT,
	    oksbtl.discount_percent PER_CVD
   from     okc_k_lines_b svl,
            okc_k_lines_b bpl,
            okc_k_lines_b btl,
            oks_k_lines_b oksbtl, --11.5.10 rule reachitecture changes
            okc_k_items   cimbt
            ,OKS_K_LINES_B ksl

    where   svl.id = p_contract_line_id
    and     svl.lse_id in (1,14,19)
    and     ksl.cle_id = svl.id
    and     bpl.cle_id = ksl.coverage_id
    and     bpl.id   = p_txngrp_id
    and     trunc(p_request_date) >= trunc(Get_BP_Line_Start_Offset(bpl.id, svl.start_date, bpl.start_date, KSL.Standard_Cov_YN))
    and     trunc(p_request_date) <= trunc(Get_grace_end_Date(svl.dnz_chr_id, svl.end_date, bpl.end_date,KSL.Standard_Cov_YN))
    and     btl.cle_id = bpl.id
    and     btl.id    = cimbt.cle_id
    and     cimbt.object1_id1 = to_char(p_bill_type_id)
    and     oksbtl.cle_id  = btl.id; --11.5.10 addition

--
--

    rec_found   Varchar2(1);
	j	      Number;
  BEGIN
      rec_found   := 'F';

      x_return_status := G_RET_STS_SUCCESS;

      IF x_out_tbl.COUNT = 0 THEN
         j := 1;
      ELSE
         j := x_out_tbl.COUNT + 1;
      END IF;

    -- bug 3141819 .. added new cursor to take care of backward compatibility
    -- related to p_txngrp_id

    IF p_business_process_id is not null and p_request_date is not null then

	  FOR i in l_bp_bt_csr
	  LOOP

        rec_found := 'T';

        if ((j =1) or (j = x_out_tbl.COUNT + 1)) then
            null;
        else
            j := j + 1;
        end if;

		x_out_tbl(j).txngrp_id := i.txngrp_id;
		x_out_tbl(j).btype_id  := i.btype_id;

		x_out_tbl(j).upto_amt  := i.upto_amt;
		x_out_tbl(j).per_cvd   := i.per_cvd;

	  --	j := j + 1;
	  END LOOP;

    ELSE

	  FOR i in l_txngrp_bt_csr
	  LOOP

             rec_found := 'T';

        if ((j =1) or (j = x_out_tbl.COUNT + 1)) then
            null;
        else
            j := j + 1;
        end if;

		x_out_tbl(j).txngrp_id := i.txngrp_id;
		x_out_tbl(j).btype_id  := i.btype_id;

		x_out_tbl(j).upto_amt  := i.upto_amt;
		x_out_tbl(j).per_cvd   := i.per_cvd;

	  --	j := j + 1;
	  END LOOP;

    END IF;

      IF rec_found = 'F' THEN
         --x_out_tbl(j).txngrp_id := 'F';
         x_out_tbl(j).status := 'F';
      ELSIF rec_found = 'T' THEN
         x_out_tbl(j).status := 'T';
      END IF;

  EXCEPTION
	WHEN OTHERS THEN
	  OKC_API.SET_MESSAGE( p_app_name	=> G_APP_NAME
				  ,p_msg_name	=> G_UNEXPECTED_ERROR
				  ,p_token1		=> G_SQLCODE_TOKEN
				  ,p_token1_value	=> SQLcode
				  ,p_token2		=> G_SQLERRM_TOKEN
				  ,p_token2_value	=> SQLerrm);

	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END populate_bt_table;

  PROCEDURE populate_work_table(x_return_status OUT NOCOPY	Varchar2,
					  p_as_tbl		IN	ser_tbl_type,
					  x_as_tbl		OUT NOCOPY	g_work_tbl)
  IS
	j 	Number;
  BEGIN
	j 	:= 1;

      x_return_status := G_RET_STS_SUCCESS;

	FOR i in p_as_tbl.FIRST..p_as_tbl.LAST
	LOOP
		x_as_tbl(j).seq_no 			    := j;
		x_as_tbl(j).Charges_line_number	:= p_as_tbl(i).Charges_line_number;
		x_as_tbl(j).estimate_detail_id	:= p_as_tbl(i).estimate_detail_id;
		x_as_tbl(j).contract_line_id	:= p_as_tbl(i).contract_line_id;
		x_as_tbl(j).txn_group_id		:= p_as_tbl(i).txn_group_id;
		x_as_tbl(j).billing_type_id		:= p_as_tbl(i).billing_type_id;
		x_as_tbl(j).charge_amount		:= p_as_tbl(i).charge_amount;
        x_as_tbl(j).business_process_id	:= p_as_tbl(i).business_process_id;
      x_as_tbl(j).request_date		:= nvl(p_as_tbl(i).request_date,sysdate);  --p_as_tbl(i).request_date;

            --Warranty Flag Added For Bug#1409072
  -- commented ; warranty to be opened up for bill types and bill rates
--            x_as_tbl(j).warranty_flag           := Get_Warranty_Flag(p_line_id => p_as_tbl(i).txn_group_id);

        x_as_tbl(j).warranty_flag       := Get_Warranty_Flag(p_line_id => p_as_tbl(i).contract_line_id);
        if x_as_tbl(j).warranty_flag = 'Y' then
          x_as_tbl(j).allow_full_discount := Get_Full_discount(p_as_tbl(i).contract_line_id,p_as_tbl(i).business_process_id
                                                               ,p_as_tbl(i).request_date,p_as_tbl(i).txn_group_id);
        end if;

		j := j + 1;
	END LOOP;
  EXCEPTION
	WHEN OTHERS THEN
	  OKC_API.SET_MESSAGE( p_app_name	=> G_APP_NAME
				  ,p_msg_name	=> G_UNEXPECTED_ERROR
				  ,p_token1		=> G_SQLCODE_TOKEN
				  ,p_token1_value	=> SQLcode
				  ,p_token2		=> G_SQLERRM_TOKEN
				  ,p_token2_value	=> SQLerrm);

	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END populate_work_table;

  PROCEDURE apply_contract_coverage
	(p_api_version            IN  Number
	,p_init_msg_list          IN  Varchar2
      ,p_est_amt_tbl            IN  ser_tbl_type
	,x_return_status          OUT NOCOPY Varchar2
	,x_msg_count              OUT NOCOPY Number
	,x_msg_data               OUT NOCOPY Varchar2
	,x_est_discounted_amt_tbl OUT NOCOPY cov_tbl_type)
  IS

	l_as_tbl		 g_work_tbl;
	x_as_tbl		 g_work_tbl;
	l_old_tgid		 Number;
	l_old_btid		 Number;
	x_out_tbl		 g_out_tbl;
	l_pre_dis		 Number;
	l_dis_amt		 Number;
      l_serv_disc        ser_tbl_type;
      l_cover_disc       cov_tbl_type;

  BEGIN

	l_old_tgid		 := -99;
	l_old_btid		 := -99;

      x_return_status := G_RET_STS_SUCCESS;

      l_serv_disc := p_est_amt_tbl;

	populate_work_table(x_return_status, l_serv_disc, x_as_tbl);

	IF x_return_status <> G_RET_STS_SUCCESS THEN
		RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;
	l_as_tbl := x_as_tbl;

    For i in l_as_tbl.FIRST..l_as_tbl.LAST LOOP
  -- commented ; warranty to be opened up for bill types and bill rates
--   IF l_as_tbl(i).warranty_flag <> 'Y' then --Added For Bug#1409072


        -- following if clause removed because it is possible to send multiple records with
        -- the same l_as_tbl(i).txn_group_id

	--IF l_old_tgid <> l_as_tbl(i).txn_group_id THEN
	--	l_old_tgid := l_as_tbl(i).txn_group_id;

  -- 11.5.9 changes

			populate_bt_table(x_return_status,
                              l_as_tbl(i).txn_group_id,
                              l_as_tbl(i).billing_type_id,
                              l_as_tbl(i).contract_line_id,
                              l_as_tbl(i).business_process_id,
                              l_as_tbl(i).request_date,
                              x_out_tbl);

			IF x_return_status <> G_RET_STS_SUCCESS THEN
				RAISE G_EXCEPTION_HALT_VALIDATION;
			END IF;
--	END IF;
  -- commented ; warranty to be opened up for bill types and bill rates
--   END IF; --Added For Bug#1409072
  END LOOP;

	FOR i in l_as_tbl.FIRST..l_as_tbl.LAST
	LOOP
  -- commented ; warranty to be opened up for bill types and bill rates
--        IF l_as_tbl(i).warranty_flag <> 'Y' then -- Added For Bug#1409072

       IF l_as_tbl(i).warranty_flag <> 'Y' OR -- not a warranty
          l_as_tbl(i).warranty_flag = 'Y' AND x_out_tbl(i).status <> 'F' then -- warranty with records exist

	   IF l_old_btid <> l_as_tbl(i).billing_type_id
	   THEN
-- #1750003
             l_old_btid	:= l_as_tbl(i).billing_type_id;

             if x_out_tbl(i).per_cvd is NULL and x_out_tbl(i).upto_amt is NULL then
               l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount;
             elsif x_out_tbl(i).per_cvd = 0 then
               l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount;
             elsif x_out_tbl(i).upto_amt = 0 then
               l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount;
             elsif x_out_tbl(i).per_cvd is NULL and x_out_tbl(i).upto_amt is not NULL then
               l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount - x_out_tbl(i).upto_amt;
             elsif x_out_tbl(i).per_cvd is not NULL and x_out_tbl(i).upto_amt is NULL then
               l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount * (1 - x_out_tbl(i).per_cvd/100);
             elsif x_out_tbl(i).per_cvd is not NULL and x_out_tbl(i).upto_amt is not NULL then
	           l_dis_amt := l_as_tbl(i).charge_amount * x_out_tbl(i).per_cvd / 100;
	           if l_dis_amt < x_out_tbl(i).upto_amt then
		          l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount - l_dis_amt;
	           else
		          l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount - x_out_tbl(i).upto_amt;
	           end if;
             end if;

--#1853256             if l_as_tbl(i).discounted_amount < 0 then
--               l_as_tbl(i).discounted_amount := 0;
--             end if;

	   ELSE
-- #1750003
             if x_out_tbl(i).per_cvd is NULL and x_out_tbl(i).upto_amt is NULL then
               l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount;
             elsif x_out_tbl(i).per_cvd = 0 then
               l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount;
             elsif x_out_tbl(i).upto_amt = 0 then
               l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount;
             elsif x_out_tbl(i).per_cvd is NULL and x_out_tbl(i).upto_amt is not NULL then
               l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount - x_out_tbl(i).upto_amt;
             elsif x_out_tbl(i).per_cvd is not NULL and x_out_tbl(i).upto_amt is NULL then
               l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount * (1 - x_out_tbl(i).per_cvd/100);
             elsif x_out_tbl(i).per_cvd is not NULL and x_out_tbl(i).upto_amt is not NULL then
	           l_dis_amt := l_as_tbl(i).charge_amount * x_out_tbl(i).per_cvd / 100;
	           if l_dis_amt < x_out_tbl(i).upto_amt then
		          l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount - l_dis_amt;
	           else
		          l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount - x_out_tbl(i).upto_amt;
	           end if;
             end if;

--#1853256             if l_as_tbl(i).discounted_amount < 0 then
--               l_as_tbl(i).discounted_amount := 0;
--             end if;

	   END IF;
         l_as_tbl(i).status := x_out_tbl(i).status;
  -- commented ; warranty to be opened up for bill types and bill rates
--        ELSE --Added For Bug#1409072
  --        l_as_tbl(i).discounted_amount := 0;
--        END IF; --Added For Bug#1409072

       ELSIF l_as_tbl(i).warranty_flag = 'Y' AND x_out_tbl(i).status = 'F' then --warranty and no record exists
          IF l_as_tbl(i).allow_full_discount = 'Y' then
                l_as_tbl(i).discounted_amount := 0;
          ELSE
                l_as_tbl(i).discounted_amount := l_as_tbl(i).charge_amount;
          END IF;
       END IF;

	END LOOP;

	populate_return_table(x_return_status, l_as_tbl, l_cover_disc);

	IF x_return_status <> G_RET_STS_SUCCESS THEN
		RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;
      x_est_discounted_amt_tbl := l_cover_disc;

  EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
		Null;
	WHEN OTHERS THEN
	  OKC_API.SET_MESSAGE( p_app_name	=> G_APP_NAME
				  ,p_msg_name	=> G_UNEXPECTED_ERROR
				  ,p_token1		=> G_SQLCODE_TOKEN
				  ,p_token1_value	=> SQLcode
				  ,p_token2		=> G_SQLERRM_TOKEN
				  ,p_token2_value	=> SQLerrm);

	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END apply_contract_coverage;

  PROCEDURE get_bp_pricelist
	(p_api_version	        IN  Number
	,p_init_msg_list	        IN  Varchar2
    ,p_Contract_line_id		IN NUMBER
    ,p_business_process_id  IN NUMBER
    ,p_request_date         IN DATE
	,x_return_status 	        OUT NOCOPY Varchar2
	,x_msg_count	        OUT NOCOPY Number
	,x_msg_data		        OUT NOCOPY Varchar2
	,x_pricing_tbl		    OUT NOCOPY PRICING_TBL_TYPE )
  IS

/*
    CURSOR get_bp_pre_dst (p_cle_id in number)IS
    select  rul.rule_information_category ,
            rul.object1_id1
    from    okc_rules_b rul,
            okc_rule_groups_b rgp
    where   rgp.id = rul.rgp_id
    and     rul.rule_information_category in ('PRE','DST')
    and     rgp.cle_id = p_cle_id;

    CURSOR get_khdr_pre (p_chr_id in number) IS
    select  rul.rule_information_category ,
            rul.object1_id1
    from    okc_rules_b rul,
            okc_rule_groups_b rgp
    where   rgp.id = rul.rgp_id
    and     rul.rule_information_category in ('PRE')
    and     rgp.chr_id = p_chr_id;
*/

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
/*
    CURSOR get_cov_bp_line(p_contract_line_id in number,p_business_process_id in number,
				   p_request_date in date)
IS
    select  bpl.id,
            bpl.dnz_chr_id,
            cimbp.object1_id1,
            bpl.start_date bpl_start_date,
            bpl.end_date bpl_end_date,
            bpl.price_list_id bpl_pre,
            oksbpl.discount_list oksbpl_dst,
            chr.price_list_id chr_pre
    from    okc_k_lines_b svl,
            okc_k_lines_b cov,
            okc_k_lines_b bpl,
            oks_k_lines_b oksbpl,
            okc_k_items   cimbp,
            okc_k_headers_b chr -- 11.5.10 addition
    where   svl.id = p_contract_line_id
    and     svl.chr_id = chr.id -- 11.5.10 addition
    and     cov.cle_id = svl.id
    and     cov.lse_id in (2,15,20)
    and     bpl.cle_id = cov.id
    and     oksbpl.cle_id = bpl.id
    and     bpl.id   = cimbp.cle_id
    and     cimbp.object1_id1 = nvl(to_char(p_business_process_id),cimbp.object1_id1)
    and     trunc(p_request_date) >= trunc(bpl.start_date)
    and     trunc(p_request_date) <= trunc(get_final_end_date(bpl.dnz_chr_id,bpl.end_date));
*/
--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--

    CURSOR get_cov_bp_line(p_contract_line_id in number,p_business_process_id in number,
				   p_request_date in date)
IS
    select  bpl.id,
            bpl.dnz_chr_id,
            cimbp.object1_id1,
            bpl.start_date bpl_start_date,
            bpl.end_date bpl_end_date,
            bpl.price_list_id bpl_pre,
            oksbpl.discount_list oksbpl_dst,
            chr.price_list_id chr_pre
    from    okc_k_lines_b svl,
            okc_k_lines_b bpl,
            oks_k_lines_b oksbpl,
            okc_k_items   cimbp,
            okc_k_headers_all_b chr  -- Modified for 12.0 MOAC project (JVARGHES)
           , oks_k_lines_b ksl
    where   svl.id = p_contract_line_id
    and     svl.lse_id in (1,14,19)
    and     ksl.cle_id  = svl.id
    and     svl.chr_id = chr.id -- 11.5.10 addition
    and     bpl.cle_id = ksl.coverage_id
    and     oksbpl.cle_id = bpl.id
    and     bpl.id   = cimbp.cle_id
    and     cimbp.object1_id1 = nvl(to_char(p_business_process_id),cimbp.object1_id1)
    and    trunc(p_request_date) >= trunc(Get_BP_Line_Start_Offset(bpl.id,svl.start_date,bpl.start_date,ksl.Standard_Cov_YN))
    and    trunc(p_request_date) <= trunc(Get_grace_end_Date(ksl.dnz_chr_id,svl.end_date,bpl.end_date,ksl.Standard_Cov_YN));

--
--

  l_request_date			date;
  l_contract_line_id    	number;
  l_business_process_id 	number;

  BEGIN

  l_request_date			:= nvl(p_request_date,trunc(sysdate));
  l_contract_line_id    	:= p_contract_line_id;
  l_business_process_id 	:= p_business_process_id;



    for cov_bp_line_rec in get_cov_bp_line(l_contract_line_id,l_business_process_id,l_request_date) loop

        x_pricing_tbl(1).contract_line_id           := p_contract_line_id;
        x_pricing_tbl(1).business_process_id        := cov_bp_line_rec.object1_id1; --p_business_process_id;
        x_pricing_tbl(1).BP_start_date              := cov_bp_line_rec.bpl_start_date;
        x_pricing_tbl(1).BP_end_date                := cov_bp_line_rec.bpl_end_date;
        x_pricing_tbl(1).BP_Price_list_id           := cov_bp_line_rec.bpl_pre;
        x_pricing_tbl(1).Contract_Price_list_Id     := cov_bp_line_rec.chr_pre;
        x_pricing_tbl(1).BP_Discount_id             := cov_bp_line_rec.oksbpl_dst;


    end loop;


    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
		Null;
	WHEN OTHERS THEN
	  OKC_API.SET_MESSAGE( p_app_name	=> G_APP_NAME
				  ,p_msg_name	=> G_UNEXPECTED_ERROR
				  ,p_token1		=> G_SQLCODE_TOKEN
				  ,p_token1_value	=> SQLcode
				  ,p_token2		=> G_SQLERRM_TOKEN
				  ,p_token2_value	=> SQLerrm);

	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END get_bp_pricelist;

 PROCEDURE get_bill_rates
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,P_input_br_rec         IN INPUT_BR_REC
    ,P_labor_sch_tbl        IN LABOR_SCH_TBL_TYPE
    ,x_return_status        OUT NOCOPY Varchar2
    ,x_msg_count            OUT NOCOPY Number
    ,x_msg_data             OUT NOCOPY Varchar2
    ,X_bill_rate_tbl        OUT NOCOPY BILL_RATE_TBL_TYPE )
  IS

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
/*

    cursor get_btl_id (p_cont_line_id in number,p_busi_proc_id in number,
                        p_txn_bill_type_id in number,p_request_date in date) IS
    select  btl.id btl_id
    from    okc_k_lines_b svl,
            okc_k_lines_b cov,
            okc_k_lines_b bpl,
            okc_k_items cimbp,
            okc_k_lines_b btl,
            okc_k_items cimbt
    where   svl.id  = p_cont_line_id
    and     cov.cle_id = svl.id
    and     cov.lse_id in (2,15,20)
    and     bpl.cle_id = cov.id
    and     bpl.id      = cimbp.cle_id
    and     trunc(nvl(p_request_date,sysdate)) >= trunc(bpl.start_date)
    and     trunc(nvl(p_request_date,sysdate)) <= trunc(get_final_end_date(bpl.dnz_chr_id,bpl.end_date))
    and     cimbp.object1_id1 = to_char(p_busi_proc_id)
    and     btl.cle_id = bpl.id
    and     btl.lse_id in (5,59,23)
    and     btl.id = cimbt.cle_id
    and     cimbt.object1_id1 = to_char(p_txn_bill_type_id);
*/

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--

    cursor get_btl_id (p_cont_line_id in number,p_busi_proc_id in number,
                        p_txn_bill_type_id in number,p_request_date in date) IS
    select  btl.id btl_id
    from    okc_k_lines_b svl,
            okc_k_lines_b bpl,
            okc_k_items cimbp,
            okc_k_lines_b btl,
            okc_k_items cimbt,
            oks_k_lines_b ksl
    where   svl.id  = p_cont_line_id
    and     svl.lse_id in (1,14,19)
    and     ksl.cle_id = svl.id
    and     bpl.cle_id = ksl.coverage_id
    and     bpl.id      = cimbp.cle_id
    and    trunc(nvl(p_request_date,sysdate)) >= trunc(Get_BP_Line_Start_Offset(bpl.id,svl.start_date,bpl.start_date,ksl.Standard_Cov_YN))
    and    trunc(nvl(p_request_date,sysdate)) <= trunc(Get_grace_end_Date(ksl.dnz_chr_id,svl.end_date,bpl.end_date,ksl.Standard_Cov_YN))
    and     cimbp.object1_id1 = to_char(p_busi_proc_id)
    and     btl.cle_id = bpl.id
    and     btl.lse_id in (5,59,23)
    and     btl.id = cimbt.cle_id
    and     cimbt.object1_id1 = to_char(p_txn_bill_type_id);

--
--
    cursor get_br_sch (p_btl_id in number,p_sunday_flag in varchar2,p_monday_flag in varchar2,
                            p_tuesday_flag in varchar2,p_wednesday_flag in varchar2,
                            p_thursday_flag in varchar2,p_friday_flag in varchar2,
                            p_saturday_flag in varchar2,p_holiday_flag in varchar2) IS
    select  ID,
            CLE_ID,
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
            UOM,
            FLAT_RATE,
            PERCENT_OVER_LIST_PRICE,
            HOLIDAY_YN,
            BT_CLE_ID
    from    oks_billrate_schedules
    where   bt_cle_id   = p_btl_id
    and     (
             decode(p_sunday_flag,'Y',sunday_flag,'N','#') = decode(p_sunday_flag,'Y','Y','N','#') and
             decode(p_monday_flag,'Y',monday_flag,'N','#') = decode(p_monday_flag,'Y','Y','N','#') and
             decode(p_tuesday_flag,'Y',tuesday_flag,'N','#') = decode(p_tuesday_flag,'Y','Y','N','#') and
             decode(p_wednesday_flag,'Y',wednesday_flag,'N','#') = decode(p_wednesday_flag,'Y','Y','N','#') and
             decode(p_thursday_flag,'Y',thursday_flag,'N','#') = decode(p_thursday_flag,'Y','Y','N','#') and
             decode(p_friday_flag,'Y',friday_flag,'N','#') = decode(p_friday_flag,'Y','Y','N','#') and
             decode(p_saturday_flag,'Y',saturday_flag,'N','#') = decode(p_saturday_flag,'Y','Y','N','#')
             )
    and     nvl(holiday_yn,'N') = p_holiday_flag
    order   by start_hour,start_minute;

    TYPE br_sch_tbl_type IS TABLE OF get_br_sch%ROWTYPE INDEX BY BINARY_INTEGER;
    br_sch_tbl    		 br_sch_tbl_type;

    L_labor_sch_tbl        LABOR_SCH_TBL_TYPE;
    L_input_br_rec         INPUT_BR_REC;

    l_bt_cle_id            number;
    l_wkday_start          varchar2(30);
    l_wkday_end            varchar2(30);
    l_wkday_searched       varchar2(30);
    l_wkday_st_searched    varchar2(30);
    l_wkday_ed_searched    varchar2(30);
    l_sunday_flag          varchar2(1);
    l_monday_flag          varchar2(1);
    l_tuesday_flag         varchar2(1);
    l_wednesday_flag       varchar2(1);
    l_thursday_flag        varchar2(1);
    l_friday_flag          varchar2(1);
    l_saturday_flag        varchar2(1);

    l_holiday_flag         varchar2(1);

    L_bill_rate_tbl        BILL_RATE_TBL_TYPE;
    L_bill_rate_tbl1       BILL_RATE_TBL_TYPE;   --Bug# 4194507 (JVARGHES)
    L_bill_ratesorted_tbl  BILL_RATE_TBL_TYPE;

    br_ctr                 number;
    l_start_numtime        number;
    l_end_numtime          number;
    l_rec_start_numtime    number;
    l_rec_end_numtime      number;
    l_prevrec_end_numtime  number;
    l_prevrec_end_hour     number;
    l_prevrec_end_minute   number;
    l_datetime_searched    date;
    wkday_ctr              number;
    l_calchour             number;
    l_calcmin              number;
    j			         number;
    br_sch_st_edctr        number;
    br_sch_betwkday_ctr    number;
    Lx_Result              Gx_Boolean;
    Lx_Return_Status       Gx_Ret_Sts;

    L_EXCEP_UNEXPECTED_ERR EXCEPTION;

  BEGIN

    L_labor_sch_tbl        := P_labor_sch_tbl;
    L_input_br_rec         := P_input_br_rec;

    l_bt_cle_id            := NULL;
    l_wkday_start          := NULL;
    l_wkday_end            := NULL;
    l_wkday_searched       := NULL;
    l_wkday_st_searched    := NULL;
    l_wkday_ed_searched    := NULL;
    l_sunday_flag          := NULL;
    l_monday_flag          := NULL;
    l_tuesday_flag         := NULL;
    l_wednesday_flag       := NULL;
    l_thursday_flag        := NULL;
    l_friday_flag          := NULL;
    l_saturday_flag        := NULL;

    l_holiday_flag         := NULL;

    br_ctr                 := 0;
    l_start_numtime        := 0;
    l_end_numtime          := 0;
    l_rec_start_numtime    := 0;
    l_rec_end_numtime      := 0;
    l_prevrec_end_numtime  := 0;
    l_prevrec_end_hour     := 0;
    l_prevrec_end_minute   := 0;

    wkday_ctr              := 0;
    l_calchour             := 0;
    l_calcmin              := 0;
    j			         := 0;
    br_sch_st_edctr        := 0;
    br_sch_betwkday_ctr    := 0;
    Lx_Result              := G_TRUE;
    Lx_Return_Status       := G_RET_STS_SUCCESS;


    for btl_id_rec in get_btl_id(L_input_br_rec.contract_line_id,L_input_br_rec.Business_process_id,
                                 L_input_br_rec.txn_billing_type_id,L_input_br_rec.request_date) loop

        l_bt_cle_id := btl_id_rec.btl_id;

    end loop;


    for i in L_labor_sch_tbl.FIRST..L_labor_sch_tbl.LAST loop

      -- taking care of bill rate schedules whose weekdays are same as weekday of the request start/end datetime

            l_wkday_st_searched    := to_char(L_labor_sch_tbl(i).start_datetime,'DY');
            l_wkday_ed_searched    := to_char(L_labor_sch_tbl(i).end_datetime,'DY');

            l_start_numtime := to_number(to_char(L_labor_sch_tbl(i).start_datetime,'HH24'))*60+
                            to_number(to_char(L_labor_sch_tbl(i).start_datetime,'MI'));

            l_end_numtime   := to_number(to_char(L_labor_sch_tbl(i).end_datetime,'HH24'))*60+
                            to_number(to_char(L_labor_sch_tbl(i).end_datetime,'MI'));



            l_sunday_flag          := 'N';
            l_monday_flag          := 'N';
            l_tuesday_flag         := 'N';
            l_wednesday_flag       := 'N';
            l_thursday_flag        := 'N';
            l_friday_flag          := 'N';
            l_saturday_flag        := 'N';

            l_holiday_flag         := L_labor_sch_tbl(i).Holiday_flag;

            if l_wkday_st_searched = 'SUN' then
                l_sunday_flag          := 'Y';
            elsif l_wkday_st_searched = 'MON' then
                l_monday_flag          := 'Y';
            elsif l_wkday_st_searched = 'TUE' then
                l_tuesday_flag         := 'Y';
            elsif l_wkday_st_searched = 'WED' then
                l_wednesday_flag       := 'Y';
            elsif l_wkday_st_searched = 'THU' then
                l_thursday_flag        := 'Y';
            elsif l_wkday_st_searched = 'FRI' then
                l_friday_flag          := 'Y';
            elsif l_wkday_st_searched = 'SAT' then
                l_saturday_flag        := 'Y';
            end if;


            for br_sch_Rec in  get_br_sch (l_bt_cle_id,l_sunday_flag,l_monday_flag,
                            l_tuesday_flag,l_wednesday_flag,
                            l_thursday_flag,l_friday_flag,
                            l_saturday_flag,l_holiday_flag) loop



                l_rec_start_numtime   := br_sch_Rec.start_hour*60+br_sch_Rec.start_minute;

                l_rec_end_numtime     := br_sch_Rec.end_hour*60+br_sch_Rec.end_minute;

	          if l_wkday_st_searched = l_wkday_ed_searched then

                  if ( l_start_numtime between l_rec_start_numtime and l_rec_end_numtime) OR
                     ( l_end_numtime between l_rec_start_numtime and l_rec_end_numtime) OR
                     ( l_start_numtime <= l_rec_start_numtime and l_end_numtime >= l_rec_end_numtime) then

				      j			:= j+1;
				      br_sch_tbl(j)     := br_sch_rec;

			      end if;

		      else

			      if ( l_start_numtime between l_rec_start_numtime and l_rec_end_numtime) OR
                      ( l_start_numtime <= l_rec_start_numtime ) then

				        j			:= j+1;
				        br_sch_tbl(j)     := br_sch_rec;

			      end if;

		      end if;

		   end loop;

		   br_sch_st_edctr        := j;

           if l_wkday_st_searched  <> l_wkday_ed_searched  then


		    l_sunday_flag          := 'N';
            l_monday_flag          := 'N';
            l_tuesday_flag         := 'N';
            l_wednesday_flag       := 'N';
            l_thursday_flag        := 'N';
            l_friday_flag          := 'N';
            l_saturday_flag        := 'N';

            if l_wkday_ed_searched = 'SUN' then
                l_sunday_flag          := 'Y';
            elsif l_wkday_ed_searched = 'MON' then
                l_monday_flag          := 'Y';
            elsif l_wkday_ed_searched = 'TUE' then
                l_tuesday_flag         := 'Y';
            elsif l_wkday_ed_searched = 'WED' then
                l_wednesday_flag       := 'Y';
            elsif l_wkday_ed_searched = 'THU' then
                l_thursday_flag        := 'Y';
            elsif l_wkday_ed_searched = 'FRI' then
                l_friday_flag          := 'Y';
            elsif l_wkday_ed_searched = 'SAT' then
                l_saturday_flag        := 'Y';
            end if;

            for br_sch_Rec in  get_br_sch (l_bt_cle_id,l_sunday_flag,l_monday_flag,
                            l_tuesday_flag,l_wednesday_flag,
                            l_thursday_flag,l_friday_flag,
                            l_saturday_flag,l_holiday_flag) loop


                l_rec_start_numtime   := br_sch_Rec.start_hour*60+br_sch_Rec.start_minute;

                l_rec_end_numtime     := br_sch_Rec.end_hour*60+br_sch_Rec.end_minute;

                if ( l_end_numtime between l_rec_start_numtime and l_rec_end_numtime) OR
                   ( l_end_numtime >= l_rec_end_numtime) then

				     j			:= j+1;
				     br_sch_tbl(j)     := br_sch_rec;

  		        end if;

		    end loop;

		    end if;

 		    j	:= 0;

            if br_sch_tbl.count > 0 then
            for k in br_sch_tbl.first..br_sch_tbl.last loop

                l_rec_start_numtime   := br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute;

                l_rec_end_numtime     := br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute;

                br_ctr  := br_ctr + 1;

		    if k = 1 and br_sch_st_edctr <> 0 then

                  if  l_start_numtime between l_rec_start_numtime and l_rec_end_numtime then

                        L_bill_rate_tbl(br_ctr).start_datetime := L_labor_sch_tbl(i).start_datetime;

                  elsif  l_start_numtime <= l_rec_start_numtime then

                        L_bill_rate_tbl(br_ctr).start_datetime :=
                           to_date(to_char(L_labor_sch_tbl(i).start_datetime,'YYYY/MM/DD')||' '||
                                to_char(br_sch_tbl(k).start_hour,'09')||':'||to_char(br_sch_tbl(k).start_minute,'09'),
                                    'YYYY/MM/DD HH24:MI');

                  end if;

		    elsif k between 2 and (br_sch_st_edctr) then

				L_bill_rate_tbl(br_ctr).start_datetime :=
                           to_date(to_char(L_labor_sch_tbl(i).start_datetime,'YYYY/MM/DD')||' '||
                                to_char(br_sch_tbl(k).start_hour,'09')||':'||to_char(br_sch_tbl(k).start_minute,'09'),
                                    'YYYY/MM/DD HH24:MI');

            elsif k between br_sch_st_edctr+1 and (br_sch_tbl.count) then

				L_bill_rate_tbl(br_ctr).start_datetime :=
                           to_date(to_char(L_labor_sch_tbl(i).end_datetime,'YYYY/MM/DD')||' '||
                                to_char(br_sch_tbl(k).start_hour,'09')||':'||to_char(br_sch_tbl(k).start_minute,'09'),
                                    'YYYY/MM/DD HH24:MI');

		    end if;

		    if (k = br_sch_tbl.COUNT and l_wkday_st_searched  = l_wkday_ed_searched ) or -- and bug 3092683
               (k = br_sch_tbl.COUNT and l_wkday_st_searched  <> l_wkday_ed_searched and
                br_sch_st_edctr < br_sch_tbl.COUNT) then

                  if  l_end_numtime between l_rec_start_numtime and l_rec_end_numtime then

                        L_bill_rate_tbl(br_ctr).end_datetime := L_labor_sch_tbl(i).end_datetime;

                  elsif  l_end_numtime >= l_rec_end_numtime then

                        L_bill_rate_tbl(br_ctr).end_datetime :=
                           to_date(to_char(L_labor_sch_tbl(i).end_datetime,'YYYY/MM/DD')||' '||
                                to_char(br_sch_tbl(k).end_hour,'09')||':'||to_char(br_sch_tbl(k).end_minute,'09'),
                                    'YYYY/MM/DD HH24:MI');

                  end if;

		    elsif k between 1 and (br_sch_st_edctr ) then

				L_bill_rate_tbl(br_ctr).end_datetime :=
                           to_date(to_char(L_labor_sch_tbl(i).start_datetime,'YYYY/MM/DD')||' '||
                                to_char(br_sch_tbl(k).end_hour,'09')||':'||to_char(br_sch_tbl(k).end_minute,'09'),
                                    'YYYY/MM/DD HH24:MI');

            elsif k between br_sch_st_edctr+1 and (br_sch_tbl.count) then

				L_bill_rate_tbl(br_ctr).end_datetime :=
                           to_date(to_char(L_labor_sch_tbl(i).end_datetime,'YYYY/MM/DD')||' '||
                                to_char(br_sch_tbl(k).end_hour,'09')||':'||to_char(br_sch_tbl(k).end_minute,'09'),
                                    'YYYY/MM/DD HH24:MI');

		    end if;

            L_bill_rate_tbl(br_ctr).labor_item_id           := to_number(br_sch_tbl(k).object1_id1);
            L_bill_rate_tbl(br_ctr).labor_item_org_id       := to_number(br_sch_tbl(k).object1_id2);
            L_bill_rate_tbl(br_ctr).bill_rate_code          := br_sch_tbl(k).bill_rate_code;
            L_bill_rate_tbl(br_ctr).flat_rate               := br_sch_tbl(k).flat_rate;
            L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := br_sch_tbl(k).uom;
            L_bill_rate_tbl(br_ctr).percent_over_listprice  := br_sch_tbl(k).percent_over_list_price;

            if k = 1 and l_start_numtime < l_rec_start_numtime and br_sch_st_edctr <> 0 then

                 br_ctr := br_ctr + 1;

 	             L_bill_rate_tbl(br_ctr).start_datetime          := L_labor_sch_tbl(i).start_datetime;

-- Bug# 4746221 (JVORUGAN)
            --     l_calchour := trunc(((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute)-1)/60);
            --     l_calcmin  := mod((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute)-1,60);
                 l_calchour := trunc(((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute))/60);
                 l_calcmin  := mod((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute),60);
-- Bug#4746221 (JVORUGAN)

                 L_bill_rate_tbl(br_ctr).end_datetime            :=
                            to_date(to_char(L_labor_sch_tbl(i).start_datetime,'YYYY/MM/DD')||' '||
                                to_char(l_calchour,'09')||':'||to_char(l_calcmin,'09'),
                                    'YYYY/MM/DD HH24:MI');

                 L_bill_rate_tbl(br_ctr).labor_item_id           := null;
                 L_bill_rate_tbl(br_ctr).labor_item_org_id       := null;
                 L_bill_rate_tbl(br_ctr).bill_rate_code          := null;
                 L_bill_rate_tbl(br_ctr).flat_rate               := null;
                 L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := null;
                 L_bill_rate_tbl(br_ctr).percent_over_listprice  := null;

		     elsif (k between 2 and (br_sch_st_edctr ))  and
--			     (l_rec_end_numtime - l_prevrec_end_numtime > 0) then -- bug 3092683
                 (l_rec_start_numtime - l_prevrec_end_numtime > 0) then

                 br_ctr := br_ctr + 1;
-- bug fix 3951896
--	             l_calchour := trunc(((l_prevrec_end_hour*60+l_prevrec_end_minute)+1)/60);
--               l_calcmin  := mod((l_prevrec_end_hour*60+l_prevrec_end_minute)+1,60);
	             l_calchour := trunc(((l_prevrec_end_hour*60+l_prevrec_end_minute))/60);
                 l_calcmin  := mod((l_prevrec_end_hour*60+l_prevrec_end_minute),60);

 				 L_bill_rate_tbl(br_ctr).start_datetime          :=
                            to_date(to_char(L_labor_sch_tbl(i).start_datetime,'YYYY/MM/DD')||' '||
                                to_char(l_calchour,'09')||':'||to_char(l_calcmin,'09'),
                                    'YYYY/MM/DD HH24:MI');

-- bug fix 3951896
--                 l_calchour := trunc(((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute)-1)/60);
--                 l_calcmin  := mod((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute)-1,60);

                 l_calchour := trunc(((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute))/60);
                 l_calcmin  := mod((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute),60);

                 L_bill_rate_tbl(br_ctr).end_datetime            :=
                            to_date(to_char(L_labor_sch_tbl(i).start_datetime,'YYYY/MM/DD')||' '||
                                to_char(l_calchour,'09')||':'||to_char(l_calcmin,'09'),
                                    'YYYY/MM/DD HH24:MI');

                 L_bill_rate_tbl(br_ctr).labor_item_id           := null;
                 L_bill_rate_tbl(br_ctr).labor_item_org_id       := null;
                 L_bill_rate_tbl(br_ctr).bill_rate_code          := null;
                 L_bill_rate_tbl(br_ctr).flat_rate               := null;
                 L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := null;
                 L_bill_rate_tbl(br_ctr).percent_over_listprice  := null;

		     elsif k = br_sch_st_edctr + 1 and l_rec_start_numtime  > 0 then

                 br_ctr := br_ctr + 1;

                 L_bill_rate_tbl(br_ctr).start_datetime          :=
                            to_date(to_char(L_labor_sch_tbl(i).end_datetime,'YYYY/MM/DD')||' '||
                                '00'||':'||'00','YYYY/MM/DD HH24:MI');
--bug#4746221 (JVORUGAN)
		-- l_calchour := trunc(((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute)-1)/60);
                -- l_calcmin  := mod((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute)-1,60);
		l_calchour := trunc(((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute))/60);
                l_calcmin  := mod((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute),60);
--bug#4746221 (JVORUGAN)


				 L_bill_rate_tbl(br_ctr).end_datetime          :=
                            to_date(to_char(L_labor_sch_tbl(i).end_datetime,'YYYY/MM/DD')||' '||
                                to_char(l_calchour,'09')||':'||to_char(l_calcmin,'09'),
                                    'YYYY/MM/DD HH24:MI');

                 L_bill_rate_tbl(br_ctr).labor_item_id           := null;
                 L_bill_rate_tbl(br_ctr).labor_item_org_id       := null;
                 L_bill_rate_tbl(br_ctr).bill_rate_code          := null;
                 L_bill_rate_tbl(br_ctr).flat_rate               := null;
                 L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := null;
                 L_bill_rate_tbl(br_ctr).percent_over_listprice  := null;


             elsif (k between (br_sch_st_edctr + 1) and (br_sch_tbl.count))  and
--			     (l_rec_end_numtime - l_prevrec_end_numtime > 0) then -- bug 3092683
                 (l_rec_start_numtime - l_prevrec_end_numtime > 0) then


                 br_ctr := br_ctr + 1;
--bug#4746221 (JVORUGAN)
		-- l_calchour := trunc(((l_prevrec_end_hour*60+l_prevrec_end_minute)+1)/60);
                -- l_calcmin  := mod((l_prevrec_end_hour*60+l_prevrec_end_minute)+1,60);
		 l_calchour := trunc(((l_prevrec_end_hour*60+l_prevrec_end_minute))/60);
                 l_calcmin  := mod((l_prevrec_end_hour*60+l_prevrec_end_minute),60);
--bug#4746221 (JVORUGAN)

				 L_bill_rate_tbl(br_ctr).start_datetime          :=
                            to_date(to_char(L_labor_sch_tbl(i).end_datetime,'YYYY/MM/DD')||' '||
                                to_char(l_calchour,'09')||':'||to_char(l_calcmin,'09'),
                                    'YYYY/MM/DD HH24:MI');
--bug#4746221 (JVORUGAN)
               --  l_calchour := trunc(((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute)-1)/60);
               --  l_calcmin  := mod((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute)-1,60);
	         l_calchour := trunc(((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute))/60);
                 l_calcmin  := mod((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute),60);
--bug#4746221 (JVORUGAN)


                 L_bill_rate_tbl(br_ctr).end_datetime            :=
                            to_date(to_char(L_labor_sch_tbl(i).end_datetime,'YYYY/MM/DD')||' '||
                                to_char(l_calchour,'09')||':'||to_char(l_calcmin,'09'),
                                    'YYYY/MM/DD HH24:MI');

                 L_bill_rate_tbl(br_ctr).labor_item_id           := null;
                 L_bill_rate_tbl(br_ctr).labor_item_org_id       := null;
                 L_bill_rate_tbl(br_ctr).bill_rate_code          := null;
                 L_bill_rate_tbl(br_ctr).flat_rate               := null;
                 L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := null;
                 L_bill_rate_tbl(br_ctr).percent_over_listprice  := null;

             end if;

             if (k = br_sch_tbl.COUNT and l_wkday_st_searched  = l_wkday_ed_searched and
                 l_rec_end_numtime < l_end_numtime ) or  -- bug 3092683
                (k = br_sch_tbl.COUNT and l_wkday_st_searched  <> l_wkday_ed_searched and
                 br_sch_st_edctr < br_sch_tbl.COUNT) and
                 l_rec_end_numtime < l_end_numtime then


                 br_ctr := br_ctr + 1;
--bug#4746221 (JVORUGAN)
              --   l_calchour := trunc(((br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute)+1)/60);
              --   l_calcmin  := mod((br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute)+1,60);
	      l_calchour := trunc(((br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute))/60);
              l_calcmin  := mod((br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute),60);
--bug#4746221 (JVORUGAN)



				 L_bill_rate_tbl(br_ctr).start_datetime          :=
                            to_date(to_char(L_labor_sch_tbl(i).end_datetime,'YYYY/MM/DD')||' '||
                                to_char(l_calchour,'09')||':'||to_char(l_calcmin,'09'),
                                    'YYYY/MM/DD HH24:MI');

                 L_bill_rate_tbl(br_ctr).end_datetime            := L_labor_sch_tbl(i).end_datetime;

                 L_bill_rate_tbl(br_ctr).labor_item_id           := null;
                 L_bill_rate_tbl(br_ctr).labor_item_org_id       := null;
                 L_bill_rate_tbl(br_ctr).bill_rate_code          := null;
                 L_bill_rate_tbl(br_ctr).flat_rate               := null;
                 L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := null;
                 L_bill_rate_tbl(br_ctr).percent_over_listprice  := null;

              end if;

              if k = br_sch_st_edctr and
                 l_wkday_st_searched  <> l_wkday_ed_searched  and
			     l_rec_end_numtime  < 1439 then

                 br_ctr := br_ctr + 1;
--bug#4746221 (JVORUGAN)
	      --   l_calchour := trunc(((br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute)+1)/60);
              --   l_calcmin  := mod((br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute)+1,60);
	      	 l_calchour := trunc(((br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute))/60);
                 l_calcmin  := mod((br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute),60);
--bug#4746221 (JVORUGAN)

				 L_bill_rate_tbl(br_ctr).start_datetime          :=
                            to_date(to_char(L_labor_sch_tbl(i).start_datetime,'YYYY/MM/DD')||' '||
                                to_char(l_calchour,'09')||':'||to_char(l_calcmin,'09'),
                                    'YYYY/MM/DD HH24:MI');

                 L_bill_rate_tbl(br_ctr).end_datetime            :=
                            to_date(to_char(L_labor_sch_tbl(i).start_datetime,'YYYY/MM/DD')||' '||
                                '23'||':'||'59','YYYY/MM/DD HH24:MI');

                 L_bill_rate_tbl(br_ctr).labor_item_id           := null;
                 L_bill_rate_tbl(br_ctr).labor_item_org_id       := null;
                 L_bill_rate_tbl(br_ctr).bill_rate_code          := null;
                 L_bill_rate_tbl(br_ctr).flat_rate               := null;
                 L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := null;
                 L_bill_rate_tbl(br_ctr).percent_over_listprice  := null;

               end if;

		     l_prevrec_end_numtime := l_rec_end_numtime;
   		     l_prevrec_end_hour    := br_sch_tbl(k).end_hour;
		     l_prevrec_end_minute  := br_sch_tbl(k).end_minute;

            end loop;


            end if;

   	        if br_sch_st_edctr = 0 and l_wkday_st_searched  <> l_wkday_ed_searched then

               br_ctr := br_ctr + 1;

			   L_bill_rate_tbl(br_ctr).start_datetime          := L_labor_sch_tbl(i).start_datetime;

               L_bill_rate_tbl(br_ctr).end_datetime            :=
                            to_date(to_char(L_labor_sch_tbl(i).start_datetime,'YYYY/MM/DD')||' '||
                                '23'||':'||'59','YYYY/MM/DD HH24:MI');

               L_bill_rate_tbl(br_ctr).labor_item_id           := null;
               L_bill_rate_tbl(br_ctr).labor_item_org_id       := null;
               L_bill_rate_tbl(br_ctr).bill_rate_code          := null;
               L_bill_rate_tbl(br_ctr).flat_rate               := null;
               L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := null;
               L_bill_rate_tbl(br_ctr).percent_over_listprice  := null;

             end if;

             if  br_sch_tbl.count = br_sch_st_edctr and  l_wkday_st_searched  <> l_wkday_ed_searched then

                br_ctr := br_ctr + 1;

                L_bill_rate_tbl(br_ctr).start_datetime          :=
                            to_date(to_char(L_labor_sch_tbl(i).end_datetime,'YYYY/MM/DD')||' '||
                                '00'||':'||'00','YYYY/MM/DD HH24:MI');

                L_bill_rate_tbl(br_ctr).end_datetime          := L_labor_sch_tbl(i).end_datetime;

                L_bill_rate_tbl(br_ctr).labor_item_id           := null;
                L_bill_rate_tbl(br_ctr).labor_item_org_id       := null;
                L_bill_rate_tbl(br_ctr).bill_rate_code          := null;
                L_bill_rate_tbl(br_ctr).flat_rate               := null;
                L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := null;
                L_bill_rate_tbl(br_ctr).percent_over_listprice  := null;

              end if;

              if  br_sch_tbl.count = 0 and  l_wkday_st_searched  = l_wkday_ed_searched then

                br_ctr := br_ctr + 1;

                L_bill_rate_tbl(br_ctr).start_datetime          := L_labor_sch_tbl(i).start_datetime;
                L_bill_rate_tbl(br_ctr).end_datetime            := L_labor_sch_tbl(i).end_datetime;

                L_bill_rate_tbl(br_ctr).labor_item_id           := null;
                L_bill_rate_tbl(br_ctr).labor_item_org_id       := null;
                L_bill_rate_tbl(br_ctr).bill_rate_code          := null;
                L_bill_rate_tbl(br_ctr).flat_rate               := null;
                L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := null;
                L_bill_rate_tbl(br_ctr).percent_over_listprice  := null;


              end if;

      -- taking care of bill rate schedules whose weekdays fall in between weekdays of the request start/end datetime

       if   ((to_char(L_labor_sch_tbl(i).start_datetime,'DY') <> to_char(L_labor_sch_tbl(i).end_datetime,'DY')) AND
            (get_next_wkday(to_char(L_labor_sch_tbl(i).start_datetime,'DY'))
                                     <> to_char(L_labor_sch_tbl(i).end_datetime,'DY'))) then

            wkday_ctr   := 1;

            WHILE (1=1) LOOP

                l_datetime_searched    := L_labor_sch_tbl(i).start_datetime + wkday_ctr;

                l_wkday_searched       := to_char(l_datetime_searched,'DY');

                l_sunday_flag          := 'N';
                l_monday_flag          := 'N';
                l_tuesday_flag         := 'N';
                l_wednesday_flag       := 'N';
                l_thursday_flag        := 'N';
                l_friday_flag          := 'N';
                l_saturday_flag        := 'N';

                l_holiday_flag         := L_labor_sch_tbl(i).Holiday_flag;

                if l_wkday_searched = 'SUN'  then
                    l_sunday_flag          := 'Y';
                elsif l_wkday_searched = 'MON'  then
                    l_monday_flag          := 'Y';
                elsif l_wkday_searched = 'TUE'  then
                    l_tuesday_flag         := 'Y';
                elsif l_wkday_searched = 'WED'  then
                    l_wednesday_flag       := 'Y';
                elsif l_wkday_searched = 'THU'  then
                    l_thursday_flag        := 'Y';
                elsif l_wkday_searched = 'FRI'  then
                    l_friday_flag          := 'Y';
                elsif l_wkday_searched = 'SAT'  then
                    l_saturday_flag        := 'Y';
                end if;

		        j := 0;
		        br_sch_tbl.DELETE;

                for br_sch_Rec in  get_br_sch (l_bt_cle_id,l_sunday_flag,l_monday_flag,
                            l_tuesday_flag,l_wednesday_flag,
                            l_thursday_flag,l_friday_flag,
                            l_saturday_flag,l_holiday_flag) loop

			          j			:= j+1;
			          br_sch_tbl(j)     := br_sch_rec;

    		    end loop;

                if br_sch_tbl.count > 0 then
                for k in br_sch_tbl.first..br_sch_tbl.last loop

                    l_rec_start_numtime   := br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute;

                    l_rec_end_numtime     := br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute;

                    br_ctr  := br_ctr + 1;

                    L_bill_rate_tbl(br_ctr).start_datetime :=
                           to_date(to_char(l_datetime_searched,'YYYY/MM/DD')||' '||
                                to_char(br_sch_tbl(k).start_hour,'09')||':'||to_char(br_sch_tbl(k).start_minute,'09'),
                                    'YYYY/MM/DD HH24:MI');

                    L_bill_rate_tbl(br_ctr).end_datetime :=
                           to_date(to_char(l_datetime_searched,'YYYY/MM/DD')||' '||
                                to_char(br_sch_tbl(k).end_hour,'09')||':'||to_char(br_sch_tbl(k).end_minute,'09'),
                                    'YYYY/MM/DD HH24:MI');


                    L_bill_rate_tbl(br_ctr).labor_item_id           := to_number(br_sch_tbl(k).object1_id1);
                    L_bill_rate_tbl(br_ctr).labor_item_org_id       := to_number(br_sch_tbl(k).object1_id2);
                    L_bill_rate_tbl(br_ctr).bill_rate_code          := br_sch_tbl(k).bill_rate_code;
                    L_bill_rate_tbl(br_ctr).flat_rate               := br_sch_tbl(k).flat_rate;
                    L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := br_sch_tbl(k).uom;
                    L_bill_rate_tbl(br_ctr).percent_over_listprice  := br_sch_tbl(k).percent_over_list_price;

		        if k = 1 and l_rec_start_numtime  > 0 then

                    br_ctr := br_ctr + 1;

                    L_bill_rate_tbl(br_ctr).start_datetime          :=
                            to_date(to_char(l_datetime_searched,'YYYY/MM/DD')||' '||
                                '00'||':'||'00','YYYY/MM/DD HH24:MI');
--bug#4746221 (JVORUGAN)
		--    l_calchour := trunc(((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute)-1)/60);
                --    l_calcmin  := mod((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute)-1,60);
		    l_calchour := trunc(((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute))/60);
                    l_calcmin  := mod((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute),60);
--bug#4746221 (JVORUGAN)


				    L_bill_rate_tbl(br_ctr).end_datetime          :=
                            to_date(to_char(l_datetime_searched,'YYYY/MM/DD')||' '||
                                to_char(l_calchour,'09')||':'||to_char(l_calcmin,'09'),
                                    'YYYY/MM/DD HH24:MI');

                    L_bill_rate_tbl(br_ctr).labor_item_id           := null;
                    L_bill_rate_tbl(br_ctr).labor_item_org_id       := null;
                    L_bill_rate_tbl(br_ctr).bill_rate_code          := null;
                    L_bill_rate_tbl(br_ctr).flat_rate               := null;
                    L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := null;
                    L_bill_rate_tbl(br_ctr).percent_over_listprice  := null;

		        elsif (k between 2 and (br_sch_tbl.count ))  and
			          (l_rec_end_numtime - l_prevrec_end_numtime > 0) then

                     br_ctr := br_ctr + 1;
--bug#4746221 (JVORUGAN)

		  --   l_calchour := trunc(((l_prevrec_end_hour*60+l_prevrec_end_minute)+1)/60);
                  --   l_calcmin  := mod((l_prevrec_end_hour*60+l_prevrec_end_minute)+1,60);
		     l_calchour := trunc(((l_prevrec_end_hour*60+l_prevrec_end_minute))/60);
                     l_calcmin  := mod((l_prevrec_end_hour*60+l_prevrec_end_minute),60);
--bug#4746221 (JVORUGAN)


				     L_bill_rate_tbl(br_ctr).start_datetime          :=
                            to_date(to_char(l_datetime_searched,'YYYY/MM/DD')||' '||
                                to_char(l_calchour,'09')||':'||to_char(l_calcmin,'09'),
                                    'YYYY/MM/DD HH24:MI');

--bug#4746221 (JVORUGAN)
                   --  l_calchour := trunc(((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute)-1)/60);
                   --  l_calcmin  := mod((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute)-1,60);
		     l_calchour := trunc(((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute))/60);
                     l_calcmin  := mod((br_sch_tbl(k).start_hour*60+br_sch_tbl(k).start_minute),60);
--bug#4746221 (JVORUGAN)


                     L_bill_rate_tbl(br_ctr).end_datetime            :=
                            to_date(to_char(l_datetime_searched,'YYYY/MM/DD')||' '||
                                to_char(l_calchour,'09')||':'||to_char(l_calcmin,'09'),
                                    'YYYY/MM/DD HH24:MI');

                     L_bill_rate_tbl(br_ctr).labor_item_id           := null;
                     L_bill_rate_tbl(br_ctr).labor_item_org_id       := null;
                     L_bill_rate_tbl(br_ctr).bill_rate_code          := null;
                     L_bill_rate_tbl(br_ctr).flat_rate               := null;
                     L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := null;
                     L_bill_rate_tbl(br_ctr).percent_over_listprice  := null;

                 end if;

		         if k = br_sch_tbl.count and l_rec_end_numtime  < 1439 then

                     br_ctr := br_ctr + 1;
--bug#4746221 (JVORUGAN)
		 --    l_calchour := trunc(((br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute)+1)/60);
                 --    l_calcmin  := mod((br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute)+1,60);
		     l_calchour := trunc(((br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute))/60);
                     l_calcmin  := mod((br_sch_tbl(k).end_hour*60+br_sch_tbl(k).end_minute),60);
--bug#4746221 (JVORUGAN)

				     L_bill_rate_tbl(br_ctr).start_datetime          :=
                            to_date(to_char(l_datetime_searched,'YYYY/MM/DD')||' '||
                                to_char(l_calchour,'09')||':'||to_char(l_calcmin,'09'),
                                    'YYYY/MM/DD HH24:MI');

                     L_bill_rate_tbl(br_ctr).end_datetime            :=
                            to_date(to_char(l_datetime_searched,'YYYY/MM/DD')||' '||
                                '23'||':'||'59','YYYY/MM/DD HH24:MI');

                     L_bill_rate_tbl(br_ctr).labor_item_id           := null;
                     L_bill_rate_tbl(br_ctr).labor_item_org_id       := null;
                     L_bill_rate_tbl(br_ctr).bill_rate_code          := null;
                     L_bill_rate_tbl(br_ctr).flat_rate               := null;
                     L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := null;
                     L_bill_rate_tbl(br_ctr).percent_over_listprice  := null;

                  end if;


                l_prevrec_end_numtime := l_rec_end_numtime;
   		        l_prevrec_end_hour    := br_sch_tbl(k).end_hour;
		        l_prevrec_end_minute  := br_sch_tbl(k).end_minute;


             end loop;
             end if;

             if br_sch_tbl.count = 0 then

                        br_ctr := br_ctr + 1;

  			            L_bill_rate_tbl(br_ctr).start_datetime            :=
                            to_date(to_char(l_datetime_searched,'YYYY/MM/DD')||' '||
                                '00'||':'||'00','YYYY/MM/DD HH24:MI');

                        L_bill_rate_tbl(br_ctr).end_datetime            :=
                            to_date(to_char(l_datetime_searched,'YYYY/MM/DD')||' '||
                                '23'||':'||'59','YYYY/MM/DD HH24:MI');

                        L_bill_rate_tbl(br_ctr).labor_item_id           := null;
                        L_bill_rate_tbl(br_ctr).labor_item_org_id       := null;
                        L_bill_rate_tbl(br_ctr).bill_rate_code          := null;
                        L_bill_rate_tbl(br_ctr).flat_rate               := null;
                        L_bill_rate_tbl(br_ctr).flat_rate_uom_code      := null;
                        L_bill_rate_tbl(br_ctr).percent_over_listprice  := null;

              end if;

             if   get_next_wkday(to_char(l_datetime_searched,'DY'))
                                     = to_char(L_labor_sch_tbl(i).end_datetime,'DY') then
                    exit;
             else
                    wkday_ctr := wkday_ctr + 1;
             end if;

          end loop;

       end if;

       -- sort by date and time on L_bill_rate_tbl

      if L_bill_rate_tbl.count > 0 then

        --Bug# 4194507 (JVARGHES)

        Remove_Zero_Duration_Billrates
          (p_Input_Tab       => l_Bill_Rate_Tbl
          ,x_Output_Tab      => l_Bill_Rate_Tbl1
          ,x_Return_Status   => lx_Return_Status);

        IF lx_Return_Status <> G_RET_STS_SUCCESS THEN
          RAISE l_EXCEP_UNEXPECTED_ERR;
        END IF;

        Sort_Billrates_datetime
        (P_Input_Tab          => L_bill_rate_tbl1
        ,X_Output_Tab         => L_bill_ratesorted_tbl
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

        X_bill_rate_tbl := L_bill_ratesorted_tbl;

      else

        X_bill_rate_tbl := L_bill_rate_tbl;

      end if;

    end loop;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
		Null;
	WHEN OTHERS THEN
	  OKC_API.SET_MESSAGE( p_app_name	=> G_APP_NAME
				  ,p_msg_name	=> G_UNEXPECTED_ERROR
				  ,p_token1		=> G_SQLCODE_TOKEN
				  ,p_token1_value	=> SQLcode
				  ,p_token2		=> G_SQLERRM_TOKEN
				  ,p_token2_value	=> SQLerrm);

	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END get_bill_rates;

 --Bug# 4194507 (JVARGHES)

 PROCEDURE Remove_Zero_Duration_Billrates
   (p_Input_Tab          IN  BILL_RATE_TBL_TYPE
   ,x_Output_Tab         OUT NOCOPY BILL_RATE_TBL_TYPE
   ,x_Return_Status   	 OUT NOCOPY Gx_Ret_Sts)
 IS

   lx_Input_Tab          BILL_RATE_TBL_TYPE;
   lx_Output_Tab         BILL_RATE_TBL_TYPE;

   li_Input_TabIdx       BINARY_INTEGER;
   li_Output_TabIdx      BINARY_INTEGER;

 BEGIN

   lx_Input_Tab     := p_Input_Tab;
   li_Input_TabIdx  := lx_Input_Tab.FIRST;
   li_Output_TabIdx := 1;

   WHILE li_Input_TabIdx IS NOT NULL LOOP

      IF lx_Input_Tab(li_Input_TabIdx).Start_DateTime =  lx_Input_Tab(li_Input_TabIdx).End_DateTime THEN
        NULL;
      ELSE
        lx_Output_Tab(li_Output_TabIdx) := lx_Input_Tab(li_Input_TabIdx);
        li_Output_TabIdx := li_Output_TabIdx + 1;
      END IF;

      li_Input_TabIdx := lx_Input_Tab.NEXT(li_Input_TabIdx);

   END LOOP;

   x_Output_Tab         := lx_Output_Tab;
   x_Return_Status      := G_RET_STS_SUCCESS;

 EXCEPTION

    WHEN OTHERS THEN
	OKC_API.SET_MESSAGE(p_App_Name	=> G_APP_NAME
	     	             ,p_Msg_Name	=> G_UNEXPECTED_ERROR
				 ,p_Token1	      => G_SQLCODE_TOKEN
				 ,p_Token1_Value  => SQLCode
				 ,p_Token2	      => G_SQLERRM_TOKEN
				 ,p_Token2_Value  => SQLErrm);

	x_Return_Status  := OKC_API.G_RET_STS_UNEXP_ERROR;

 END Remove_Zero_Duration_Billrates;

 --

 FUNCTION get_next_wkday
	(p_today         		IN Varchar2) RETURN Varchar2
  IS
    x_next_wkday    varchar2(30) := null;
  BEGIN
    null;

    if p_today = 'SUN' then
        x_next_wkday := 'MON';
    elsif p_today = 'MON' then
        x_next_wkday := 'TUE';
    elsif p_today = 'TUE' then
        x_next_wkday := 'WED';
    elsif p_today = 'WED' then
        x_next_wkday := 'THU';
    elsif p_today = 'THU' then
        x_next_wkday := 'FRI';
    elsif p_today = 'FRI' then
        x_next_wkday := 'SAT';
    elsif p_today = 'SAT' then
        x_next_wkday := 'SUN';
    end if;

--    x_return_status := G_RET_STS_SUCCESS;
    return x_next_wkday;

  EXCEPTION
	WHEN OTHERS THEN
	  OKC_API.SET_MESSAGE( p_app_name	=> G_APP_NAME
				  ,p_msg_name	=> G_UNEXPECTED_ERROR
				  ,p_token1		=> G_SQLCODE_TOKEN
				  ,p_token1_value	=> SQLcode
				  ,p_token2		=> G_SQLERRM_TOKEN
				  ,p_token2_value	=> SQLerrm);
      return      x_next_wkday ;
 END get_next_wkday;

 PROCEDURE Sort_Billrates_datetime
    (P_Input_Tab          IN  BILL_RATE_TBL_TYPE
    ,X_Output_Tab         out nocopy BILL_RATE_TBL_TYPE
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts)  IS

    Lx_Sort_Tab           BILL_RATE_TBL_TYPE;
    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;

    Li_TableIdx_Out       BINARY_INTEGER;
    Li_TableIdx_In        BINARY_INTEGER;

    Lx_Temp_ContItem      OKS_CON_COVERAGE_PUB.BILL_RATE_REC_TYPE;

    Lv_Val1               DATE;
    Lv_Val2               DATE;

  BEGIN

    Lx_Sort_Tab           := P_Input_Tab;
    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;


    Li_TableIdx_Out  := Lx_Sort_Tab.FIRST;

    WHILE Li_TableIdx_Out IS NOT NULL LOOP

      Li_TableIdx_In  := Li_TableIdx_Out;

      WHILE Li_TableIdx_In IS NOT NULL LOOP

        Lv_Val1  := Lx_Sort_Tab(Li_TableIdx_Out).Start_datetime;

        Lv_Val2  := Lx_Sort_Tab(Li_TableIdx_In).Start_datetime;

        IF Lv_Val1 > Lv_Val2 THEN

          Lx_Temp_ContItem              := Lx_Sort_Tab(Li_TableIdx_Out);
          Lx_Sort_Tab(Li_TableIdx_Out)  := Lx_Sort_Tab(Li_TableIdx_In);
          Lx_Sort_Tab(Li_TableIdx_In)   := Lx_Temp_ContItem;

        END IF;

        Li_TableIdx_In  := Lx_Sort_Tab.NEXT(Li_TableIdx_In);

      END LOOP;

      Li_TableIdx_Out := Lx_Sort_Tab.NEXT(Li_TableIdx_Out);

    END LOOP;

    X_Output_Tab          := Lx_Sort_Tab;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
		Null;
	WHEN OTHERS THEN
	  OKC_API.SET_MESSAGE( p_app_name	=> G_APP_NAME
				  ,p_msg_name	=> G_UNEXPECTED_ERROR
				  ,p_token1		=> G_SQLCODE_TOKEN
				  ,p_token1_value	=> SQLcode
				  ,p_token2		=> G_SQLERRM_TOKEN
				  ,p_token2_value	=> SQLerrm);

	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Sort_Billrates_datetime;

  FUNCTION Get_Final_End_Date(
    P_Contract_Id IN number,
    P_Enddate IN DATE) Return Date is


   CURSOR Lx_Csr_HDR_Grace(Cx_HDR_Id IN number) IS
    SELECT okh.Grace_Duration Duration
          ,okh.Grace_Period TimeUnit
          ,chr.end_date end_date
      FROM okc_k_headers_all_b chr,    -- Modified for 12.0 MOAC project (JVARGHES)
           Oks_K_Headers_B OKH
     WHERE chr.Id = Cx_HDR_Id
       and okh.chr_id =  chr.id;

   L_Date    DATE;

  BEGIN

   L_Date    := P_Enddate;

   IF G_GRACE_PROFILE_SET = 'Y' then
    FOR Idx in Lx_Csr_HDR_Grace(P_Contract_Id) LOOP

        if (Idx.end_date = P_Enddate and
           Idx.TimeUnit is not null and
           Idx.Duration is not null ) then

            L_Date := OKC_TIME_UTIL_PVT.get_enddate(
                          P_Enddate,
                          Idx.TimeUnit,
                          Idx.Duration) + 1;

        end if;

    END LOOP;
   END IF;

   RETURN L_Date;

  END Get_Final_End_Date;

END OKS_CON_COVERAGE_PVT;

/
