--------------------------------------------------------
--  DDL for Package Body OKS_COVERAGES_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_COVERAGES_MIGRATION" AS
/* $Header: OKSIMCVB.pls 115.2 2003/02/05 00:14:25 hmedheka noship $ */


PROCEDURE COVERAGE_MIGRATE (P_FromId        IN  NUMBER,
                            P_ToId          IN  NUMBER,
                            P_VALIDATE_FLAG IN  VARCHAR2,
                            P_LOG_PARAMETER IN  VARCHAR2) IS

CURSOR get_coverages_cur (p_FromId in number,p_ToId in number) is
	select
	 nvl(cov.COVERAGE_ID,0) COVERAGE_ID,
	 cov.NAME,
	 cov.DESCRIPTION,
	cov.START_DATE,
	cov.END_DATE,
	cov.FREE_UPGRADE_YN,
	cov.COVERAGE_TYPE_CODE,
	cov.EXCEPTION_COVERAGE_YN,
	cov.EXC_COVERAGE_ID,
	cov.TEMPLATE_FLAG_YN,
	cov.WARRANTY_YN,
	cov.WARRANTY_INHERITANCE_CODE,
	cov.TRANSFER_ALLOWED_YN,
	cov.ATTRIBUTE_CATEGORY,
	cov.ATTRIBUTE1,
	cov.ATTRIBUTE2,
	cov.ATTRIBUTE3,
	cov.ATTRIBUTE4,
	cov.ATTRIBUTE5,
	cov.ATTRIBUTE6,
	cov.ATTRIBUTE7,
	cov.ATTRIBUTE8,
	cov.ATTRIBUTE9,
	cov.ATTRIBUTE10,
	cov.ATTRIBUTE11,
	cov.ATTRIBUTE12,
	cov.ATTRIBUTE13,
	cov.ATTRIBUTE14,
	cov.ATTRIBUTE15
from oks_coverages_int_all cov,
     OKS_CON_LINES_INT_ALL lines,
     OKS_CON_HEADERS_INT_ALL head
where cov.coverage_id <> 0
and  cov.interfaced_status_flag is null
and  head.batch_number between p_FromId and p_ToID
and  head.interfaced_status_flag = 'S'
and  head.contract_id = lines.contract_id
and  lines.interfaced_status_flag = 'S'
and  lines.coverage_id = cov.coverage_id;

get_coverages_rec  get_coverages_cur%ROWTYPE;

CURSOR get_okc_lines_cur(p_id in number) is
SELECT cle1.Id           Id,
		cle1.Lse_Id           Lse_Id,
		cle1.Start_Date       Start_Date,
		cle1.Sts_Code         Sts_Code,
		cle1.End_Date         End_Date,
		cle1.Dnz_Chr_Id       Dnz_Chr_Id,
		cle1.Currency_Code    Currency_Code,
		cle1.display_sequence display_sequence,
		cle1.Line_Number      Line_Number,
		cle1.CREATED_BY       CREATED_BY,
		cle1.CREATION_DATE    CREATION_DATE,
		cle1.LAST_UPDATED_BY  LAST_UPDATED_BY,
		cle1.LAST_UPDATE_DATE LAST_UPDATE_DATE,
        cle1.LAST_UPDATE_LOGIN LAST_UPDATE_LOGIN
        FROM OKC_K_LINES_B cle1,OKS_CON_LINES_INT_ALL ocl
        WHERE 	cle1.Lse_Id = 1
        AND     cle1.UPG_ORIG_SYSTEM_REF_ID = ocl.contract_line_id
        AND     cle1.dnz_chr_Id <> -1
        AND     cle1.UPG_ORIG_SYSTEM_REF = g_line_ref
        AND     ocl.coverage_id  = p_id;

 get_okc_lines_rec get_okc_lines_cur%rowtype;

CURSOR get_cov_id_cur is
	select nvl(coverage_id,0) id,nvl(coverage_template_id,0) tid
	from oks_con_lines_int_all
    where coverage_id <> 0;

CURSOR get_mtl_cov_id_cur is
		select distinct coverage_schedule_id id
		from mtl_system_items mtl,
		Okc_k_Lines_b cle,
		okc_k_Items cim
		WHERE to_char(mtl.Inventory_Item_Id) = cim.object1_Id1
		AND to_char(mtl.Organization_Id) = cim.object1_Id2
		AND cle.Id = cim.Cle_Id
		AND mtl.Coverage_Schedule_Id IS NOT NULL ;
/*---------------------*/
 i                  NUMBER := 0;
 l_old_id           Number := 0;
 g_seq_id           Number := 0;
 G_SEQ_CONSTANT     Number := 0;
 g_CREATION_DATE    date := sysdate;
 l_get_cov_id		number;
 l_get_cov_tmp_id	number;
 l_upg_flag         VARCHAR2(1) := 'N';
 l_transfer_all_flag VARCHAR2(1) := 'N';
 l_duration          NUMBER;
 l_timeunits         VARCHAR2(240);
 l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
TYPE K_Status_rec IS RECORD (old_status Varchar2(30),new_status Varchar2(30));
TYPE K_Status_Tab is TABLE OF K_Status_Rec INDEX BY BINARY_Integer;

l_status_tab K_Status_Tab;

l_validate_flag VARCHAR2(1) := p_validate_flag;

/*---------------------*/
FUNCTION Get_new_status(p_k_status_id IN Number) RETURN Varchar2 IS
   l_new_status Varchar2(30);
BEGIN
   Return(l_status_tab(p_k_status_id).new_status);
END Get_new_status;

 FUNCTION Get_Seq_Id (P_id IN Number) RETURN Number IS
  BEGIN

   IF        l_old_id <> P_id
   THEN
       l_old_id := P_id;
       g_seq_id :=   (P_id * 10000)+G_SEQ_CONSTANT ;
   ELSE
	   g_seq_id  := g_seq_id + 1;
   END IF;
	 Return(g_seq_id);
 END Get_Seq_Id;

FUNCTION Get_Cov_Type (P_contract_type IN Varchar2) RETURN Varchar2 IS
    CURSOR Cur_cov_code IS
		 SELECT LOOKUP_CODE
		 FROM   FND_LOOKUPS
		 WHERE  LOOKUP_TYPE = 'OKSCVETYPE'
		 AND    MEANING = P_contract_type;
	 l_cov_type Varchar2(30);
 BEGIN
      IF P_contract_type = 'Gold' THEN
         l_cov_type := 'G';
      ELSIF P_contract_type = 'Silver' THEN
         l_cov_type := 'S';
      ELSIF P_contract_type = 'Bronze' THEN
         l_cov_type := 'B';
      ELSE
	     OPEN Cur_cov_code;
		FETCH Cur_cov_code INTO l_cov_type;
		  IF Cur_cov_code%NOTFOUND THEN
		    l_cov_type := NULL;
            END IF;
		CLOSE Cur_cov_code;
      END IF;
	 RETURN l_cov_type;
  END;

BEGIN --- MAIN BEGIN OF coverage_migrate procedure ----

    open get_coverages_cur (p_fromid,p_toId);
    loop
    fetch get_coverages_cur into get_coverages_rec;

            exit when get_coverages_cur%notfound;
            -- dbms_output.put_line('Value of get_coverages_rec.COVERAGE_ID='||TO_CHAR(get_coverages_rec.COVERAGE_ID));
     open get_okc_lines_cur(get_coverages_rec.COVERAGE_ID)    ;
     loop
        fetch get_okc_lines_cur into get_okc_lines_rec;
            exit when get_okc_lines_cur%notfound;

       -- dbms_output.put_line('1111111111');
       -- dbms_output.put_line('Value of get_okc_lines_rec.dnz_chr_id='||TO_CHAR(get_okc_lines_rec.dnz_chr_id));
        l_clev_tbl_in(i).cle_id_renewed           :=NULL;
        l_clev_tbl_in(i).comments                 :=NULL;
        l_clev_tbl_in(i).price_unit               :=NULL;
        l_clev_tbl_in(i).price_unit_percent       :=NULL;
        l_clev_tbl_in(i).price_negotiated         :=NULL;
        l_clev_tbl_in(i).price_level_ind          :='N';
        l_clev_tbl_in(i).block23text              :=NULL;
        l_clev_tbl_in(i).id                  := okc_p_util.raw_to_number(sys_guid()); --Get_Seq_Id(get_coverages_rec.Coverage_ID)
        l_clev_tbl_in(i).CREATION_DATE       := g_CREATION_DATE;
        l_clev_tbl_in(i).CREATED_BY          := -1;
        l_clev_tbl_in(i).LAST_UPDATE_DATE    := sysdate;
        l_clev_tbl_in(i).LAST_UPDATED_BY     := -1;
        l_clev_tbl_in(i).LAST_UPDATE_LOGIN   := -1;
        l_clev_tbl_in(i).object_version_number    := 1;
        l_clev_tbl_in(i).chr_id              := Null;
        l_clev_tbl_in(i).cle_id 		      := get_okc_lines_rec.id;
        l_clev_tbl_in(i).dnz_chr_id          := get_okc_lines_rec.dnz_chr_id;
        l_clev_tbl_in(i).line_number         :='1';
        l_clev_tbl_in(i).sfwt_flag		:='N';
        l_clev_tbl_in(i).lse_id		:= 2;
        l_clev_tbl_in(i).sts_code	        := get_coverages_rec.COVERAGE_TYPE_CODE;
        l_clev_tbl_in(i).display_sequence    :=1;
        l_clev_tbl_in(i).exception_yn        :='Y';
	    l_clev_tbl_in(i).item_description	:= get_coverages_rec.description;
    	l_clev_tbl_in(i).Name			:= get_coverages_rec.NAME;
	    l_clev_tbl_in(i).start_date	:= get_coverages_rec.start_date;
    	l_clev_tbl_in(i).end_date	:= get_coverages_rec.end_date;
        l_clev_tbl_in(i).upg_orig_system_ref_id := get_coverages_rec.coverage_id;
        l_clev_tbl_in(i).upg_orig_system_ref   := g_covline_ref;
        l_clev_tbl_in(i).currency_code := get_okc_lines_rec.currency_code;
--        l_clev_tbl_in(i).orig_system_source_code := NULL;
       -- l_clev_tbl_in(i).orig_system_id1 := NULL;
        l_clev_tbl_in(i).ATTRIBUTE_CATEGORY    := get_coverages_rec.ATTRIBUTE_CATEGORY;
        l_clev_tbl_in(i).attribute1	           :=get_coverages_rec.Attribute1 ;
    	l_clev_tbl_in(i).attribute2	           :=get_coverages_rec.Attribute2 ;
	    l_clev_tbl_in(i).attribute3	           :=get_coverages_rec.Attribute3 ;
    	l_clev_tbl_in(i).attribute4	           :=get_coverages_rec.Attribute4 ;
	    l_clev_tbl_in(i).attribute5	           :=get_coverages_rec.Attribute5 ;
    	l_clev_tbl_in(i).attribute6	           :=get_coverages_rec.Attribute6 ;
	    l_clev_tbl_in(i).attribute7	           :=get_coverages_rec.Attribute7 ;
    	l_clev_tbl_in(i).attribute8	           :=get_coverages_rec.Attribute8 ;
	    l_clev_tbl_in(i).attribute9	           :=get_coverages_rec.Attribute9 ;
    	l_clev_tbl_in(i).attribute10	       :=get_coverages_rec.Attribute10 ;
	    l_clev_tbl_in(i).attribute11	       :=get_coverages_rec.Attribute11 ;
    	l_clev_tbl_in(i).attribute12	       :=get_coverages_rec.Attribute12 ;
	    l_clev_tbl_in(i).attribute13	       :=get_coverages_rec.Attribute13 ;
    	l_clev_tbl_in(i).attribute14	       :=get_coverages_rec.Attribute14 ;
        l_clev_tbl_in(i).attribute15	       :=get_coverages_rec.Attribute15;
        l_clev_tbl_in(i).INVOICE_LINE_LEVEL_IND:= Null;
        l_clev_tbl_in(i).DPAS_RATING           := Null;
        l_clev_tbl_in(i).TEMPLATE_USED         := Null;
        l_clev_tbl_in(i).PRICE_TYPE            := Null;
    --l_clev_tbl_in(i).UOM_CODE                                :=Null;
        l_clev_tbl_in(i).TRN_CODE              := Null;
        l_clev_tbl_in(i).HIDDEN_IND            := Null;
        l_clev_tbl_in(i).DATE_TERMINATED       := Null;
        l_clev_tbl_in(i).CLE_ID_RENEWED_TO     := Null;
        l_clev_tbl_in(i).CURRENCY_CODE_RENEWED := Null;
        l_clev_tbl_in(i).PRICE_NEGOTIATED_RENEWED:= Null;

        l_clev_tbl_in(i).program_application_id:= fnd_global.prog_appl_id;
        l_clev_tbl_in(i).program_id:= fnd_global.CONC_PROGRAM_ID;

               -- dbms_output.put_line('Before Insert');

If l_validate_flag = 'Y' THEN


         If l_clev_tbl_in.count > 0 Then

           okc_cle_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_clev_tbl      =>    l_clev_tbl_in,
                                x_clev_tbl      =>    x_clev_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
        End If;
ELSE
    	okc_cle_pvt.Insert_Row_Upg( l_return_status , l_clev_tbl_in);

END IF;

       --         l_clev_tbl_in.delete;
       -- dbms_output.put_line('----222222222222');

 -- Rule Group Creation----
    l_rgpv_tbl_in(i).id                     :=okc_p_util.raw_to_number(sys_guid()); --Get_Seq_Id(get_coverages_rec.Coverage_ID);
    -- dbms_output.put_line('Value of l_rgpv_tbl_in(i).id='||TO_CHAR(l_rgpv_tbl_in(i).id));
    l_rgpv_tbl_in(i).CREATION_DATE          := g_CREATION_DATE;
    l_rgpv_tbl_in(i).CREATED_BY             := -1;
    l_rgpv_tbl_in(i).LAST_UPDATE_DATE       := sysdate;
    l_rgpv_tbl_in(i).LAST_UPDATED_BY        := -1;
    l_rgpv_tbl_in(i).LAST_UPDATE_LOGIN      := -1;
    l_rgpv_tbl_in(i).object_version_number  := 1;
    l_rgpv_tbl_in(i).cle_id		            := l_clev_tbl_in(i).Id;
    -- dbms_output.put_line('Value of l_rgpv_tbl_in(i).cle_id='||TO_CHAR(l_rgpv_tbl_in(i).cle_id));
    l_rgpv_tbl_in(i).dnz_chr_id	            := l_clev_tbl_In(i).dnz_chr_Id;
    -- dbms_output.put_line('Value of l_rgpv_tbl_in(i).dnz_chr_id='||TO_CHAR(l_rgpv_tbl_in(i).dnz_chr_id));
    l_rgpv_tbl_in(i).sfwt_flag	            :='N';
    l_rgpv_tbl_in(i).rgd_code	            := 'SVC_K';
    l_rgpv_tbl_in(i).rgp_type	            := 'KRG';
       -- dbms_output.put_line('333333333333333');
    l_rgpv_tbl_in(i).CHR_ID                                   :=Null;
    l_rgpv_tbl_in(i).PARENT_RGP_ID                            :=Null;
	l_rgpv_tbl_in(i).SAT_CODE                                 :=Null;
	l_rgpv_tbl_in(i).COMMENTS                                 :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE_CATEGORY                       :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE1                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE2                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE3                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE4                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE5                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE6                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE7                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE8                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE9                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE10                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE11                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE12                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE13                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE14                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE15                              :=Null;
       -- dbms_output.put_line('4444444444444');
       If l_validate_flag = 'Y' THEN


         If l_rgpv_tbl_in.count > 0 Then

           okc_rgp_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rgpv_tbl      =>    l_rgpv_tbl_in,
                                x_rgpv_tbl      =>    x_rgpv_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
        End If;
ELSE
   	okc_rgp_pvt.Insert_Row_Upg( l_return_status , l_rgpv_tbl_in);

END IF;


       -- dbms_output.put_line('---55555555555');
/*Inserting Rule Informations */
--OFS Rule
           l_rulv_tbl_in(i).rgp_id	            	  := l_rgpv_tbl_in(i).id;
           l_rulv_tbl_in(i).sfwt_flag                 := 'N';
           l_rulv_tbl_in(i).rule_information_category := 'OFS';
           l_rulv_tbl_in(i).rule_information1         := okc_p_util.raw_to_number(sys_guid());
           l_rulv_tbl_in(i).std_template_yn           := 'N';
           l_rulv_tbl_in(i).warn_yn                   := 'Y';
           l_rulv_tbl_in(i).dnz_chr_id                := l_clev_tbl_In(i).dnz_chr_Id;
           l_rulv_tbl_in(i).id                        := okc_p_util.raw_to_number(sys_guid()); --Get_Seq_Id(get_coverages_rec.Coverage_ID);
           l_rulv_tbl_in(i).CREATION_DATE             := sysdate;
           l_rulv_tbl_in(i).CREATED_BY                := -1;
           l_rulv_tbl_in(i).LAST_UPDATE_DATE          := sysdate;
           l_rulv_tbl_in(i).LAST_UPDATED_BY           := -1;
           l_rulv_tbl_in(i).LAST_UPDATE_LOGIN         := -1;
           l_rulv_tbl_in(i).object_version_number     := 1;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).OBJECT1_ID1               := NULL;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).OBJECT2_ID1               := NULL;
           l_rulv_tbl_in(i).OBJECT3_ID1               := NULL;
           l_rulv_tbl_in(i).OBJECT2_ID2               := NULL;
           l_rulv_tbl_in(i).OBJECT3_ID2               := NULL;
           l_rulv_tbl_in(i).OBJECT1_ID2               := NULL;
           l_rulv_tbl_in(i).JTOT_OBJECT1_CODE         := NULL;
           l_rulv_tbl_in(i).JTOT_OBJECT2_CODE         := NULL;
           l_rulv_tbl_in(i).JTOT_OBJECT3_CODE         := NULL;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).COMMENTS                  := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE_CATEGORY        := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE1                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE2                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE3                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE4                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE5                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE6                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE7                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE8                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE9                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE10               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE11               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE12               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE13               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE14               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE15               := NULL;
           l_rulv_tbl_in(i).TEXT                      := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION2         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION3         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION4         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION5         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION6         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION7         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION8         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION9         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION10        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION11        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION12        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION13        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION14        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION15        := NULL;

If l_validate_flag = 'Y' THEN


         If l_rulv_tbl_in.count > 0 Then

           okc_rul_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rulv_tbl      =>    l_rulv_tbl_in,
                                x_rulv_tbl      =>    x_rulv_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
        End If;
ELSE
            	okc_rul_pvt.Insert_Row_Upg( l_return_status , l_rulv_tbl_in);

END IF;


                  okc_time_util_pub.get_duration
    (
          p_start_date    => get_okc_lines_rec.start_date,
          p_end_date      => get_okc_lines_rec.end_date,
          x_duration      => l_duration,
          x_timeunit      => l_timeunits,
          x_return_status => l_return_status
    );
 -- dbms_output.put_line('232323323232');
  l_isev_ext_tbl_in(i).id                            :=l_rulv_tbl_in(i).rule_information1;
  l_isev_ext_tbl_in(i).object_version_number         :=1;
  l_isev_ext_tbl_in(i).sfwt_flag                     :='N';
  l_isev_ext_tbl_in(i).spn_id                        :=Null;
  l_isev_ext_tbl_in(i).uom_code                      :=l_timeunits;
  l_isev_ext_tbl_in(i).tve_id_started                  :=okc_p_util.raw_to_number(sys_guid());
  l_isev_ext_tbl_in(i).tve_id_ended                  :=Null;
  l_isev_ext_tbl_in(i).tve_id_limited                :=Null;
  l_isev_ext_tbl_in(i).dnz_chr_id                    :=l_clev_tbl_In(i).dnz_chr_Id;
  l_isev_ext_tbl_in(i).tze_id                        :=Null;
  l_isev_ext_tbl_in(i).description                   :=Null;
  l_isev_ext_tbl_in(i).short_description             :=Null;
  l_isev_ext_tbl_in(i).comments                      :=Null;
  l_isev_ext_tbl_in(i).duration                      :=l_duration;
  l_isev_ext_tbl_in(i).operator                      :=Null;
  l_isev_ext_tbl_in(i).before_after                  :=Null;
  l_isev_ext_tbl_in(i).attribute_category            :=Null;
  l_isev_ext_tbl_in(i).attribute1                    :=Null;
  l_isev_ext_tbl_in(i).attribute2                    :=Null;
  l_isev_ext_tbl_in(i).attribute3                    :=Null;
  l_isev_ext_tbl_in(i).attribute4                    :=Null;
  l_isev_ext_tbl_in(i).attribute5                    :=Null;
  l_isev_ext_tbl_in(i).attribute6                    :=Null;
  l_isev_ext_tbl_in(i).attribute7                    :=Null;
  l_isev_ext_tbl_in(i).attribute8                    :=Null;
  l_isev_ext_tbl_in(i).attribute9                    :=Null;
  l_isev_ext_tbl_in(i).attribute10                   :=Null;
  l_isev_ext_tbl_in(i).attribute11                   :=Null;
  l_isev_ext_tbl_in(i).attribute12                   :=Null;
  l_isev_ext_tbl_in(i).attribute13                   :=Null;
  l_isev_ext_tbl_in(i).attribute14                   :=Null;
  l_isev_ext_tbl_in(i).attribute15                   :=Null;
  l_isev_ext_tbl_in(i).CREATION_DATE             := sysdate;
  l_isev_ext_tbl_in(i).CREATED_BY                := -1;
  l_isev_ext_tbl_in(i).LAST_UPDATE_DATE          := sysdate;
  l_isev_ext_tbl_in(i).LAST_UPDATED_BY           := -1;
  l_isev_ext_tbl_in(i).LAST_UPDATE_LOGIN         := -1;

	okc_time_pvt.Insert_ise_Row_Upg( l_isev_ext_tbl_in);

                l_rulv_tbl_in.delete;
                l_isev_ext_tbl_in.delete;
--UGE Rule
        if  (get_coverages_rec.FREE_UPGRADE_YN = 'Y') then
            l_upg_flag := 'Y';
        end if;
           l_rulv_tbl_in(i).rgp_id	            	  := l_rgpv_tbl_in(i).id;
           l_rulv_tbl_in(i).sfwt_flag                 := 'N';
           l_rulv_tbl_in(i).rule_information_category := 'UGE';
           l_rulv_tbl_in(i).rule_information1         := l_upg_flag ;

           l_rulv_tbl_in(i).std_template_yn           := 'N';
           l_rulv_tbl_in(i).warn_yn                   := 'Y';
           l_rulv_tbl_in(i).dnz_chr_id                := l_clev_tbl_In(i).dnz_chr_Id;
           l_rulv_tbl_in(i).id                        := okc_p_util.raw_to_number(sys_guid()); --Get_Seq_Id(get_coverages_rec.Coverage_ID);
           l_rulv_tbl_in(i).CREATION_DATE             := sysdate;
           l_rulv_tbl_in(i).CREATED_BY                := -1;
           l_rulv_tbl_in(i).LAST_UPDATE_DATE          := sysdate;
           l_rulv_tbl_in(i).LAST_UPDATED_BY           := -1;
           l_rulv_tbl_in(i).LAST_UPDATE_LOGIN         := -1;
           l_rulv_tbl_in(i).object_version_number     := 1;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).OBJECT1_ID1               := NULL;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).OBJECT2_ID1               := NULL;
           l_rulv_tbl_in(i).OBJECT3_ID1               := NULL;
           l_rulv_tbl_in(i).OBJECT2_ID2               := NULL;
           l_rulv_tbl_in(i).OBJECT3_ID2               := NULL;
           l_rulv_tbl_in(i).OBJECT1_ID2               := NULL;
           l_rulv_tbl_in(i).JTOT_OBJECT1_CODE         := NULL;
           l_rulv_tbl_in(i).JTOT_OBJECT2_CODE         := NULL;
           l_rulv_tbl_in(i).JTOT_OBJECT3_CODE         := NULL;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).COMMENTS                  := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE_CATEGORY        := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE1                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE2                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE3                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE4                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE5                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE6                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE7                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE8                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE9                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE10               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE11               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE12               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE13               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE14               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE15               := NULL;
           l_rulv_tbl_in(i).TEXT                      := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION2         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION3         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION4         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION5         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION6         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION7         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION8         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION9         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION10        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION11        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION12        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION13        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION14        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION15        := NULL;
If l_validate_flag = 'Y' THEN

If l_rulv_tbl_in.count > 0 Then

           okc_rul_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rulv_tbl      =>    l_rulv_tbl_in,
                                x_rulv_tbl      =>    x_rulv_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
        End If;
ELSE
            	okc_rul_pvt.Insert_Row_Upg( l_return_status , l_rulv_tbl_in);

END IF;

                l_rulv_tbl_in.delete;

--STR Rule
        if  (get_coverages_rec.TRANSFER_ALLOWED_YN = 'Y') then
            l_transfer_all_flag := 'Y';
        end if;
           l_rulv_tbl_in(i).rgp_id	            	  := l_rgpv_tbl_in(i).id;
           l_rulv_tbl_in(i).sfwt_flag                 := 'N';
           l_rulv_tbl_in(i).rule_information_category := 'STR';
           l_rulv_tbl_in(i).rule_information1         := l_transfer_all_flag;
           l_rulv_tbl_in(i).std_template_yn           := 'N';
           l_rulv_tbl_in(i).warn_yn                   := 'Y';
           l_rulv_tbl_in(i).dnz_chr_id                := l_clev_tbl_In(i).dnz_chr_Id;
           l_rulv_tbl_in(i).id                        := okc_p_util.raw_to_number(sys_guid()); --Get_Seq_Id(get_coverages_rec.Coverage_ID);
           l_rulv_tbl_in(i).CREATION_DATE             := sysdate;
           l_rulv_tbl_in(i).CREATED_BY                := -1;
           l_rulv_tbl_in(i).LAST_UPDATE_DATE          := sysdate;
           l_rulv_tbl_in(i).LAST_UPDATED_BY           := -1;
           l_rulv_tbl_in(i).LAST_UPDATE_LOGIN         := -1;
           l_rulv_tbl_in(i).object_version_number     := 1;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).OBJECT1_ID1               := NULL;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).OBJECT1_ID2               := NULL;
           l_rulv_tbl_in(i).JTOT_OBJECT1_CODE         := NULL;
           l_rulv_tbl_in(i).OBJECT2_ID1               := NULL;
           l_rulv_tbl_in(i).OBJECT3_ID1               := NULL;
           l_rulv_tbl_in(i).OBJECT2_ID2               := NULL;
           l_rulv_tbl_in(i).OBJECT3_ID2               := NULL;
           l_rulv_tbl_in(i).JTOT_OBJECT2_CODE         := NULL;
           l_rulv_tbl_in(i).JTOT_OBJECT3_CODE         := NULL;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).COMMENTS                  := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE_CATEGORY        := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE1                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE2                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE3                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE4                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE5                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE6                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE7                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE8                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE9                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE10               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE11               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE12               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE13               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE14               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE15               := NULL;
           l_rulv_tbl_in(i).TEXT                      := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION2         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION3         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION4         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION5         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION6         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION7         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION8         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION9         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION10        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION11        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION12        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION13        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION14        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION15        := NULL;
If l_validate_flag = 'Y' THEN
           If l_rulv_tbl_in.count > 0 Then

           okc_rul_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rulv_tbl      =>    l_rulv_tbl_in,
                                x_rulv_tbl      =>    x_rulv_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
        End If;
ELSE
            	okc_rul_pvt.Insert_Row_Upg( l_return_status , l_rulv_tbl_in);

END IF;
                l_rulv_tbl_in.delete;

IF get_coverages_rec.COVERAGE_TYPE_CODE IS NOT NULL THEN

           l_rulv_tbl_in(i).rgp_id	            	  := l_rgpv_tbl_in(i).id;
           l_rulv_tbl_in(i).sfwt_flag                 := 'N';
           l_rulv_tbl_in(i).rule_information_category := 'CVE';
           l_rulv_tbl_in(i).rule_information1         := Get_Cov_Type(get_coverages_rec.COVERAGE_TYPE_CODE);
           l_rulv_tbl_in(i).std_template_yn           := 'N';
           l_rulv_tbl_in(i).warn_yn                   := 'Y';
           l_rulv_tbl_in(i).dnz_chr_id                := l_clev_tbl_In(i).dnz_chr_Id;
           l_rulv_tbl_in(i).id                        := okc_p_util.raw_to_number(sys_guid());
           l_rulv_tbl_in(i).CREATION_DATE             := sysdate;
           l_rulv_tbl_in(i).CREATED_BY                := -1;
           l_rulv_tbl_in(i).LAST_UPDATE_DATE          := sysdate;
           l_rulv_tbl_in(i).LAST_UPDATED_BY           := -1;
           l_rulv_tbl_in(i).LAST_UPDATE_LOGIN         := -1;
           l_rulv_tbl_in(i).object_version_number     := 1;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).OBJECT1_ID1               := NULL;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).OBJECT2_ID1               := NULL;
           l_rulv_tbl_in(i).OBJECT3_ID1               := NULL;
           l_rulv_tbl_in(i).OBJECT2_ID2               := NULL;
           l_rulv_tbl_in(i).OBJECT3_ID2               := NULL;
           l_rulv_tbl_in(i).JTOT_OBJECT2_CODE         := NULL;
           l_rulv_tbl_in(i).JTOT_OBJECT3_CODE         := NULL;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).COMMENTS                  := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE_CATEGORY        := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE1                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE2                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE3                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE4                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE5                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE6                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE7                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE8                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE9                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE10               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE11               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE12               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE13               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE14               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE15               := NULL;
           l_rulv_tbl_in(i).TEXT                      := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION2         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION3         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION4         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION5         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION6         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION7         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION8         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION9         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION10        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION11        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION12        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION13        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION14        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION15        := NULL;

            --	okc_rul_pvt.Insert_Row_Upg( l_return_status , l_rulv_tbl_in);
If l_validate_flag = 'Y' THEN
            If l_rulv_tbl_in.count > 0 Then

           okc_rul_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rulv_tbl      =>    l_rulv_tbl_in,
                                x_rulv_tbl      =>    x_rulv_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
        End If;
ELSE
            	okc_rul_pvt.Insert_Row_Upg( l_return_status , l_rulv_tbl_in);

END IF;
                l_rulv_tbl_in.delete;
END IF;        -- End of  CVE Rule COVERAGE_TYPE_CODE --

      IF get_coverages_rec.EXC_COVERAGE_ID IS NOT NULL then
            -- dbms_output.put_line('6666666666666');
            l_rulv_tbl_in(i).rgp_id	            	  := l_rgpv_tbl_in(i).id;
            l_rulv_tbl_in(i).sfwt_flag                 := 'N';
            l_rulv_tbl_in(i).rule_information_category := 'ECE';
            l_rulv_tbl_in(i).rule_information1         := get_coverages_rec.EXC_COVERAGE_ID;
            l_rulv_tbl_in(i).std_template_yn           := 'N';
            l_rulv_tbl_in(i).warn_yn                   := 'Y';
            l_rulv_tbl_in(i).dnz_chr_id                := l_clev_tbl_In(i).dnz_chr_Id;
            l_rulv_tbl_in(i).id                        := okc_p_util.raw_to_number(sys_guid()); --Get_Seq_Id(get_coverages_rec.Coverage_ID);
            l_rulv_tbl_in(i).CREATION_DATE             := g_CREATION_DATE;
            l_rulv_tbl_in(i).CREATED_BY                := -1;
            l_rulv_tbl_in(i).LAST_UPDATE_DATE          := sysdate;
            l_rulv_tbl_in(i).LAST_UPDATED_BY           := -1;
            l_rulv_tbl_in(i).LAST_UPDATE_LOGIN         := -1;
            l_rulv_tbl_in(i).object_version_number     := 1;
            l_rulv_tbl_in(i).OBJECT2_ID1               := NULL;
            l_rulv_tbl_in(i).OBJECT3_ID1               := NULL;
            l_rulv_tbl_in(i).OBJECT2_ID2               := NULL;
            l_rulv_tbl_in(i).OBJECT3_ID2               := NULL;
            l_rulv_tbl_in(i).JTOT_OBJECT2_CODE         := NULL;
            l_rulv_tbl_in(i).JTOT_OBJECT3_CODE         := NULL;
            l_rulv_tbl_in(i).PRIORITY                  := NULL;
            l_rulv_tbl_in(i).COMMENTS                  := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE_CATEGORY        := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE1                := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE2                := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE3                := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE4                := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE5                := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE6                := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE7                := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE8                := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE9                := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE10               := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE11               := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE12               := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE13               := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE14               := NULL;
            l_rulv_tbl_in(i).ATTRIBUTE15               := NULL;
            l_rulv_tbl_in(i).TEXT                      := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION2         := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION3         := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION4         := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION5         := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION6         := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION7         := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION8         := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION9         := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION10        := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION11        := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION12        := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION13        := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION14        := NULL;
            l_rulv_tbl_in(i).RULE_INFORMATION15        := NULL;


                  --  	okc_rul_pvt.Insert_Row_Upg( l_return_status , l_rulv_tbl_in);
If l_validate_flag = 'Y' THEN
                  If l_rulv_tbl_in.count > 0 Then

           okc_rul_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rulv_tbl      =>    l_rulv_tbl_in,
                                x_rulv_tbl      =>    x_rulv_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
        End If;
ELSE
            	okc_rul_pvt.Insert_Row_Upg( l_return_status , l_rulv_tbl_in);

END IF;
                        l_rulv_tbl_in.delete;
        end if ;---End  rule for EXC_COVERAGE_ID (EXECPTION COVERAGE ID)

/*Complete Inserting Rule Informations */


            -- dbms_output.put_line('Before 0 Commit');
            commit;
            l_clev_tbl_in.delete;
            l_rgpv_tbl_in.delete;
            -- dbms_output.put_line('After 0 Delete');

    end loop;
          UPDATE oks_coverages_int_all
          SET    INTERFACED_STATUS_FLAG  = 'S',
                 LAST_UPDATED_BY         = -1,
                 LAST_UPDATE_DATE        = sysdate,
                 LAST_UPDATE_LOGIN       = -1
          WHERE  COVERAGE_ID = get_coverages_rec.coverage_id;

          if (get_okc_lines_cur%notfound)  then
                    close get_okc_lines_cur;
          end if;

        end loop;


     if (get_coverages_cur%notfound)
            then
                close get_coverages_cur;
          end if;
          -- dbms_output.put_line('Before 1 Commit');
           commit;
--end loop; --get_cov_id_cur
exception when others then
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20000,'Error in Business Process Interface');

end coverage_migrate;


PROCEDURE Business_Processes_migrate(P_FromId        IN  NUMBER,
                            P_ToId          IN  NUMBER,
                            P_VALIDATE_FLAG IN  VARCHAR2,
                            P_LOG_PARAMETER IN  VARCHAR2) IS

CURSOR get_buss_process_cur (p_fromid IN NUMBER,p_toid IN NUMBER) IS
SELECT
obp.coverage_bus_process_id,
obp.coverage_id,
obp.business_process_id,
obp.offset_duration,
obp.offset_period,
obp.start_date,
obp.end_date,
obp.price_list_id,
obp.discount_id,
obp.coverage_sunday_start_time,
obp.coverage_sunday_end_time,
obp.coverage_monday_start_time,
obp.coverage_monday_end_time,
obp.coverage_tuesday_start_time,
obp.coverage_tuesday_end_time,
obp.coverage_wednesday_start_time,
obp.coverage_wednesday_end_time,
obp.coverage_thursday_start_time,
obp.coverage_thursday_end_time,
obp.coverage_friday_start_time,
obp.coverage_friday_end_time,
obp.coverage_saturday_start_time,
obp.coverage_saturday_end_time,
obp.time_zone_id,
obp.reaction_name,
obp.reaction_description,
obp.reaction_time_id,
obp.reaction_severity_code,
obp.Incident_severity_id,
obp.sunday_reaction_times,
obp.monday_reaction_times,
obp.tuesday_reaction_times,
obp.wednesday_reaction_times,
obp.thursday_reaction_times,
obp.friday_reaction_times,
obp.saturday_reaction_times,
obp.work_through_yn,
obp.active_yn,
obp.sunday_resolution_times,
obp.monday_resolution_times,
obp.tuesday_resolution_times,
obp.wednesday_resolution_times,
obp.thursday_resolution_times,
obp.friday_resolution_times,
obp.saturday_resolution_times,
obp.preferred_resource_type,
obp.preferred_resource_id,
obp.attribute_category,
obp.attribute1,
obp.attribute2,
obp.attribute3,
obp.attribute4,
obp.attribute5,
obp.attribute6,
obp.attribute7,
obp.attribute8,
obp.attribute9,
obp.attribute10,
obp.attribute11,
obp.attribute12,
obp.attribute13,
obp.attribute14,
obp.attribute15,
okl.id cle_id,
okl.dnz_chr_id,
okl.sts_code,
okl.currency_code
FROM    oks_cov_txn_groups_int_all obp,
        okc_k_lines_b okl,
        oks_coverages_int_all cov,
        oks_con_lines_int_all lines,
        oks_con_headers_int_all head
WHERE   okl.upg_Orig_System_Ref= g_covline_ref
AND     okl.upg_Orig_System_Ref_Id = obp.Coverage_Id
AND     obp.coverage_id = cov.coverage_id
AND     cov.INTERFACED_STATUS_FLAG = 'S'
AND     cov.coverage_id = lines.coverage_id
AND     lines.INTERFACED_STATUS_FLAG = 'S'
AND     head.contract_id = lines.contract_id
AND     head.INTERFACED_STATUS_FLAG = 'S'
AND     head.batch_number between p_fromid and p_toid
AND     obp.interfaced_status_flag is null;

get_buss_process_rec get_buss_process_cur%rowtype;

l_validate_flag VARCHAR2(1) := p_validate_flag;

TYPE K_Status_rec IS RECORD (old_status Varchar2(30),new_status Varchar2(30));
TYPE K_Status_Tab is TABLE OF K_Status_Rec INDEX BY BINARY_Integer;
      g_creation_date           DATE;
      g_created_by              NUMBER;
      g_Last_updated_by         NUMBER;
      g_Last_update_date        date;
      g_Last_Update_Login       NUMBER;
      g_COVERAGE_TXN_GROUP_ID   NUMBER;

/*-----------------------------------------*/
    	 COVERAGE_BUSS_PROCESS_ID_tbl                  NUM_tbl_type;
	     COVERAGE_ID_tbl                               NUM_tbl_type;
    	 BUSINESS_PROCESS_ID_tbl                       NUM_tbl_type;
       	 OFFSET_DURATION_tbl                           NUM_tbl_type;
    	 OFFSET_PERIOD_tbl                             VC15_tbl_type;
         CURRENCY_CODE_Tbl		                        Vc15_Tbl_Type;
    	 START_DATE_tbl                       DATE_tbl_type;
    	 END_DATE_tbl                         DATE_tbl_type;
    	 PRICE_LIST_ID_tbl                             NUM_tbl_type;
    	 DISCOUNT_ID_tbl                               NUM_tbl_type;
    	 CONTEXT_tbl                                   VC150_tbl_type;
    	 MANUFACTURING_ORG_ID_tbl                      NUM_tbl_type;
    	 SUBINVENTORY_CODE_tbl                         VC15_tbl_type;
         TIME_ZONE_ID_TBL                           NUM_tbl_type;
    	 COVERAGE_SUN_START_TIME_tbl                DATE_tbl_type;
    	 COVERAGE_SUN_END_TIME_tbl                  DATE_tbl_type;
    	 COVERAGE_MON_START_TIME_tbl                DATE_tbl_type;
    	 COVERAGE_MON_END_TIME_tbl                  DATE_tbl_type;
    	 COVERAGE_TUE_START_TIME_tbl                DATE_tbl_type;
    	 COVERAGE_TUE_END_TIME_tbl                 DATE_tbl_type;
    	 COVERAGE_WED_START_TIME_tbl                  DATE_tbl_type;
    	 COVERAGE_WED_END_TIME_tbl                     DATE_tbl_type;
    	 COVERAGE_THU_START_TIME_tbl              DATE_tbl_type;
    	 COVERAGE_THU_END_TIME_tbl                DATE_tbl_type;
         COVERAGE_FRI_START_TIME_tbl                DATE_tbl_type;
    	 COVERAGE_FRI_END_TIME_tbl                  DATE_tbl_type;
    	 COVERAGE_SAT_START_TIME_tbl              DATE_tbl_type;
    	 COVERAGE_SAT_END_TIME_tbl                DATE_tbl_type;
    	 REACTION_NAME_tbl                             VC15_tbl_type;
         Incident_severity_id_Tbl                       NUM_TBL_TYPE;
         REACTION_TIME_ID_tbl                              NUM_tbl_type;
    	 REACTION_DESCRIPTION_tbl                      VC150_tbl_type;
         REACTION_security_code_tbl                 VC150_tbl_type;
    	 SUN_REACTION_TIMES_tbl                    Num_Tbl_Type;
    	 MON_REACTION_TIMES_tbl                     Num_Tbl_Type;
    	 TUE_REACTION_TIMES_tbl                    Num_Tbl_Type;
    	 WED_REACTION_TIMES_tbl                  Num_Tbl_Type;
    	 THU_REACTION_TIMES_tbl                   Num_Tbl_Type;
    	 FRI_REACTION_TIMES_tbl                     Num_Tbl_Type;
    	 SAT_REACTION_TIMES_tbl                   Num_Tbl_Type;
    	 ALWAYS_COVERED_tbl                            VC1_tbl_type;
    	 RESOLUTION_TIME_ID_tbl                        NUM_tbl_type;
    	 RESOLUTION_NAME_tbl                           VC150_tbl_type;
    	 RESOLUTION_DESCRIPTION_tbl                    VC150_tbl_type;
    	 SUN_RESOLUTION_TIMES_tbl                   NUM_tbl_type;
    	 MON_RESOLUTION_TIMES_tbl                   NUM_tbl_type;
    	 TUE_RESOLUTION_TIMES_tbl                  NUM_tbl_type;
    	 WED_RESOLUTION_TIMES_tbl                NUM_tbl_type;
    	 THU_RESOLUTION_TIMES_tbl                 NUM_tbl_type;
    	 FRI_RESOLUTION_TIMES_tbl                   NUM_tbl_type;
    	 SAT_RESOLUTION_TIMES_tbl                 NUM_tbl_type;
         work_through_yn_tbl                        VC1_tbl_type;
         PREFERRED_RESOURCE_TYPE_tbl                   VC150_tbl_type;
         active_yn_tbl                                  VC1_tbl_type;
    	 START_DATE_ACTIVE_tbl                         DATE_tbl_type;
    	 END_DATE_ACTIVE_tbl                           DATE_tbl_type;
         PREFERRED_RESOURCE_ID_tbl                      NUM_tbl_type;
    	 ATTRIBUTE_CATEGORY_tbl                        VC150_tbl_type;
    	 ATTRIBUTE1_tbl                                VC150_tbl_type;
    	 ATTRIBUTE2_tbl                                VC150_tbl_type;
    	 ATTRIBUTE3_tbl                                VC150_tbl_type;
    	 ATTRIBUTE4_tbl                                VC150_tbl_type;
    	 ATTRIBUTE5_tbl                                VC150_tbl_type;
    	 ATTRIBUTE6_tbl                                VC150_tbl_type;
    	 ATTRIBUTE7_tbl                                VC150_tbl_type;
    	 ATTRIBUTE8_tbl                                VC150_tbl_type;
    	 ATTRIBUTE9_tbl                                VC150_tbl_type;
    	 ATTRIBUTE10_tbl                               VC150_tbl_type;
    	 ATTRIBUTE11_tbl                               VC150_tbl_type;
    	 ATTRIBUTE12_tbl                               VC150_tbl_type;
    	 ATTRIBUTE13_tbl                               VC150_tbl_type;
    	 ATTRIBUTE14_tbl                               VC150_tbl_type;
    	 ATTRIBUTE15_tbl                               VC150_tbl_type;
    	 id_tbl                                        NUM_TBL_TYPE;
         dnz_chr_id_tbl                                NUM_TBL_TYPE;
         sts_code_tbl                                  VC30_tbl_type;

l_status_tab              K_Status_Tab;
l_Time_Unit               VARCHAR2(3);
l_return_status           VARCHAR2(3);
l_BP_start_date           Date;
  l_error_message           VARCHAR2(2000);
FUNCTION Get_new_status(p_k_status_id IN Number)
 RETURN Varchar2 IS
   l_new_status Varchar2(30);
BEGIN
   Return(l_status_tab(p_k_status_id).new_status);
END Get_new_status;

FUNCTION Get_PrefEng(P_Name IN VARCHAR2)
 RETURN VARCHAR2 IS
   l_Id1  Varchar2(30);
CURSOR Res_Cur IS
SELECT Id1 FROM OKX_RESOURCES_V
WHERE Description = P_Name;
BEGIN
OPEN Res_Cur;
FETCH Res_Cur INTO l_Id1;
	IF Res_Cur%NOTFOUND
	THEN	l_Id1:=NULL;
	END IF;
CLOSE Res_Cur;
RETURN l_Id1;
END Get_PrefEng;


FUNCTION GetTimeUom(P_Uom_Code IN VARCHAR2)
   RETURN Varchar2 IS
   l_TimeUnit VARCHAR2(3):= NULL;
  BEGIN
  IF Upper(P_Uom_Code)='DAY'
  THEN l_TimeUnit:='DAY';
  ELSIF Upper(P_Uom_Code)='HOUR'
  THEN l_TimeUnit:='HR';
  ELSIF Upper(P_Uom_Code)='MINUTE'
  THEN l_TimeUnit:='MIN';
  ELSIF Upper(P_Uom_Code)='WEEK'
  THEN l_TimeUnit:='WK';
  ELSIF Upper(P_Uom_Code)='MONTH'
  THEN l_TimeUnit:='MTH';
  ELSIF Upper(P_Uom_Code)='YEAR'
  THEN l_TimeUnit:='YR';
  END IF;
  RETURN l_TimeUnit;
  END  GetTimeUom;

PROCEDURE Fetch_K_Status IS
CURSOR K_Status_Cur IS
	SELECT old.contract_status_id k_id, upper(old.name) old_stat,
     	  decode(new.code, NULL,'ENTERED',upper(old.name)) new_stat
	FROM   OKC_STATUSES_V new, CS_CONTRACT_STATUSES old
	WHERE  upper(new.code(+)) = upper(old.name);
 BEGIN
  FOR K_Status_Rec IN K_Status_Cur
  LOOP
	l_status_tab(K_Status_Rec.k_id).old_status := K_Status_Rec.old_stat;
     l_status_tab(K_Status_Rec.k_id).new_status := K_Status_Rec.new_stat;
  END LOOP;
END Fetch_K_Status;

BEGIN --- MAIN BEGIN OF Business_Processes_migrate procedure -----
Fetch_K_Status;
open get_buss_process_cur (p_fromid,p_toid);
loop
    BEGIN
    FETCH get_buss_process_cur BULK COLLECT into

   	 COVERAGE_BUSS_PROCESS_ID_tbl,
	     COVERAGE_ID_tbl,
    	 BUSINESS_PROCESS_ID_tbl,
    	 OFFSET_DURATION_tbl,
    	 OFFSET_PERIOD_tbl,
    	 START_DATE_tbl,
    	 END_DATE_tbl,
    	 PRICE_LIST_ID_tbl,
    	 DISCOUNT_ID_tbl,
    	 COVERAGE_SUN_START_TIME_tbl,
    	 COVERAGE_SUN_END_TIME_tbl,
    	 COVERAGE_MON_START_TIME_tbl,
    	 COVERAGE_MON_END_TIME_tbl,
    	 COVERAGE_TUE_START_TIME_tbl,
    	 COVERAGE_TUE_END_TIME_tbl,
    	 COVERAGE_WED_START_TIME_tbl,
    	 COVERAGE_WED_END_TIME_tbl,
    	 COVERAGE_THU_START_TIME_tbl,
    	 COVERAGE_THU_END_TIME_tbl,
         COVERAGE_FRI_START_TIME_tbl,
    	 COVERAGE_FRI_END_TIME_tbl,
    	 COVERAGE_SAT_START_TIME_tbl,
    	 COVERAGE_SAT_END_TIME_tbl,
         time_zone_id_tbl,
    	 REACTION_NAME_tbl,
         REACTION_DESCRIPTION_TBL,
         REACTION_TIME_ID_TBL,
         REACTION_security_code_tbl,
         Incident_severity_id_Tbl,
    	 SUN_REACTION_TIMES_tbl,
    	 MON_REACTION_TIMES_tbl,
    	 TUE_REACTION_TIMES_tbl,
    	 WED_REACTION_TIMES_tbl,
    	 THU_REACTION_TIMES_tbl,
    	 FRI_REACTION_TIMES_tbl,
    	 SAT_REACTION_TIMES_tbl,
    	 work_through_yn_tbl,
         active_yn_tbl,
    	 SUN_RESOLUTION_TIMES_tbl,
    	 MON_RESOLUTION_TIMES_tbl,
    	 TUE_RESOLUTION_TIMES_tbl,
    	 WED_RESOLUTION_TIMES_tbl,
    	 THU_RESOLUTION_TIMES_tbl,
    	 FRI_RESOLUTION_TIMES_tbl,
    	 SAT_RESOLUTION_TIMES_tbl,
    	 PREFERRED_RESOURCE_TYPE_tbl,
    	 PREFERRED_RESOURCE_ID_tbl,
    	 ATTRIBUTE_CATEGORY_tbl,
    	 ATTRIBUTE1_tbl,
    	 ATTRIBUTE2_tbl,
    	 ATTRIBUTE3_tbl,
    	 ATTRIBUTE4_tbl,
    	 ATTRIBUTE5_tbl,
    	 ATTRIBUTE6_tbl,
    	 ATTRIBUTE7_tbl,
    	 ATTRIBUTE8_tbl,
    	 ATTRIBUTE9_tbl,
    	 ATTRIBUTE10_tbl,
    	 ATTRIBUTE11_tbl,
    	 ATTRIBUTE12_tbl,
    	 ATTRIBUTE13_tbl,
    	 ATTRIBUTE14_tbl,
    	 ATTRIBUTE15_tbl,
    	 id_tbl,
         dnz_chr_id_tbl,
         sts_code_tbl,
         currency_code_tbl
         LIMIT 1000;


         IF (COVERAGE_BUSS_PROCESS_ID_tbl.COUNT > 0) then
            ---- dbms_output.put_line('Test');
            FOR i IN COVERAGE_BUSS_PROCESS_ID_tbl.FIRST .. COVERAGE_BUSS_PROCESS_ID_tbl.LAST
            LOOP
                g_CREATION_DATE                 := sysdate;
                g_CREATED_BY                    := -1;
                g_LAST_UPDATE_DATE              := sysdate;
                g_LAST_UPDATED_BY               := -1;
                g_LAST_UPDATE_LOGIN             := -1;
--                g_COVERAGE_TXN_GROUP_ID         := COVERAGE_TXN_GROUP_ID_Tbl(i);

----Line Creation For Business Process with LSE_ID = 3 --
                    l_Time_Unit      :=  GetTimeUOM(offset_period_Tbl(i));

                  	l_BP_start_date  :=  OKC_TIME_UTIL_PUB.get_enddate(
                                                        START_DATE_tbl(i),
                                                        l_time_unit,
                                                        offset_duration_Tbl(i));

    l_clev_tbl_in(i).id                 := okc_p_util.raw_to_number(sys_guid()); --Get_Seq_Id(g_COVERAGE_TXN_GROUP_ID); --okc_p_util.raw_to_number(sys_guid());
    l_clev_tbl_in(i).CREATION_DATE      := sysdate;
    l_clev_tbl_in(i).CREATED_BY         := g_CREATED_BY;
    l_clev_tbl_in(i).LAST_UPDATE_DATE   := g_LAST_UPDATE_DATE;
    l_clev_tbl_in(i).LAST_UPDATED_BY    := g_LAST_UPDATED_BY;
    l_clev_tbl_in(i).LAST_UPDATE_LOGIN  := g_LAST_UPDATE_LOGIN;
    l_clev_tbl_in(i).object_version_number        := 1;
    l_clev_tbl_in(i).dnz_chr_id	        := dnz_chr_id_tbl(i);
    l_clev_tbl_in(i).cle_id		        := ID_Tbl(i);
    l_clev_tbl_in(i).sfwt_flag	        :='N';
    l_clev_tbl_in(i).lse_id		        := 3;
--	l_clev_tbl_in(i).sts_code	         :=Get_New_Status(Contract_Line_Status_Id_Tbl(i));
	l_clev_tbl_in(i).sts_code	         :=sts_code_tbl(i);
	l_clev_tbl_in(i).display_sequence	 :=1;
	l_clev_tbl_in(i).Name		:='MIGRATED';      --Name;
	l_clev_tbl_in(i).Currency_Code	:=Currency_Code_Tbl(i);
	l_clev_tbl_in(i).exception_yn	:='N';  --	clarify
	l_clev_tbl_in(i).start_date	:=START_DATE_tbl(i);
	l_clev_tbl_in(i).end_date		:=END_DATE_tbl(i);
               -- dbms_output.put_line('Test3');
	l_clev_tbl_in(i).attribute1	          :=Attribute1_Tbl(i);
	l_clev_tbl_in(i).attribute2	          :=Attribute2_Tbl(i);
	l_clev_tbl_in(i).attribute3	          :=Attribute3_Tbl(i);
	l_clev_tbl_in(i).attribute4	          :=Attribute4_Tbl(i);
	l_clev_tbl_in(i).attribute5	          :=Attribute5_Tbl(i);
	l_clev_tbl_in(i).attribute6	          :=Attribute6_Tbl(i);
	l_clev_tbl_in(i).attribute7	          :=Attribute7_Tbl(i);
	l_clev_tbl_in(i).attribute8	          :=Attribute8_Tbl(i);
	l_clev_tbl_in(i).attribute9	          :=Attribute9_Tbl(i);
	l_clev_tbl_in(i).attribute10	          :=Attribute10_Tbl(i);
	l_clev_tbl_in(i).attribute11	          :=Attribute11_Tbl(i);
	l_clev_tbl_in(i).attribute12	          :=Attribute12_Tbl(i);
	l_clev_tbl_in(i).attribute13	          :=Attribute13_Tbl(i);
	l_clev_tbl_in(i).attribute14	          :=Attribute14_Tbl(i);
	l_clev_tbl_in(i).attribute15	          :=Attribute15_Tbl(i);
	l_clev_tbl_in(i).attribute_Category	      :=    attribute_Category_tbl(i);
               -- -- dbms_output.put_line('Test4');
    l_clev_tbl_in(i).Upg_Orig_System_Ref    :=g_bpline_ref;
    l_clev_tbl_in(i).Upg_Orig_System_Ref_Id :=COVERAGE_BUSS_PROCESS_ID_tbl(i);
    l_clev_tbl_in(i).INVOICE_LINE_LEVEL_IND                  :=Null;
    l_clev_tbl_in(i).DPAS_RATING                             :=Null;
    l_clev_tbl_in(i).TEMPLATE_USED                            :=Null;
    l_clev_tbl_in(i).PRICE_TYPE                             :=Null;
    --l_clev_tbl_in(i).UOM_CODE                                :=Null;
    l_clev_tbl_in(i).LINE_NUMBER                     		:='3';
    l_clev_tbl_in(i).CHR_ID                                   :=Null;
    l_clev_tbl_in(i).TRN_CODE                                 :=Null;
    l_clev_tbl_in(i).LAST_UPDATE_LOGIN                        :=Null;
    l_clev_tbl_in(i).HIDDEN_IND                               :=Null;
    l_clev_tbl_in(i).DATE_TERMINATED                        :=Null;
    l_clev_tbl_in(i).CLE_ID_RENEWED_TO                        :=Null;
    l_clev_tbl_in(i).CURRENCY_CODE_RENEWED                    :=Null;
    l_clev_tbl_in(i).PRICE_NEGOTIATED_RENEWED                 :=Null;
    l_clev_tbl_in(i).cle_id_renewed           :=NULL;
    l_clev_tbl_in(i).comments                 :=NULL;
    l_clev_tbl_in(i).price_unit               :=NULL;
    l_clev_tbl_in(i).price_unit_percent       :=NULL;
    l_clev_tbl_in(i).price_negotiated         :=NULL;
    l_clev_tbl_in(i).price_level_ind          :='N';
    l_clev_tbl_in(i).block23text              :=NULL;
        l_clev_tbl_in(i).program_application_id:= fnd_global.prog_appl_id;
        l_clev_tbl_in(i).program_id:= fnd_global.CONC_PROGRAM_ID;
             --   -- dbms_output.put_line('Test5');
IF COVERAGE_BUSS_PROCESS_ID_tbl(i) IS NOT NULL
THEN

    l_cimv_tbl_in(i).cle_id			              := l_clev_tbl_in(i).Id;
	l_cimv_tbl_in(i).object1_id1		          := COVERAGE_BUSS_PROCESS_ID_tbl(i);
  	l_cimv_tbl_in(i).object1_id2		          := '#';
	l_cimv_tbl_in(i).jtot_object1_code		      := 'OKX_BUSIPROC';
	l_cimv_tbl_in(i).uom_code	                  := Null;
	l_cimv_tbl_in(i).exception_yn		          := 'N';
	l_cimv_tbl_in(i).number_of_items	          := 1;
    l_cimv_tbl_in(i).dnz_chr_id			          := dnz_chr_id_tbl(i);
    l_cimv_tbl_in(i).id                           := okc_p_util.raw_to_number(sys_guid()); --Get_Seq_Id(g_COVERAGE_TXN_GROUP_ID); --okc_p_util.raw_to_number(sys_guid());
	l_cimv_tbl_in(i).CREATION_DATE                := g_CREATION_DATE;
    l_cimv_tbl_in(i).CREATED_BY                   := g_CREATED_BY;
    l_cimv_tbl_in(i).LAST_UPDATE_DATE             := g_LAST_UPDATE_DATE;
    l_cimv_tbl_in(i).LAST_UPDATED_BY              := g_LAST_UPDATED_BY;
    l_cimv_tbl_in(i).LAST_UPDATE_LOGIN            := g_LAST_UPDATE_LOGIN;
    l_cimv_tbl_in(i).object_version_number        := 1;
    l_cimv_tbl_in(i).CHR_ID                       := Null;
    l_cimv_tbl_in(i).CLE_ID_FOR                   := Null;
    l_cimv_tbl_in(i).PRICED_ITEM_YN               := Null;
    l_cimv_tbl_in(i).UPG_ORIG_SYSTEM_REF          := Null;
    l_cimv_tbl_in(i).UPG_ORIG_SYSTEM_REF_ID       := Null;
        l_cimv_tbl_in(i).program_application_id:= fnd_global.prog_appl_id;
        l_cimv_tbl_in(i).program_id:= fnd_global.CONC_PROGRAM_ID;
EnD if;

  ---- Creation For Rule_Groups in OKC_RULE_GROUPS_V

     l_rgpv_tbl_in(i).cle_id		             := l_clev_tbl_in(i).Id;
     l_rgpv_tbl_in(i).sfwt_flag	                 := 'N';
     l_rgpv_tbl_in(i).rgd_code	                 := 'SVC_K';
     l_rgpv_tbl_in(i).rgp_type	                 := 'KRG';
     l_rgpv_tbl_in(i).dnz_chr_id                := dnz_chr_id_tbl(i);
     l_rgpv_tbl_in(i).id                        :=  okc_p_util.raw_to_number(sys_guid());
     l_rgpv_tbl_in(i).CREATION_DATE             := g_CREATION_DATE;
     l_rgpv_tbl_in(i).CREATED_BY                := g_CREATED_BY;
     l_rgpv_tbl_in(i).LAST_UPDATE_DATE          := g_LAST_UPDATE_DATE;
     l_rgpv_tbl_in(i).LAST_UPDATED_BY           := g_LAST_UPDATED_BY;
     l_rgpv_tbl_in(i).LAST_UPDATE_LOGIN         := g_LAST_UPDATE_LOGIN;
     l_rgpv_tbl_in(i).object_version_number        := 1;
     l_rgpv_tbl_in(i).CHR_ID                                   :=Null;
     l_rgpv_tbl_in(i).PARENT_RGP_ID                            :=Null;
	l_rgpv_tbl_in(i).SAT_CODE                                 :=Null;
	l_rgpv_tbl_in(i).COMMENTS                                 :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE_CATEGORY                       :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE1                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE2                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE3                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE4                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE5                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE6                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE7                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE8                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE9                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE10                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE11                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE12                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE13                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE14                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE15                              :=Null;


 -- dbms_output.put_line('Before Time Period');


  -------------------OFFSET PERIOD -----

l_Time_Unit:=GetTimeUOM(offset_period_Tbl(i));
-- dbms_output.put_line('Value of l_time_unit='||l_time_unit);
IF l_Time_Unit IS NULL	THEN NULL;
--   RAISE e_Error;
-- dbms_output.put_line('Error');
ELSE
    IF l_Time_Unit is NOT NULL THEN
/*------------------------------------------------------------------------------------------------*/
 l_isev_rel_tbl_in(i).dnz_chr_id                    :=dnz_chr_id_tbl(i);
  l_isev_rel_tbl_in(i).id                            :=okc_p_util.raw_to_number(sys_guid());
  l_isev_rel_tbl_in(i).object_version_number         :=1;
  l_isev_rel_tbl_in(i).sfwt_flag                     :='N';
  l_isev_rel_tbl_in(i).spn_id                        :=Null;
  l_isev_rel_tbl_in(i).uom_code                      :=l_time_unit;
  l_isev_rel_tbl_in(i).start_tve_id_offset           :=okc_p_util.raw_to_number(sys_guid());
  l_isev_rel_tbl_in(i).tve_id_ended                  :=Null;
  l_isev_rel_tbl_in(i).tve_id_limited                :=Null;
  l_isev_rel_tbl_in(i).tze_id                        :=Null;
  l_isev_rel_tbl_in(i).description                   :=Null;
  l_isev_rel_tbl_in(i).short_description             :=Null;
  l_isev_rel_tbl_in(i).comments                      :=Null;
  l_isev_rel_tbl_in(i).duration                      :=offset_duration_Tbl(i);
  l_isev_rel_tbl_in(i).operator                      :=Null;
  l_isev_rel_tbl_in(i).before_after                  :='A';
  l_isev_rel_tbl_in(i).attribute_category            :=Null;
  l_isev_rel_tbl_in(i).attribute1                    :=Null;
  l_isev_rel_tbl_in(i).attribute2                    :=Null;
  l_isev_rel_tbl_in(i).attribute3                    :=Null;
  l_isev_rel_tbl_in(i).attribute4                    :=Null;
  l_isev_rel_tbl_in(i).attribute5                    :=Null;
  l_isev_rel_tbl_in(i).attribute6                    :=Null;
  l_isev_rel_tbl_in(i).attribute7                    :=Null;
  l_isev_rel_tbl_in(i).attribute8                    :=Null;
  l_isev_rel_tbl_in(i).attribute9                    :=Null;
  l_isev_rel_tbl_in(i).attribute10                   :=Null;
  l_isev_rel_tbl_in(i).attribute11                   :=Null;
  l_isev_rel_tbl_in(i).attribute12                   :=Null;
  l_isev_rel_tbl_in(i).attribute13                   :=Null;
  l_isev_rel_tbl_in(i).attribute14                   :=Null;
  l_isev_rel_tbl_in(i).attribute15                   :=Null;
  l_isev_rel_tbl_in(i).CREATION_DATE                 := sysdate;
  l_isev_rel_tbl_in(i).CREATED_BY                    := -1;
  l_isev_rel_tbl_in(i).LAST_UPDATE_DATE              := sysdate;
  l_isev_rel_tbl_in(i).LAST_UPDATED_BY               := -1;
  l_isev_rel_tbl_in(i).LAST_UPDATE_LOGIN             := -1;
/*------------------------------------------------------------------------------------------------*/

 -- dbms_output.put_line('After Time Period');
 -- dbms_output.put_line('Value of offset_duration_Tbl(i='||offset_duration_Tbl(i));
 -- dbms_output.put_line('Value of l_time_unit='||l_time_unit);
 -- dbms_output.put_line('Value of START_DATE_tbl(i)='||TO_CHAR(START_DATE_tbl(i)));
l_isev_ext_tbl_in(i).start_date:=OKC_TIME_UTIL_PUB.get_enddate(
                                                                    START_DATE_tbl(i),
                                                                    l_time_unit,
                                                                    offset_duration_Tbl(i)
                                                                  );
  -- dbms_output.put_line('Value of l_isev_ext_tbl_in(i).start_date='||TO_CHAR(l_isev_ext_tbl_in(i).start_date));

  l_isev_ext_tbl_in(i).end_date  	                 := end_date_tbl(i);
  -- dbms_output.put_line('Value of l_isev_ext_tbl_in(i).end_date='||TO_CHAR(l_isev_ext_tbl_in(i).end_date));

  l_isev_ext_tbl_in(i).dnz_chr_id                    :=dnz_chr_id_tbl(i);
--  l_isev_ext_tbl_in(i).id                            :=okc_p_util.raw_to_number(sys_guid());
  l_isev_ext_tbl_in(i).id                            :=l_isev_rel_tbl_in(i).start_tve_id_offset;
  l_isev_ext_tbl_in(i).object_version_number         :=1;
  l_isev_ext_tbl_in(i).sfwt_flag                     :='N';
  l_isev_ext_tbl_in(i).spn_id                        :=Null;
  l_isev_ext_tbl_in(i).uom_code                      :=l_time_unit;
  l_isev_ext_tbl_in(i).tve_id_ended                  :=Null;
  l_isev_ext_tbl_in(i).tve_id_limited                :=Null;
  l_isev_ext_tbl_in(i).tze_id                        :=Null;
  l_isev_ext_tbl_in(i).description                   :=Null;
  l_isev_ext_tbl_in(i).short_description             :=Null;
  l_isev_ext_tbl_in(i).comments                      :=Null;
  l_isev_ext_tbl_in(i).duration                      :=offset_duration_Tbl(i);
  l_isev_ext_tbl_in(i).operator                      :=Null;
  l_isev_ext_tbl_in(i).before_after                  :=Null;
  l_isev_ext_tbl_in(i).attribute_category            :=Null;
  l_isev_ext_tbl_in(i).attribute1                    :=Null;
  l_isev_ext_tbl_in(i).attribute2                    :=Null;
  l_isev_ext_tbl_in(i).attribute3                    :=Null;
  l_isev_ext_tbl_in(i).attribute4                    :=Null;
  l_isev_ext_tbl_in(i).attribute5                    :=Null;
  l_isev_ext_tbl_in(i).attribute6                    :=Null;
  l_isev_ext_tbl_in(i).attribute7                    :=Null;
  l_isev_ext_tbl_in(i).attribute8                    :=Null;
  l_isev_ext_tbl_in(i).attribute9                    :=Null;
  l_isev_ext_tbl_in(i).attribute10                   :=Null;
  l_isev_ext_tbl_in(i).attribute11                   :=Null;
  l_isev_ext_tbl_in(i).attribute12                   :=Null;
  l_isev_ext_tbl_in(i).attribute13                   :=Null;
  l_isev_ext_tbl_in(i).attribute14                   :=Null;
  l_isev_ext_tbl_in(i).attribute15                   :=Null;
  l_isev_ext_tbl_in(i).CREATION_DATE                 := sysdate;
  l_isev_ext_tbl_in(i).CREATED_BY                    := -1;
  l_isev_ext_tbl_in(i).LAST_UPDATE_DATE              := sysdate;
  l_isev_ext_tbl_in(i).LAST_UPDATED_BY               := -1;
  l_isev_ext_tbl_in(i).LAST_UPDATE_LOGIN             := -1;

  -- dbms_output.put_line('Value of l_isev_ext_tbl_in(i).uom_code='||l_isev_ext_tbl_in(i).uom_code);

   l_rulv_tbl_in(i).rgp_id	       	                 := l_rgpv_tbl_in(i).id;
   l_rulv_tbl_in(i).sfwt_flag                       := 'N';
   l_rulv_tbl_in(i).rule_information_category       := 'OFS';
   l_rulv_tbl_in(i).rule_information1               := l_isev_ext_tbl_in(i).id;
   l_rulv_tbl_in(i).dnz_chr_id                      := l_clev_tbl_in(i).dnz_chr_id;
   l_rulv_tbl_in(i).std_template_yn                 := 'N';
   l_rulv_tbl_in(i).warn_YN                         := 'N';
   l_rulv_tbl_in(i).id                              :=okc_p_util.raw_to_number(sys_guid()); --okc_p_util.raw_to_number(sys_guid());
   l_rulv_tbl_in(i).CREATION_DATE                   := sysdate;
   l_rulv_tbl_in(i).CREATED_BY                      := -1;
   l_rulv_tbl_in(i).LAST_UPDATE_DATE                := sysdate;
   l_rulv_tbl_in(i).LAST_UPDATED_BY                 := -1;
   l_rulv_tbl_in(i).LAST_UPDATE_LOGIN               := -1;
   l_rulv_tbl_in(i).object_version_number           := 1;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).OBJECT1_ID1               := NULL;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).OBJECT2_ID1               := NULL;
           l_rulv_tbl_in(i).OBJECT3_ID1               := NULL;
           l_rulv_tbl_in(i).OBJECT2_ID2               := NULL;
           l_rulv_tbl_in(i).OBJECT3_ID2               := NULL;
           l_rulv_tbl_in(i).JTOT_OBJECT2_CODE         := NULL;
           l_rulv_tbl_in(i).JTOT_OBJECT3_CODE         := NULL;
           l_rulv_tbl_in(i).PRIORITY                  := NULL;
           l_rulv_tbl_in(i).COMMENTS                  := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE_CATEGORY        := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE1                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE2                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE3                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE4                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE5                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE6                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE7                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE8                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE9                := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE10               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE11               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE12               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE13               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE14               := NULL;
           l_rulv_tbl_in(i).ATTRIBUTE15               := NULL;
           l_rulv_tbl_in(i).TEXT                      := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION2         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION3         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION4         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION5         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION6         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION7         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION8         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION9         := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION10        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION11        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION12        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION13        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION14        := NULL;
           l_rulv_tbl_in(i).RULE_INFORMATION15        := NULL;


/*----------------------------------------------------------------------

--  -- dbms_output.put_line('Value of l_isev_rel_tbl_in(i+1000.end_date='||TO_CHAR(l_isev_rel_tbl_in(i+1000.end_date));



-------------------------------------------------------------------------*/
  END IF;
    END IF;


  IF  PRICE_LIST_ID_Tbl(i) IS NOT NULL    THEN
/*
     rulv_ctr := rulv_ctr + 1;
     INT_INITIALIZE_ALL_PVT.Clear_Rules_Table;
*/
   l_rulv_tbl_in(i+1000).rgp_id	       	           := l_rgpv_tbl_in(i).id;
   l_rulv_tbl_in(i+1000).sfwt_flag                 := 'N';
   l_rulv_tbl_in(i+1000).rule_information_category := 'PRE';
   l_rulv_tbl_in(i+1000).std_template_yn           := 'N';
   l_rulv_tbl_in(i+1000).warn_YN                  := 'N';
   l_rulv_tbl_in(i+1000).OBJECT1_ID1         	  := PRICE_LIST_ID_Tbl(i);
   l_rulv_tbl_in(i+1000).OBJECT1_ID2         	  := '#';
   l_rulv_tbl_in(i+1000).JTOT_OBJECT1_code        := 'OKX_PRICE';
   l_rulv_tbl_in(i+1000).dnz_chr_id          	  := dnz_chr_id_tbl(i);
   l_rulv_tbl_in(i+1000).id                       :=  okc_p_util.raw_to_number(sys_guid()); --okc_p_util.raw_to_number(sys_guid());
   l_rulv_tbl_in(i+1000).CREATION_DATE            := sysdate;
   l_rulv_tbl_in(i+1000).CREATED_BY                 := -1;
   l_rulv_tbl_in(i+1000).LAST_UPDATE_DATE           := sysdate;
   l_rulv_tbl_in(i+1000).LAST_UPDATED_BY            := -1;
   l_rulv_tbl_in(i+1000).LAST_UPDATE_LOGIN          := -1;
   l_rulv_tbl_in(i+1000).object_version_number      := 1;
           l_rulv_tbl_in(i+1000).PRIORITY                  := NULL;
           l_rulv_tbl_in(i+1000).OBJECT2_ID1               := NULL;
           l_rulv_tbl_in(i+1000).OBJECT3_ID1               := NULL;
           l_rulv_tbl_in(i+1000).OBJECT2_ID2               := NULL;
           l_rulv_tbl_in(i+1000).OBJECT3_ID2               := NULL;
           l_rulv_tbl_in(i+1000).JTOT_OBJECT2_CODE         := NULL;
           l_rulv_tbl_in(i+1000).JTOT_OBJECT3_CODE         := NULL;
           l_rulv_tbl_in(i+1000).PRIORITY                  := NULL;
           l_rulv_tbl_in(i+1000).COMMENTS                  := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE_CATEGORY        := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE1                := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE2                := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE3                := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE4                := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE5                := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE6                := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE7                := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE8                := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE9                := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE10               := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE11               := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE12               := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE13               := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE14               := NULL;
           l_rulv_tbl_in(i+1000).ATTRIBUTE15               := NULL;
           l_rulv_tbl_in(i+1000).TEXT                      := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION2         := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION3         := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION4         := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION5         := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION6         := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION7         := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION8         := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION9         := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION10        := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION11        := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION12        := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION13        := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION14        := NULL;
           l_rulv_tbl_in(i+1000).RULE_INFORMATION15        := NULL;

End If;

   l_rulv_tbl_in(i+3000).rgp_id	       	           := l_rgpv_tbl_in(i).id;
   l_rulv_tbl_in(i+3000).sfwt_flag                 := 'N';
   l_rulv_tbl_in(i+3000).rule_information_category := 'CVR';
   l_rulv_tbl_in(i+3000).rule_information1         := null;
   l_rulv_tbl_in(i+3000).std_template_yn           := 'N';
   l_rulv_tbl_in(i+3000).warn_YN                   := 'N';
   l_rulv_tbl_in(i+3000).dnz_chr_id	       	       := dnz_chr_id_tbl(i);
   l_rulv_tbl_in(i+3000).id                        := okc_p_util.raw_to_number(sys_guid());--Get_Seq_Id(g_COVERAGE_TXN_GROUP_ID); --okc_p_util.raw_to_number(sys_guid());
   l_rulv_tbl_in(i+3000).CREATION_DATE             := g_CREATION_DATE;
   l_rulv_tbl_in(i+3000).CREATED_BY                := g_CREATED_BY;
   l_rulv_tbl_in(i+3000).LAST_UPDATE_DATE          := g_LAST_UPDATE_DATE;
   l_rulv_tbl_in(i+3000).LAST_UPDATED_BY           := g_LAST_UPDATED_BY;
   l_rulv_tbl_in(i+3000).LAST_UPDATE_LOGIN         := g_LAST_UPDATE_LOGIN;
   l_rulv_tbl_in(i+3000).object_version_number     := 1;
           l_rulv_tbl_in(i+3000).PRIORITY                  := NULL;
           l_rulv_tbl_in(i+3000).OBJECT2_ID1               := NULL;
           l_rulv_tbl_in(i+3000).OBJECT3_ID1               := NULL;
           l_rulv_tbl_in(i+3000).OBJECT2_ID2               := NULL;
           l_rulv_tbl_in(i+3000).OBJECT3_ID2               := NULL;
           l_rulv_tbl_in(i+3000).JTOT_OBJECT2_CODE         := NULL;
           l_rulv_tbl_in(i+3000).JTOT_OBJECT3_CODE         := NULL;
           l_rulv_tbl_in(i+3000).PRIORITY                  := NULL;
           l_rulv_tbl_in(i+3000).COMMENTS                  := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE_CATEGORY        := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE1                := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE2                := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE3                := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE4                := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE5                := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE6                := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE7                := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE8                := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE9                := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE10               := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE11               := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE12               := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE13               := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE14               := NULL;
           l_rulv_tbl_in(i+3000).ATTRIBUTE15               := NULL;
           l_rulv_tbl_in(i+3000).TEXT                      := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION2         := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION3         := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION4         := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION5         := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION6         := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION7         := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION8         := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION9         := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION10        := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION11        := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION12        := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION13        := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION14        := NULL;
           l_rulv_tbl_in(i+3000).RULE_INFORMATION15        := NULL;

  IF COVERAGE_SUN_START_TIME_tbl(i) IS NOT NULL THEN
    l_igsv_ext_tbl_in(i).id		                       :=okc_p_util.raw_to_number(sys_guid());
	l_igsv_ext_tbl_in(i).start_day_of_week              := 'SUN';
	l_igsv_ext_tbl_in(i).start_hour                     := to_char(COVERAGE_SUN_START_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i).start_minute                   := to_char(COVERAGE_SUN_START_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i).start_second                   := to_char(COVERAGE_SUN_START_TIME_tbl(i),'SS');
	l_igsv_ext_tbl_in(i).end_month                      := Null;
	l_igsv_ext_tbl_in(i).end_day_of_week                := 'SUN';
	l_igsv_ext_tbl_in(i).end_hour                       := to_char(COVERAGE_SUN_END_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i).end_minute                     := to_char(COVERAGE_SUN_END_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i).end_second                     := to_char(COVERAGE_SUN_END_TIME_tbl(i),'SS');
    l_igsv_ext_tbl_in(i).dnz_chr_id                      := l_clev_tbl_in(i).dnz_chr_Id;
    l_igsv_ext_tbl_in(i).tze_id                          := nvl(Time_Zone_Id_Tbl(i),g_timezone_id);
    l_igsv_ext_tbl_in(i).CREATION_DATE                   := g_CREATION_DATE;
    l_igsv_ext_tbl_in(i).CREATED_BY                      := g_CREATED_BY;
    l_igsv_ext_tbl_in(i).LAST_UPDATE_DATE                := g_LAST_UPDATE_DATE;
    l_igsv_ext_tbl_in(i).LAST_UPDATED_BY                 := g_LAST_UPDATED_BY;
    l_igsv_ext_tbl_in(i).LAST_UPDATE_LOGIN               := g_LAST_UPDATE_LOGIN;
    l_igsv_ext_tbl_in(i).Object_version_Number                     :=1;
    l_igsv_ext_tbl_in(i).sfwt_flag                     :='N';
    /*---------------------------------------*/
  l_igsv_ext_tbl_in(i).tve_id_ended                  :=Null;
  l_igsv_ext_tbl_in(i).tve_id_limited                :=Null;
  l_igsv_ext_tbl_in(i).description                   :=Null;
  l_igsv_ext_tbl_in(i).short_description             :=Null;
  l_igsv_ext_tbl_in(i).comments                      :=Null;
  l_igsv_ext_tbl_in(i).attribute_category            :=Null;
  l_igsv_ext_tbl_in(i).attribute1                    :=Null;
  l_igsv_ext_tbl_in(i).attribute2                    :=Null;
  l_igsv_ext_tbl_in(i).attribute3                    :=Null;
  l_igsv_ext_tbl_in(i).attribute4                    :=Null;
  l_igsv_ext_tbl_in(i).attribute5                    :=Null;
  l_igsv_ext_tbl_in(i).attribute6                    :=Null;
  l_igsv_ext_tbl_in(i).attribute7                    :=Null;
  l_igsv_ext_tbl_in(i).attribute8                    :=Null;
  l_igsv_ext_tbl_in(i).attribute9                    :=Null;
  l_igsv_ext_tbl_in(i).attribute10                   :=Null;
  l_igsv_ext_tbl_in(i).attribute11                   :=Null;
  l_igsv_ext_tbl_in(i).attribute12                   :=Null;
  l_igsv_ext_tbl_in(i).attribute13                   :=Null;
  l_igsv_ext_tbl_in(i).attribute14                   :=Null;
  l_igsv_ext_tbl_in(i).attribute15                   :=Null;

    l_ctiv_tbl_In(i).rul_id                 :=l_rulv_tbl_in(i+3000).id;
    l_ctiv_tbl_in(i).tve_id                 :=l_igsv_ext_tbl_in(i).Id;
    l_ctiv_tbl_in(i).dnz_chr_id             :=l_clev_tbl_in(i).dnz_chr_Id;
    l_ctiv_tbl_in(i).CREATION_DATE          := g_CREATION_DATE;
    l_ctiv_tbl_in(i).CREATED_BY             := g_CREATED_BY;
    l_ctiv_tbl_in(i).LAST_UPDATE_DATE       := g_LAST_UPDATE_DATE;
    l_ctiv_tbl_in(i).LAST_UPDATED_BY        := g_LAST_UPDATED_BY;
    l_ctiv_tbl_in(i).LAST_UPDATE_LOGIN      := g_LAST_UPDATE_LOGIN;
    l_ctiv_tbl_in(i).object_version_number        := 1;

End If;


IF COVERAGE_MON_START_TIME_tbl(i) IS NOT NULL THEN
    l_igsv_ext_tbl_in(i+1000).id		                       :=okc_p_util.raw_to_number(sys_guid());
	l_igsv_ext_tbl_in(i+1000).start_day_of_week              := 'MON';
	l_igsv_ext_tbl_in(i+1000).start_hour                     := to_char(COVERAGE_MON_START_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i+1000).start_minute                   := to_char(COVERAGE_MON_START_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i+1000).start_second                   := to_char(COVERAGE_MON_START_TIME_tbl(i),'SS');
	l_igsv_ext_tbl_in(i+1000).end_MONth                      := Null;
	l_igsv_ext_tbl_in(i+1000).end_day_of_week                := 'MON';
	l_igsv_ext_tbl_in(i+1000).end_hour                       := to_char(COVERAGE_MON_END_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i+1000).end_minute                     := to_char(COVERAGE_MON_END_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i+1000).end_second                     := to_char(COVERAGE_MON_END_TIME_tbl(i),'SS');
    l_igsv_ext_tbl_in(i+1000).dnz_chr_id                      := l_clev_tbl_in(i).dnz_chr_Id;
    l_igsv_ext_tbl_in(i+1000).tze_id                          := nvl(Time_Zone_Id_Tbl(i),g_timezone_id);
    l_igsv_ext_tbl_in(i+1000).CREATION_DATE                   := g_CREATION_DATE;
    l_igsv_ext_tbl_in(i+1000).CREATED_BY                      := g_CREATED_BY;
    l_igsv_ext_tbl_in(i+1000).LAST_UPDATE_DATE                := g_LAST_UPDATE_DATE;
    l_igsv_ext_tbl_in(i+1000).LAST_UPDATED_BY                 := g_LAST_UPDATED_BY;
    l_igsv_ext_tbl_in(i+1000).LAST_UPDATE_LOGIN               := g_LAST_UPDATE_LOGIN;
    l_igsv_ext_tbl_in(i+1000).Object_version_Number                     :=1;
    l_igsv_ext_tbl_in(i+1000).sfwt_flag                     :='N';
  l_igsv_ext_tbl_in(i+1000).tve_id_ended                  :=Null;
  l_igsv_ext_tbl_in(i+1000).tve_id_limited                :=Null;
  l_igsv_ext_tbl_in(i+1000).description                   :=Null;
  l_igsv_ext_tbl_in(i+1000).short_description             :=Null;
  l_igsv_ext_tbl_in(i+1000).comments                      :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute_category            :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute1                    :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute2                    :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute3                    :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute4                    :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute5                    :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute6                    :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute7                    :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute8                    :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute9                    :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute10                   :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute11                   :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute12                   :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute13                   :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute14                   :=Null;
  l_igsv_ext_tbl_in(i+1000).attribute15                   :=Null;

    l_ctiv_tbl_In(i+1000).rul_id                 :=l_rulv_tbl_in(i+3000).id;
    l_ctiv_tbl_in(i+1000).tve_id                 :=l_igsv_ext_tbl_in(i+1000).Id;
    l_ctiv_tbl_in(i+1000).dnz_chr_id             :=l_clev_tbl_in(i).dnz_chr_Id;
    l_ctiv_tbl_in(i+1000).CREATION_DATE          := g_CREATION_DATE;
    l_ctiv_tbl_in(i+1000).CREATED_BY             := g_CREATED_BY;
    l_ctiv_tbl_in(i+1000).LAST_UPDATE_DATE       := g_LAST_UPDATE_DATE;
    l_ctiv_tbl_in(i+1000).LAST_UPDATED_BY        := g_LAST_UPDATED_BY;
    l_ctiv_tbl_in(i+1000).LAST_UPDATE_LOGIN      := g_LAST_UPDATE_LOGIN;
    l_ctiv_tbl_in(i+1000).object_version_number        := 1;
End If;

IF COVERAGE_TUE_START_TIME_tbl(i) IS NOT NULL THEN
    l_igsv_ext_tbl_in(i+2000).id		                       :=okc_p_util.raw_to_number(sys_guid());
	l_igsv_ext_tbl_in(i+2000).start_day_of_week              := 'TUE';
	l_igsv_ext_tbl_in(i+2000).start_hour                     := to_char(COVERAGE_TUE_START_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i+2000).start_minute                   := to_char(COVERAGE_TUE_START_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i+2000).start_second                   := to_char(COVERAGE_TUE_START_TIME_tbl(i),'SS');
	l_igsv_ext_tbl_in(i+2000).end_month                      := Null;
	l_igsv_ext_tbl_in(i+2000).end_day_of_week                := 'TUE';
	l_igsv_ext_tbl_in(i+2000).end_hour                       := to_char(COVERAGE_TUE_END_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i+2000).end_minute                     := to_char(COVERAGE_TUE_END_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i+2000).end_second                     := to_char(COVERAGE_TUE_END_TIME_tbl(i),'SS');
    l_igsv_ext_tbl_in(i+2000).dnz_chr_id                      := l_clev_tbl_in(i).dnz_chr_Id;
    l_igsv_ext_tbl_in(i+2000).tze_id                          := nvl(Time_Zone_Id_Tbl(i),g_timezone_id);
    l_igsv_ext_tbl_in(i+2000).CREATION_DATE                   := g_CREATION_DATE;
    l_igsv_ext_tbl_in(i+2000).CREATED_BY                      := g_CREATED_BY;
    l_igsv_ext_tbl_in(i+2000).LAST_UPDATE_DATE                := g_LAST_UPDATE_DATE;
    l_igsv_ext_tbl_in(i+2000).LAST_UPDATED_BY                 := g_LAST_UPDATED_BY;
    l_igsv_ext_tbl_in(i+2000).LAST_UPDATE_LOGIN               := g_LAST_UPDATE_LOGIN;
    l_igsv_ext_tbl_in(i+2000).Object_version_Number                     :=1;
    l_igsv_ext_tbl_in(i+2000).sfwt_flag                     :='N';
  l_igsv_ext_tbl_in(i+2000).tve_id_ended                  :=Null;
  l_igsv_ext_tbl_in(i+2000).tve_id_limited                :=Null;
  l_igsv_ext_tbl_in(i+2000).description                   :=Null;
  l_igsv_ext_tbl_in(i+2000).short_description             :=Null;
  l_igsv_ext_tbl_in(i+2000).comments                      :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute_category            :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute1                    :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute2                    :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute3                    :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute4                    :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute5                    :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute6                    :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute7                    :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute8                    :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute9                    :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute10                   :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute11                   :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute12                   :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute13                   :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute14                   :=Null;
  l_igsv_ext_tbl_in(i+2000).attribute15                   :=Null;

    l_ctiv_tbl_In(i+2000).rul_id                 :=l_rulv_tbl_in(i+3000).id;
    l_ctiv_tbl_in(i+2000).tve_id                 :=l_igsv_ext_tbl_in(i+2000).Id;
    l_ctiv_tbl_in(i+2000).dnz_chr_id             :=l_clev_tbl_in(i).dnz_chr_Id;
    l_ctiv_tbl_in(i+2000).CREATION_DATE          := g_CREATION_DATE;
    l_ctiv_tbl_in(i+2000).CREATED_BY             := g_CREATED_BY;
    l_ctiv_tbl_in(i+2000).LAST_UPDATE_DATE       := g_LAST_UPDATE_DATE;
    l_ctiv_tbl_in(i+2000).LAST_UPDATED_BY        := g_LAST_UPDATED_BY;
    l_ctiv_tbl_in(i+2000).LAST_UPDATE_LOGIN      := g_LAST_UPDATE_LOGIN;
    l_ctiv_tbl_in(i+2000).object_version_number        := 1;
End If;

IF COVERAGE_WED_START_TIME_tbl(i) IS NOT NULL THEN
    l_igsv_ext_tbl_in(i+3000).id		                       :=okc_p_util.raw_to_number(sys_guid());
	l_igsv_ext_tbl_in(i+3000).start_day_of_week              := 'WED';
	l_igsv_ext_tbl_in(i+3000).start_hour                     := to_char(COVERAGE_WED_START_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i+3000).start_minute                   := to_char(COVERAGE_WED_START_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i+3000).start_second                   := to_char(COVERAGE_WED_START_TIME_tbl(i),'SS');
	l_igsv_ext_tbl_in(i+3000).end_month                      := Null;
	l_igsv_ext_tbl_in(i+3000).end_day_of_week                := 'WED';
	l_igsv_ext_tbl_in(i+3000).end_hour                       := to_char(COVERAGE_WED_END_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i+3000).end_minute                     := to_char(COVERAGE_WED_END_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i+3000).end_second                     := to_char(COVERAGE_WED_END_TIME_tbl(i),'SS');
    l_igsv_ext_tbl_in(i+3000).dnz_chr_id                      := l_clev_tbl_in(i).dnz_chr_Id;
    l_igsv_ext_tbl_in(i+3000).tze_id                          := nvl(Time_Zone_Id_Tbl(i),g_timezone_id);
    l_igsv_ext_tbl_in(i+3000).CREATION_DATE                   := g_CREATION_DATE;
    l_igsv_ext_tbl_in(i+3000).CREATED_BY                      := g_CREATED_BY;
    l_igsv_ext_tbl_in(i+3000).LAST_UPDATE_DATE                := g_LAST_UPDATE_DATE;
    l_igsv_ext_tbl_in(i+3000).LAST_UPDATED_BY                 := g_LAST_UPDATED_BY;
    l_igsv_ext_tbl_in(i+3000).LAST_UPDATE_LOGIN               := g_LAST_UPDATE_LOGIN;
    l_igsv_ext_tbl_in(i+3000).Object_version_Number                     :=1;
    l_igsv_ext_tbl_in(i+3000).sfwt_flag                     :='N';
  l_igsv_ext_tbl_in(i+3000).tve_id_ended                  :=Null;
  l_igsv_ext_tbl_in(i+3000).tve_id_limited                :=Null;
  l_igsv_ext_tbl_in(i+3000).description                   :=Null;
  l_igsv_ext_tbl_in(i+3000).short_description             :=Null;
  l_igsv_ext_tbl_in(i+3000).comments                      :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute_category            :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute1                    :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute2                    :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute3                    :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute4                    :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute5                    :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute6                    :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute7                    :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute8                    :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute9                    :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute10                   :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute11                   :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute12                   :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute13                   :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute14                   :=Null;
  l_igsv_ext_tbl_in(i+3000).attribute15                   :=Null;

    l_ctiv_tbl_In(i+3000).rul_id                 :=l_rulv_tbl_in(i+3000).id;
    l_ctiv_tbl_in(i+3000).tve_id                 :=l_igsv_ext_tbl_in(i+3000).Id;
    l_ctiv_tbl_in(i+3000).dnz_chr_id             :=l_clev_tbl_in(i).dnz_chr_Id;
    l_ctiv_tbl_in(i+3000).CREATION_DATE          := g_CREATION_DATE;
    l_ctiv_tbl_in(i+3000).CREATED_BY             := g_CREATED_BY;
    l_ctiv_tbl_in(i+3000).LAST_UPDATE_DATE       := g_LAST_UPDATE_DATE;
    l_ctiv_tbl_in(i+3000).LAST_UPDATED_BY        := g_LAST_UPDATED_BY;
    l_ctiv_tbl_in(i+3000).LAST_UPDATE_LOGIN      := g_LAST_UPDATE_LOGIN;
    l_ctiv_tbl_in(i+3000).object_version_number        := 1;
End If;

IF COVERAGE_THU_START_TIME_tbl(i) IS NOT NULL THEN
---- dbms_output.put_line('Test');
    l_igsv_ext_tbl_in(i+4000).id		                       :=okc_p_util.raw_to_number(sys_guid());
	l_igsv_ext_tbl_in(i+4000).start_day_of_week              := 'THU';
	l_igsv_ext_tbl_in(i+4000).start_hour                     := to_char(COVERAGE_THU_START_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i+4000).start_minute                   := to_char(COVERAGE_THU_START_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i+4000).start_second                   := to_char(COVERAGE_THU_START_TIME_tbl(i),'SS');
	l_igsv_ext_tbl_in(i+4000).end_month                      := Null;
	l_igsv_ext_tbl_in(i+4000).end_day_of_week                := 'THU';
	l_igsv_ext_tbl_in(i+4000).end_hour                       := to_char(COVERAGE_THU_END_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i+4000).end_minute                     := to_char(COVERAGE_THU_END_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i+4000).end_second                     := to_char(COVERAGE_THU_END_TIME_tbl(i),'SS');
    l_igsv_ext_tbl_in(i+4000).dnz_chr_id                      := l_clev_tbl_in(i).dnz_chr_Id;
    l_igsv_ext_tbl_in(i+4000).tze_id                          := nvl(Time_Zone_Id_Tbl(i),g_timezone_id);
    l_igsv_ext_tbl_in(i+4000).CREATION_DATE                   := g_CREATION_DATE;
    l_igsv_ext_tbl_in(i+4000).CREATED_BY                      := g_CREATED_BY;
    l_igsv_ext_tbl_in(i+4000).LAST_UPDATE_DATE                := g_LAST_UPDATE_DATE;
    l_igsv_ext_tbl_in(i+4000).LAST_UPDATED_BY                 := g_LAST_UPDATED_BY;
    l_igsv_ext_tbl_in(i+4000).LAST_UPDATE_LOGIN               := g_LAST_UPDATE_LOGIN;
    l_igsv_ext_tbl_in(i+4000).Object_version_Number                     :=1;
   -- -- dbms_output.put_line('Test1');
    l_igsv_ext_tbl_in(i+4000).sfwt_flag                     :='N';
  l_igsv_ext_tbl_in(i+4000).tve_id_ended                  :=Null;
  l_igsv_ext_tbl_in(i+4000).tve_id_limited                :=Null;
  l_igsv_ext_tbl_in(i+4000).description                   :=Null;
  l_igsv_ext_tbl_in(i+4000).short_description             :=Null;
  l_igsv_ext_tbl_in(i+4000).comments                      :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute_category            :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute1                    :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute2                    :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute3                    :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute4                    :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute5                    :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute6                    :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute7                    :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute8                    :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute9                    :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute10                   :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute11                   :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute12                   :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute13                   :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute14                   :=Null;
  l_igsv_ext_tbl_in(i+4000).attribute15                   :=Null;

    l_ctiv_tbl_In(i+4000).rul_id              :=l_rulv_tbl_in(i+3000).id;
    l_ctiv_tbl_in(i+4000).tve_id                 :=l_igsv_ext_tbl_in(i+4000).Id;
    l_ctiv_tbl_in(i+4000).dnz_chr_id             :=l_clev_tbl_in(i).dnz_chr_Id;
    l_ctiv_tbl_in(i+4000).CREATION_DATE          := g_CREATION_DATE;
    l_ctiv_tbl_in(i+4000).CREATED_BY             := g_CREATED_BY;
    l_ctiv_tbl_in(i+4000).LAST_UPDATE_DATE       := g_LAST_UPDATE_DATE;
    l_ctiv_tbl_in(i+4000).LAST_UPDATED_BY        := g_LAST_UPDATED_BY;
    l_ctiv_tbl_in(i+4000).LAST_UPDATE_LOGIN      := g_LAST_UPDATE_LOGIN;
    l_ctiv_tbl_in(i+4000).object_version_number        := 1;

End If;

IF COVERAGE_FRI_START_TIME_tbl(i) IS NOT NULL THEN
    l_igsv_ext_tbl_in(i+5000).id		                       :=okc_p_util.raw_to_number(sys_guid());
	l_igsv_ext_tbl_in(i+5000).start_day_of_week              := 'FRI';
	l_igsv_ext_tbl_in(i+5000).start_hour                     := to_char(COVERAGE_FRI_START_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i+5000).start_minute                   := to_char(COVERAGE_FRI_START_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i+5000).start_second                   := to_char(COVERAGE_FRI_START_TIME_tbl(i),'SS');
	l_igsv_ext_tbl_in(i+5000).end_month                      := Null;
	l_igsv_ext_tbl_in(i+5000).end_day_of_week                := 'FRI';
	l_igsv_ext_tbl_in(i+5000).end_hour                       := to_char(COVERAGE_FRI_END_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i+5000).end_minute                     := to_char(COVERAGE_FRI_END_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i+5000).end_second                     := to_char(COVERAGE_FRI_END_TIME_tbl(i),'SS');
    l_igsv_ext_tbl_in(i+5000).dnz_chr_id                      := l_clev_tbl_in(i).dnz_chr_Id;
    l_igsv_ext_tbl_in(i+5000).tze_id                          := nvl(Time_Zone_Id_Tbl(i),g_timezone_id);
    l_igsv_ext_tbl_in(i+5000).CREATION_DATE                   := g_CREATION_DATE;
    l_igsv_ext_tbl_in(i+5000).CREATED_BY                      := g_CREATED_BY;
    l_igsv_ext_tbl_in(i+5000).LAST_UPDATE_DATE                := g_LAST_UPDATE_DATE;
    l_igsv_ext_tbl_in(i+5000).LAST_UPDATED_BY                 := g_LAST_UPDATED_BY;
    l_igsv_ext_tbl_in(i+5000).LAST_UPDATE_LOGIN               := g_LAST_UPDATE_LOGIN;
    l_igsv_ext_tbl_in(i+5000).Object_version_Number                     :=1;
    l_igsv_ext_tbl_in(i+5000).sfwt_flag                     :='N';
  l_igsv_ext_tbl_in(i+5000).tve_id_ended                  :=Null;
  l_igsv_ext_tbl_in(i+5000).tve_id_limited                :=Null;
  l_igsv_ext_tbl_in(i+5000).description                   :=Null;
  l_igsv_ext_tbl_in(i+5000).short_description             :=Null;
  l_igsv_ext_tbl_in(i+5000).comments                      :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute_category            :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute1                    :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute2                    :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute3                    :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute4                    :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute5                    :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute6                    :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute7                    :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute8                    :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute9                    :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute10                   :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute11                   :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute12                   :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute13                   :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute14                   :=Null;
  l_igsv_ext_tbl_in(i+5000).attribute15                   :=Null;

    l_ctiv_tbl_In(i+5000).rul_id                 :=l_rulv_tbl_in(i+3000).id;
    l_ctiv_tbl_in(i+5000).tve_id                 :=l_igsv_ext_tbl_in(i+5000).Id;
    l_ctiv_tbl_in(i+5000).dnz_chr_id             :=l_clev_tbl_in(i).dnz_chr_Id;
    l_ctiv_tbl_in(i+5000).CREATION_DATE          := g_CREATION_DATE;
    l_ctiv_tbl_in(i+5000).CREATED_BY             := g_CREATED_BY;
    l_ctiv_tbl_in(i+5000).LAST_UPDATE_DATE       := g_LAST_UPDATE_DATE;
    l_ctiv_tbl_in(i+5000).LAST_UPDATED_BY        := g_LAST_UPDATED_BY;
    l_ctiv_tbl_in(i+5000).LAST_UPDATE_LOGIN      := g_LAST_UPDATE_LOGIN;
    l_ctiv_tbl_in(i+5000).object_version_number        := 1;
End If;
IF COVERAGE_SAT_START_TIME_tbl(i) IS NOT NULL THEN
    l_igsv_ext_tbl_in(i+6000).id		                       :=okc_p_util.raw_to_number(sys_guid());
	l_igsv_ext_tbl_in(i+6000).start_day_of_week              := 'SAT';
	l_igsv_ext_tbl_in(i+6000).start_hour                     := to_char(COVERAGE_SAT_START_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i+6000).start_minute                   := to_char(COVERAGE_SAT_START_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i+6000).start_second                   := to_char(COVERAGE_SAT_START_TIME_tbl(i),'SS');
	l_igsv_ext_tbl_in(i+6000).end_month                      := Null;
	l_igsv_ext_tbl_in(i+6000).end_day_of_week                := 'SAT';
	l_igsv_ext_tbl_in(i+6000).end_hour                       := to_char(COVERAGE_SAT_END_TIME_tbl(i),'HH24');
	l_igsv_ext_tbl_in(i+6000).end_minute                     := to_char(COVERAGE_SAT_END_TIME_tbl(i),'MI');
	l_igsv_ext_tbl_in(i+6000).end_second                     := to_char(COVERAGE_SAT_END_TIME_tbl(i),'SS');
    l_igsv_ext_tbl_in(i+6000).dnz_chr_id                      := l_clev_tbl_in(i).dnz_chr_Id;
    l_igsv_ext_tbl_in(i+6000).tze_id                          := nvl(Time_Zone_Id_Tbl(i),g_timezone_id);
    l_igsv_ext_tbl_in(i+6000).CREATION_DATE                   := g_CREATION_DATE;
    l_igsv_ext_tbl_in(i+6000).CREATED_BY                      := g_CREATED_BY;
    l_igsv_ext_tbl_in(i+6000).LAST_UPDATE_DATE                := g_LAST_UPDATE_DATE;
    l_igsv_ext_tbl_in(i+6000).LAST_UPDATED_BY                 := g_LAST_UPDATED_BY;
    l_igsv_ext_tbl_in(i+6000).LAST_UPDATE_LOGIN               := g_LAST_UPDATE_LOGIN;
    l_igsv_ext_tbl_in(i+6000).Object_version_Number                     :=1;
    l_igsv_ext_tbl_in(i+6000).sfwt_flag                     :='N';
  l_igsv_ext_tbl_in(i+6000).tve_id_ended                  :=Null;
  l_igsv_ext_tbl_in(i+6000).tve_id_limited                :=Null;
  l_igsv_ext_tbl_in(i+6000).description                   :=Null;
  l_igsv_ext_tbl_in(i+6000).short_description             :=Null;
  l_igsv_ext_tbl_in(i+6000).comments                      :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute_category            :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute1                    :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute2                    :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute3                    :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute4                    :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute5                    :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute6                    :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute7                    :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute8                    :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute9                    :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute10                   :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute11                   :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute12                   :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute13                   :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute14                   :=Null;
  l_igsv_ext_tbl_in(i+6000).attribute15                   :=Null;

    l_ctiv_tbl_In(i+6000).rul_id                 :=l_rulv_tbl_in(i+3000).id;
    l_ctiv_tbl_in(i+6000).tve_id                 :=l_igsv_ext_tbl_in(i+6000).Id;
    l_ctiv_tbl_in(i+6000).dnz_chr_id             :=l_clev_tbl_in(i).dnz_chr_Id;
    l_ctiv_tbl_in(i+6000).CREATION_DATE          := g_CREATION_DATE;
    l_ctiv_tbl_in(i+6000).CREATED_BY             := g_CREATED_BY;
    l_ctiv_tbl_in(i+6000).LAST_UPDATE_DATE       := g_LAST_UPDATE_DATE;
    l_ctiv_tbl_in(i+6000).LAST_UPDATED_BY        := g_LAST_UPDATED_BY;
    l_ctiv_tbl_in(i+6000).LAST_UPDATE_LOGIN      := g_LAST_UPDATE_LOGIN;
    l_ctiv_tbl_in(i+6000).object_version_number        := 1;
End If;

/* Temparary Changes Made to pass through QA check.
   l_cplv_tbl_in(i).id		                   :=okc_p_util.raw_to_number(sys_guid());
   l_cplv_tbl_in(i).chr_id                      := NULL;
   l_cplv_tbl_in(i).sfwt_flag	               :='N';
   l_cplv_tbl_in(i).cle_id		                := l_clev_tbl_in(i).Id;
   l_cplv_tbl_in(i).dnz_chr_id	                := l_clev_tbl_in(i).dnz_chr_Id;
   l_cplv_tbl_in(i).rle_code                    := 'VENDOR';
 --  l_cplv_tbl_in(i).object1_id1                 := '204';
   l_cplv_tbl_in(i).object1_id2                 := '#';
   l_cplv_tbl_in(i).jtot_object1_code           := 'OKX_OPERUNIT';
   l_cplv_tbl_in(i).CREATION_DATE               := g_CREATION_DATE;
   l_cplv_tbl_in(i).CREATED_BY                  := g_CREATED_BY;
   l_cplv_tbl_in(i).LAST_UPDATE_DATE            := g_LAST_UPDATE_DATE;
   l_cplv_tbl_in(i).LAST_UPDATED_BY             := g_LAST_UPDATED_BY;
   l_cplv_tbl_in(i).LAST_UPDATE_LOGIN           := g_LAST_UPDATE_LOGIN;
   l_cplv_tbl_in(i).object_version_number        := 1;
  l_cplv_tbl_in(i).cpl_id                        := NULL;
  l_cplv_tbl_in(i).CODE                                     :=null;
  l_cplv_tbl_in(i).FACILITY                                :=null;
  l_cplv_tbl_in(i).MINORITY_GROUP_LOOKUP_CODE              :=null;
  l_cplv_tbl_in(i).SMALL_BUSINESS_FLAG                      :=null;
  l_cplv_tbl_in(i).WOMEN_OWNED_FLAG                       :=null;
  l_cplv_tbl_in(i).LAST_UPDATE_LOGIN                       :=null;
  l_cplv_tbl_in(i).ATTRIBUTE_CATEGORY                       :=null;
  l_cplv_tbl_in(i).ATTRIBUTE1                               :=null;
  l_cplv_tbl_in(i).ATTRIBUTE2                              :=null;
  l_cplv_tbl_in(i).ATTRIBUTE3                              :=null;
  l_cplv_tbl_in(i).ATTRIBUTE4                              :=null;
  l_cplv_tbl_in(i).ATTRIBUTE5                              :=null;
  l_cplv_tbl_in(i).ATTRIBUTE6                              :=null;
  l_cplv_tbl_in(i).ATTRIBUTE7                             :=null;
  l_cplv_tbl_in(i).ATTRIBUTE8                               :=null;
  l_cplv_tbl_in(i).ATTRIBUTE9                             :=null;
  l_cplv_tbl_in(i).ATTRIBUTE10                             :=null;
  l_cplv_tbl_in(i).ATTRIBUTE11                             :=null;
  l_cplv_tbl_in(i).ATTRIBUTE12                              :=null;
  l_cplv_tbl_in(i).ATTRIBUTE13                          :=null;
  l_cplv_tbl_in(i).ATTRIBUTE14                          :=null;
  l_cplv_tbl_in(i).ATTRIBUTE15                             :=null;

 l_ctcv_tbl_in(i).id		                    :=okc_p_util.raw_to_number(sys_guid());
   l_ctcv_tbl_in(i).cpl_id		                := l_cplv_tbl_in(i).id;
   l_ctcv_tbl_in(i).cro_code	                := 'ENGINEER';
   l_ctcv_tbl_in(i).dnz_chr_id	                := l_clev_tbl_in(i).dnz_chr_Id;
   l_ctcv_tbl_in(i).contact_sequence            := 1;
   l_ctcv_tbl_in(i).CREATION_DATE               := g_CREATION_DATE;
   l_ctcv_tbl_in(i).CREATED_BY                  := g_CREATED_BY;
   l_ctcv_tbl_in(i).LAST_UPDATE_DATE            := g_LAST_UPDATE_DATE;
   l_ctcv_tbl_in(i).LAST_UPDATED_BY             := g_LAST_UPDATED_BY;
   l_ctcv_tbl_in(i).LAST_UPDATE_LOGIN           := g_LAST_UPDATE_LOGIN;
   l_ctcv_tbl_in(i).object_version_number        := 1;
   l_ctcv_tbl_in(i).object1_id1	                := Get_PrefEng(PREFERRED_RESOURCE_ID_tbl(i));
   l_ctcv_tbl_in(i).object1_id2	                := '#';
   l_ctcv_tbl_in(i).jtot_object1_code           := 'OKX_RESOURCE';
   l_ctcv_tbl_in(i).LAST_UPDATE_LOGIN                         :=null;
   l_ctcv_tbl_in(i).ATTRIBUTE_CATEGORY                        :=null;
   l_ctcv_tbl_in(i).ATTRIBUTE1                                :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE2                                :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE3                                :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE4                               :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE5                               :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE6                               :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE7                                :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE8                               :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE9                               :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE10                              :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE11                              :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE12                              :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE13                              :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE14                              :=null;
 l_ctcv_tbl_in(i).ATTRIBUTE15                              :=null;

*/
IF REACTION_TIME_ID_TBL(i) IS NOT NULL THEN
             --   -- dbms_output.put_line('Test1');
    l_clev_tbl_in(i+1000).id                     := okc_p_util.raw_to_number(sys_guid());
    l_clev_tbl_in(i+1000).CREATION_DATE          := g_CREATION_DATE;
    l_clev_tbl_in(i+1000).CREATED_BY             	   := g_CREATED_BY;
    l_clev_tbl_in(i+1000).LAST_UPDATE_DATE     := g_LAST_UPDATE_DATE;
    l_clev_tbl_in(i+1000).LAST_UPDATED_BY        := g_LAST_UPDATED_BY;
    l_clev_tbl_in(i+1000).LAST_UPDATE_LOGIN    := g_LAST_UPDATE_LOGIN;
    l_clev_tbl_in(i+1000).object_version_number      := 1;
    l_clev_tbl_in(i+1000).cle_id                 	:=  l_clev_tbl_in(i).Id;
    l_clev_tbl_in(i+1000).dnz_chr_id             	:= l_clev_tbl_in(i).dnz_chr_Id;
    l_clev_tbl_in(i+1000).sfwt_flag	                :='N';
    l_clev_tbl_in(i+1000).lse_id	                    :=4;
    l_clev_tbl_in(i+1000).line_number	            :=1;
                 --   -- dbms_output.put_line('Test2');
--    l_clev_tbl_in(i+1000).sts_code	               :='ENTERED'; --Get_New_Status(Contract_Line_Status_Id_Tbl(i));
	l_clev_tbl_in(i+1000).sts_code	            :=sts_code_tbl(i);
	l_clev_tbl_in(i+1000).display_sequence	     :=1;
	l_clev_tbl_in(i+1000).item_description	     :=reaction_Description_Tbl(i);
	l_clev_tbl_in(i+1000).Name		            :=reaction_name_Tbl(i);
	l_clev_tbl_in(i+1000).exception_yn	         :='N';  --	clarify
	l_clev_tbl_in(i+1000).Currency_Code	         :=Currency_Code_Tbl(i);
    l_clev_tbl_in(i+1000).start_date :=start_date_tbl(i);
    l_clev_tbl_in(i+1000).end_date   :=end_date_tbl(i);
                --    -- dbms_output.put_line('Test3');
  	l_clev_tbl_in(i+1000).attribute1	            :=Attribute1_Tbl(i);
	l_clev_tbl_in(i+1000).attribute2	            :=Attribute2_Tbl(i);
	l_clev_tbl_in(i+1000).attribute3	           :=Attribute3_Tbl(i);
	l_clev_tbl_in(i+1000).attribute4	           :=Attribute4_Tbl(i);
	l_clev_tbl_in(i+1000).attribute5	           :=Attribute5_Tbl(i);
	l_clev_tbl_in(i+1000).attribute6	           :=Attribute6_Tbl(i);
	l_clev_tbl_in(i+1000).attribute7	           :=Attribute7_Tbl(i);
	l_clev_tbl_in(i+1000).attribute8	           :=Attribute8_Tbl(i);
	l_clev_tbl_in(i+1000).attribute9	           :=Attribute9_Tbl(i);
	l_clev_tbl_in(i+1000).attribute10	           :=Attribute10_Tbl(i);
	l_clev_tbl_in(i+1000).attribute11	       	:=Attribute11_Tbl(i);
	l_clev_tbl_in(i+1000).attribute12	       :=Attribute12_Tbl(i);
	l_clev_tbl_in(i+1000).attribute13	       :=Attribute13_Tbl(i);
	l_clev_tbl_in(i+1000).attribute14	       :=Attribute14_Tbl(i);
	l_clev_tbl_in(i+1000).attribute15	       :=Attribute15_Tbl(i);
                 --   -- dbms_output.put_line('Test4');
	l_clev_tbl_in(i+1000).attribute_Category	   :=attribute_Category_Tbl(i);
    l_clev_tbl_in(i+1000).Upg_Orig_System_Ref    :='oks_cov_txn_groups_int_all REACTION_TIMES';
    l_clev_tbl_in(i+1000).Upg_Orig_System_Ref_Id :=Reaction_Time_ID_Tbl(i);
   l_clev_tbl_in(i+1000).INVOICE_LINE_LEVEL_IND                  :=Null;
    l_clev_tbl_in(i+1000).DPAS_RATING                             :=Null;
    l_clev_tbl_in(i+1000).TEMPLATE_USED                            :=Null;
    l_clev_tbl_in(i+1000).PRICE_TYPE                             :=Null;
--    l_clev_tbl_in(i+1000).UOM_CODE                                :=Null;
    l_clev_tbl_in(i+1000).CHR_ID                                   :=Null;
    l_clev_tbl_in(i+1000).TRN_CODE                                 :=Null;
    l_clev_tbl_in(i+1000).HIDDEN_IND                               :=Null;
    l_clev_tbl_in(i+1000).DATE_TERMINATED                        :=Null;
    l_clev_tbl_in(i+1000).CLE_ID_RENEWED_TO                        :=Null;
    l_clev_tbl_in(i+1000).CURRENCY_CODE_RENEWED                    :=Null;
    l_clev_tbl_in(i+1000).PRICE_NEGOTIATED_RENEWED                 :=Null;
    l_clev_tbl_in(i+1000).cle_id_renewed           :=NULL;
    l_clev_tbl_in(i+1000).comments                 :=NULL;
    l_clev_tbl_in(i+1000).price_unit               :=NULL;
    l_clev_tbl_in(i+1000).price_unit_percent       :=NULL;
    l_clev_tbl_in(i+1000).price_negotiated         :=NULL;
    l_clev_tbl_in(i+1000).price_level_ind          :='N';
    l_clev_tbl_in(i+1000).block23text              :=NULL;
        l_clev_tbl_in(i+1000).program_application_id:= fnd_global.prog_appl_id;
        l_clev_tbl_in(i+1000).program_id:= fnd_global.CONC_PROGRAM_ID;
             --   -- dbms_output.put_line('Test5');


     l_rgpv_tbl_in(i+1000).cle_id		             :=     l_clev_tbl_in(i+1000).id;
     l_rgpv_tbl_in(i+1000).sfwt_flag	                 := 'N';
     l_rgpv_tbl_in(i+1000).rgd_code	                 := 'SVC_K';
     l_rgpv_tbl_in(i+1000).rgp_type	                 := 'KRG';
     l_rgpv_tbl_in(i+1000).dnz_chr_id                :=  l_clev_tbl_in(i+1000).dnz_chr_Id;
     l_rgpv_tbl_in(i+1000).id                        :=  okc_p_util.raw_to_number(sys_guid());
     l_rgpv_tbl_in(i+1000).CREATION_DATE             := g_CREATION_DATE;
     l_rgpv_tbl_in(i+1000).CREATED_BY                := g_CREATED_BY;
     l_rgpv_tbl_in(i+1000).LAST_UPDATE_DATE          := g_LAST_UPDATE_DATE;
     l_rgpv_tbl_in(i+1000).LAST_UPDATED_BY           := g_LAST_UPDATED_BY;
     l_rgpv_tbl_in(i+1000).LAST_UPDATE_LOGIN         := g_LAST_UPDATE_LOGIN;
     l_rgpv_tbl_in(i+1000).object_version_number        := 1;
     l_rgpv_tbl_in(i+1000).CHR_ID                                   :=Null;
     l_rgpv_tbl_in(i+1000).PARENT_RGP_ID                            :=Null;
	l_rgpv_tbl_in(i+1000).SAT_CODE                                 :=Null;
	l_rgpv_tbl_in(i+1000).COMMENTS                                 :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE_CATEGORY                       :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE1                               :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE2                               :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE3                               :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE4                               :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE5                               :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE6                               :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE7                               :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE8                               :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE9                               :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE10                              :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE11                              :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE12                              :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE13                              :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE14                              :=Null;
	l_rgpv_tbl_in(i+1000).ATTRIBUTE15                              :=Null;


END IF  ;------REACTION_TIME_ID_TBL(i)

IF Incident_severity_id_Tbl(i) IS Not NULL then


 l_rulv_tbl_in(i+4000).rgp_id	       	    := l_rgpv_tbl_in(i+1000).id;
   l_rulv_tbl_in(i+4000).sfwt_flag                 := 'N';
   l_rulv_tbl_in(i+4000).rule_information_category := 'RCN';
   l_rulv_tbl_in(i+4000).id        := okc_p_util.raw_to_number(sys_guid());
   l_rulv_tbl_in(i+4000).CREATION_DATE := g_CREATION_DATE;
   l_rulv_tbl_in(i+4000).CREATED_BY := g_CREATED_BY;
   l_rulv_tbl_in(i+4000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
   l_rulv_tbl_in(i+4000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
   l_rulv_tbl_in(i+4000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
   l_rulv_tbl_in(i+4000).object_version_number        := 1;
   l_rulv_tbl_in(i+4000).std_template_yn   := 'N';
   l_rulv_tbl_in(i+4000).warn_yn           := 'N';
   l_rulv_tbl_in(i+4000).dnz_chr_id        := l_clev_tbl_in(i).dnz_chr_Id;
   l_rulv_tbl_in(i+4000).rule_information1         := NULL; --WORKFLOW_Tbl(i); --- PDF
   l_rulv_tbl_in(i+4000).rule_information2         := reaction_name_Tbl(i);
   l_rulv_tbl_in(i+4000).rule_information3         := 'N'; --ALWAYS_COVERED_Tbl(i); --'N';--always_covered;
   l_rulv_tbl_in(i+4000).rule_information4         := 'N'; --Use_For_SR_Date_Calc;
   l_rulv_tbl_in(i+4000).object1_id1               :=Incident_severity_id_Tbl(i);
   l_rulv_tbl_in(i+4000).object1_id2               := '#';
   l_rulv_tbl_in(i+4000).jtot_object1_code         := 'OKX_REACTIME';
l_rulv_tbl_in(i+4000).PRIORITY                  := NULL;
           l_rulv_tbl_in(i+4000).OBJECT2_ID1               := NULL;
           l_rulv_tbl_in(i+4000).OBJECT3_ID1               := NULL;
           l_rulv_tbl_in(i+4000).OBJECT2_ID2               := NULL;
           l_rulv_tbl_in(i+4000).OBJECT3_ID2               := NULL;
           l_rulv_tbl_in(i+4000).JTOT_OBJECT2_CODE         := NULL;
           l_rulv_tbl_in(i+4000).JTOT_OBJECT3_CODE         := NULL;
           l_rulv_tbl_in(i+4000).PRIORITY                  := NULL;
           l_rulv_tbl_in(i+4000).COMMENTS                  := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE_CATEGORY        := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE1                := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE2                := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE3                := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE4                := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE5                := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE6                := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE7                := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE8                := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE9                := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE10               := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE11               := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE12               := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE13               := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE14               := NULL;
           l_rulv_tbl_in(i+4000).ATTRIBUTE15               := NULL;
           l_rulv_tbl_in(i+4000).TEXT                      := NULL;
           l_rulv_tbl_in(i+4000).RULE_INFORMATION5         := NULL;
           l_rulv_tbl_in(i+4000).RULE_INFORMATION6         := NULL;
           l_rulv_tbl_in(i+4000).RULE_INFORMATION7         := NULL;
           l_rulv_tbl_in(i+4000).RULE_INFORMATION8         := NULL;
           l_rulv_tbl_in(i+4000).RULE_INFORMATION9         := NULL;
           l_rulv_tbl_in(i+4000).RULE_INFORMATION10        := NULL;
           l_rulv_tbl_in(i+4000).RULE_INFORMATION11        := NULL;
           l_rulv_tbl_in(i+4000).RULE_INFORMATION12        := NULL;
           l_rulv_tbl_in(i+4000).RULE_INFORMATION13        := NULL;
           l_rulv_tbl_in(i+4000).RULE_INFORMATION14        := NULL;
           l_rulv_tbl_in(i+4000).RULE_INFORMATION15        := NULL;

  l_rulv_tbl_in(i+5000).rgp_id	       	    := l_rgpv_tbl_in(i+1000).id;
   l_rulv_tbl_in(i+5000).sfwt_flag                 := 'N';
   l_rulv_tbl_in(i+5000).rule_information_category := 'RSN';
   l_rulv_tbl_in(i+5000).id        := okc_p_util.raw_to_number(sys_guid());
   l_rulv_tbl_in(i+5000).CREATION_DATE := g_CREATION_DATE;
   l_rulv_tbl_in(i+5000).CREATED_BY := g_CREATED_BY;
   l_rulv_tbl_in(i+5000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
   l_rulv_tbl_in(i+5000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
   l_rulv_tbl_in(i+5000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
   l_rulv_tbl_in(i+5000).object_version_number        := 1;
   l_rulv_tbl_in(i+5000).std_template_yn   := 'N';
   l_rulv_tbl_in(i+5000).warn_yn           := 'N';
   l_rulv_tbl_in(i+5000).dnz_chr_id        := l_clev_tbl_in(i).dnz_chr_Id;
   l_rulv_tbl_in(i+5000).rule_information1         := NULL; --WORKFLOW_Tbl(i); --- PDF
   l_rulv_tbl_in(i+5000).rule_information2         := reaction_name_Tbl(i);
   l_rulv_tbl_in(i+5000).rule_information3         := 'N'; --ALWAYS_COVERED_Tbl(i); --'N';--always_covered;
   l_rulv_tbl_in(i+5000).rule_information4         := 'N'; --Use_For_SR_Date_Calc;
   l_rulv_tbl_in(i+5000).object1_id1               :=Incident_severity_id_Tbl(i);
   l_rulv_tbl_in(i+5000).object1_id2               := '#';
   l_rulv_tbl_in(i+5000).jtot_object1_code         := 'OKX_REACTIME';
l_rulv_tbl_in(i+5000).PRIORITY                  := NULL;
           l_rulv_tbl_in(i+5000).OBJECT2_ID1               := NULL;
           l_rulv_tbl_in(i+5000).OBJECT3_ID1               := NULL;
           l_rulv_tbl_in(i+5000).OBJECT2_ID2               := NULL;
           l_rulv_tbl_in(i+5000).OBJECT3_ID2               := NULL;
           l_rulv_tbl_in(i+5000).JTOT_OBJECT2_CODE         := NULL;
           l_rulv_tbl_in(i+5000).JTOT_OBJECT3_CODE         := NULL;
           l_rulv_tbl_in(i+5000).PRIORITY                  := NULL;
           l_rulv_tbl_in(i+5000).COMMENTS                  := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE_CATEGORY        := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE1                := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE2                := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE3                := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE4                := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE5                := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE6                := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE7                := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE8                := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE9                := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE10               := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE11               := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE12               := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE13               := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE14               := NULL;
           l_rulv_tbl_in(i+5000).ATTRIBUTE15               := NULL;
           l_rulv_tbl_in(i+5000).TEXT                      := NULL;
           l_rulv_tbl_in(i+5000).RULE_INFORMATION5         := NULL;
           l_rulv_tbl_in(i+5000).RULE_INFORMATION6         := NULL;
           l_rulv_tbl_in(i+5000).RULE_INFORMATION7         := NULL;
           l_rulv_tbl_in(i+5000).RULE_INFORMATION8         := NULL;
           l_rulv_tbl_in(i+5000).RULE_INFORMATION9         := NULL;
           l_rulv_tbl_in(i+5000).RULE_INFORMATION10        := NULL;
           l_rulv_tbl_in(i+5000).RULE_INFORMATION11        := NULL;
           l_rulv_tbl_in(i+5000).RULE_INFORMATION12        := NULL;
           l_rulv_tbl_in(i+5000).RULE_INFORMATION13        := NULL;
           l_rulv_tbl_in(i+5000).RULE_INFORMATION14        := NULL;
           l_rulv_tbl_in(i+5000).RULE_INFORMATION15        := NULL;
END IF;  -------Incident_severity_id_Tbl(i)

IF SUN_REACTION_TIMES_tbl(i) IS NOT NULL
THEN
  l_tgdv_ext_tbl_in(i).id		:=okc_p_util.raw_to_number(sys_guid());
    l_tgdv_ext_tbl_in(i).day_of_week  := 'SUN';
    l_tgdv_ext_tbl_in(i).dnz_chr_id  :=l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_ext_tbl_in(i).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_ext_tbl_in(i).CREATED_BY := g_CREATED_BY;
    l_tgdv_ext_tbl_in(i).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_ext_tbl_in(i).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_ext_tbl_in(i).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_ext_tbl_in(i).Object_Version_Number        := 1;
l_tgdv_ext_tbl_in(i).SFWT_FLAG                       := 'N' ;
 l_tgdv_ext_tbl_in(i).TZE_ID                                   := NULL ;
 l_tgdv_ext_tbl_in(i).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_ext_tbl_in(i).DESCRIPTION                              := NULL ;
 l_tgdv_ext_tbl_in(i).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_ext_tbl_in(i).COMMENTS                                 := NULL ;
l_tgdv_ext_tbl_in(i).MONTH                                   := NULL ;
 l_tgdv_ext_tbl_in(i).DAY                                      := NULL ;
 l_tgdv_ext_tbl_in(i).HOUR                                    := NULL ;
 l_tgdv_ext_tbl_in(i).MINUTE                                   := NULL ;
 l_tgdv_ext_tbl_in(i).SECOND                                  := NULL ;
 l_tgdv_ext_tbl_in(i).NTH                                     := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE1                               := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE2                               := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE3                               := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE4                             := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE5                              := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE6                               := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE7                               := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE8                               := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE9                              := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE10                              := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE11                             := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE12                              := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE13                             := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE14                              := NULL ;
 l_tgdv_ext_tbl_in(i).ATTRIBUTE15                             := NULL ;


    l_rilv_tbl_in(i).tve_id 			:=l_tgdv_ext_tbl_in(i).id;
    l_rilv_tbl_in(i).rul_id			:=l_rulv_tbl_in(i+ 4000).id;
    l_rilv_tbl_in(i).uom_code	:='HR';
    l_rilv_tbl_in(i).duration			:=SUN_REACTION_TIMES_tbl(i);
    l_rilv_tbl_in(i).object_version_number :=1;
    l_rilv_tbl_in(i).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilv_tbl_in(i).CREATION_DATE := g_CREATION_DATE;
    l_rilv_tbl_in(i).CREATED_BY := g_CREATED_BY;
    l_rilv_tbl_in(i).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilv_tbl_in(i).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilv_tbl_in(i).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilv_tbl_in(i).object_version_number        := 1;

END IF; ---SUN_REACTION_TIMES_tbl

IF MON_REACTION_TIMES_tbl(i) IS NOT NULL
THEN
  l_tgdv_ext_tbl_in(i+1000).id		:=okc_p_util.raw_to_number(sys_guid());
    l_tgdv_ext_tbl_in(i+1000).day_of_week  := 'MON';
    l_tgdv_ext_tbl_in(i+1000).dnz_chr_id  :=l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_ext_tbl_in(i+1000).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_ext_tbl_in(i+1000).CREATED_BY := g_CREATED_BY;
    l_tgdv_ext_tbl_in(i+1000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_ext_tbl_in(i+1000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_ext_tbl_in(i+1000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_ext_tbl_in(i+1000).Object_Version_Number        := 1;
l_tgdv_ext_tbl_in(i+1000).SFWT_FLAG                       := 'N' ;
 l_tgdv_ext_tbl_in(i+1000).TZE_ID                                   := NULL ;
 l_tgdv_ext_tbl_in(i+1000).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_ext_tbl_in(i+1000).DESCRIPTION                              := NULL ;
 l_tgdv_ext_tbl_in(i+1000).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_ext_tbl_in(i+1000).COMMENTS                                 := NULL ;
l_tgdv_ext_tbl_in(i+1000).MONTH                                   := NULL ;
 l_tgdv_ext_tbl_in(i+1000).DAY                                      := NULL ;
 l_tgdv_ext_tbl_in(i+1000).HOUR                                    := NULL ;
 l_tgdv_ext_tbl_in(i+1000).MINUTE                                   := NULL ;
 l_tgdv_ext_tbl_in(i+1000).SECOND                                  := NULL ;
 l_tgdv_ext_tbl_in(i+1000).NTH                                     := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE1                               := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE2                               := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE3                               := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE4                             := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE5                              := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE6                               := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE7                               := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE8                               := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE9                              := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE10                              := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE11                             := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE12                              := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE13                             := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE14                              := NULL ;
 l_tgdv_ext_tbl_in(i+1000).ATTRIBUTE15                             := NULL ;


    l_rilv_tbl_in(i+1000).tve_id 			:=l_tgdv_ext_tbl_in(i+1000).id;
    l_rilv_tbl_in(i+1000).rul_id			:=l_rulv_tbl_in(i+4000).id;
    l_rilv_tbl_in(i+1000).uom_code	:='HR';
    l_rilv_tbl_in(i+1000).duration			:=MON_REACTION_TIMES_tbl(i);
    l_rilv_tbl_in(i+1000).object_version_number :=1;
    l_rilv_tbl_in(i+1000).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilv_tbl_in(i+1000).CREATION_DATE := g_CREATION_DATE;
    l_rilv_tbl_in(i+1000).CREATED_BY := g_CREATED_BY;
    l_rilv_tbl_in(i+1000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilv_tbl_in(i+1000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilv_tbl_in(i+1000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilv_tbl_in(i+1000).object_version_number        := 1;
END IF; ---MON_REACTION_TIMES_tbl


IF TUE_REACTION_TIMES_tbl(i) IS NOT NULL
THEN
    l_tgdv_ext_tbl_in(i+2000).day_of_week  := 'TUE';
    l_tgdv_ext_tbl_in(i+2000).dnz_chr_id  := l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_ext_tbl_in(i+2000).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_ext_tbl_in(i+2000).CREATED_BY := g_CREATED_BY;
    l_tgdv_ext_tbl_in(i+2000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_ext_tbl_in(i+2000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_ext_tbl_in(i+2000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_ext_tbl_in(i+2000).object_version_number        := 1;
l_tgdv_ext_tbl_in(i+2000).SFWT_FLAG                       := 'N' ;
 l_tgdv_ext_tbl_in(i+2000).TZE_ID                                   := NULL ;
 l_tgdv_ext_tbl_in(i+2000).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_ext_tbl_in(i+2000).DESCRIPTION                              := NULL ;
 l_tgdv_ext_tbl_in(i+2000).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_ext_tbl_in(i+2000).COMMENTS                                 := NULL ;
l_tgdv_ext_tbl_in(i+2000).MONTH                                   := NULL ;
 l_tgdv_ext_tbl_in(i+2000).DAY                                      := NULL ;
 l_tgdv_ext_tbl_in(i+2000).HOUR                                    := NULL ;
 l_tgdv_ext_tbl_in(i+2000).MINUTE                                   := NULL ;
 l_tgdv_ext_tbl_in(i+2000).SECOND                                  := NULL ;
 l_tgdv_ext_tbl_in(i+2000).NTH                                     := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE1                               := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE2                               := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE3                               := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE4                             := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE5                              := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE6                               := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE7                               := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE8                               := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE9                              := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE10                              := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE11                             := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE12                              := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE13                             := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE14                              := NULL ;
 l_tgdv_ext_tbl_in(i+2000).ATTRIBUTE15                             := NULL ;

    l_rilv_tbl_in(i+2000).tve_id 			:=l_tgdv_ext_tbl_in(i+2000).id;
    l_rilv_tbl_in(i+2000).rul_id			:=l_rulv_tbl_in(i+4000).id;
    l_rilv_tbl_in(i+2000).uom_code	:='HR';
    l_rilv_tbl_in(i+2000).duration			:=TUE_REACTION_TIMES_tbl(i);
    l_rilv_tbl_in(i+2000).object_version_number :=1;
    l_rilv_tbl_in(i+2000).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilv_tbl_in(i+2000).CREATION_DATE := g_CREATION_DATE;
    l_rilv_tbl_in(i+2000).CREATED_BY := g_CREATED_BY;
    l_rilv_tbl_in(i+2000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilv_tbl_in(i+2000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilv_tbl_in(i+2000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilv_tbl_in(i+2000).object_version_number        := 1;
END IF; ---TUE_REACTION_TIMES_tbl
IF WED_REACTION_TIMES_tbl(i) IS NOT NULL
THEN
  l_tgdv_ext_tbl_in(i+3000).id		:=okc_p_util.raw_to_number(sys_guid());
    l_tgdv_ext_tbl_in(i+3000).day_of_week  := 'WED';
    l_tgdv_ext_tbl_in(i+3000).dnz_chr_id  :=l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_ext_tbl_in(i+3000).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_ext_tbl_in(i+3000).CREATED_BY := g_CREATED_BY;
    l_tgdv_ext_tbl_in(i+3000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_ext_tbl_in(i+3000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_ext_tbl_in(i+3000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_ext_tbl_in(i+3000).Object_Version_Number        := 1;
l_tgdv_ext_tbl_in(i+3000).SFWT_FLAG                       := 'N' ;
 l_tgdv_ext_tbl_in(i+3000).TZE_ID                                   := NULL ;
 l_tgdv_ext_tbl_in(i+3000).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_ext_tbl_in(i+3000).DESCRIPTION                              := NULL ;
 l_tgdv_ext_tbl_in(i+3000).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_ext_tbl_in(i+3000).COMMENTS                                 := NULL ;
l_tgdv_ext_tbl_in(i+3000).MONTH                                   := NULL ;
 l_tgdv_ext_tbl_in(i+3000).DAY                                      := NULL ;
 l_tgdv_ext_tbl_in(i+3000).HOUR                                    := NULL ;
 l_tgdv_ext_tbl_in(i+3000).MINUTE                                   := NULL ;
 l_tgdv_ext_tbl_in(i+3000).SECOND                                  := NULL ;
 l_tgdv_ext_tbl_in(i+3000).NTH                                     := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE1                               := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE2                               := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE3                               := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE4                             := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE5                              := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE6                               := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE7                               := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE8                               := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE9                              := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE10                              := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE11                             := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE12                              := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE13                             := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE14                              := NULL ;
 l_tgdv_ext_tbl_in(i+3000).ATTRIBUTE15                             := NULL ;


    l_rilv_tbl_in(i+3000).tve_id 			:=l_tgdv_ext_tbl_in(i+3000).id;
    l_rilv_tbl_in(i+3000).rul_id			:=l_rulv_tbl_in(i+4000).id;
    l_rilv_tbl_in(i+3000).uom_code	:='HR';
    l_rilv_tbl_in(i+3000).duration			:=WED_REACTION_TIMES_tbl(i);
    l_rilv_tbl_in(i+3000).object_version_number :=1;
    l_rilv_tbl_in(i+3000).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilv_tbl_in(i+3000).CREATION_DATE := g_CREATION_DATE;
    l_rilv_tbl_in(i+3000).CREATED_BY := g_CREATED_BY;
    l_rilv_tbl_in(i+3000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilv_tbl_in(i+3000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilv_tbl_in(i+3000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilv_tbl_in(i+3000).object_version_number        := 1;
END IF; ---WED_REACTION_TIMES_tbl

IF THU_REACTION_TIMES_tbl(i) IS NOT NULL
THEN
  l_tgdv_ext_tbl_in(i+4000).id		:=okc_p_util.raw_to_number(sys_guid());
    l_tgdv_ext_tbl_in(i+4000).day_of_week  := 'THU';
    l_tgdv_ext_tbl_in(i+4000).dnz_chr_id  :=l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_ext_tbl_in(i+4000).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_ext_tbl_in(i+4000).CREATED_BY := g_CREATED_BY;
    l_tgdv_ext_tbl_in(i+4000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_ext_tbl_in(i+4000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_ext_tbl_in(i+4000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_ext_tbl_in(i+4000).Object_Version_Number        := 1;
l_tgdv_ext_tbl_in(i+4000).SFWT_FLAG                       := 'N' ;
 l_tgdv_ext_tbl_in(i+4000).TZE_ID                                   := NULL ;
 l_tgdv_ext_tbl_in(i+4000).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_ext_tbl_in(i+4000).DESCRIPTION                              := NULL ;
 l_tgdv_ext_tbl_in(i+4000).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_ext_tbl_in(i+4000).COMMENTS                                 := NULL ;
l_tgdv_ext_tbl_in(i+4000).MONTH                                   := NULL ;
 l_tgdv_ext_tbl_in(i+4000).DAY                                      := NULL ;
 l_tgdv_ext_tbl_in(i+4000).HOUR                                    := NULL ;
 l_tgdv_ext_tbl_in(i+4000).MINUTE                                   := NULL ;
 l_tgdv_ext_tbl_in(i+4000).SECOND                                  := NULL ;
 l_tgdv_ext_tbl_in(i+4000).NTH                                     := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE1                               := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE2                               := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE3                               := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE4                             := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE5                              := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE6                               := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE7                               := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE8                               := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE9                              := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE10                              := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE11                             := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE12                              := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE13                             := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE14                              := NULL ;
 l_tgdv_ext_tbl_in(i+4000).ATTRIBUTE15                             := NULL ;


    l_rilv_tbl_in(i+4000).tve_id 			:=l_tgdv_ext_tbl_in(i+4000).id;
    l_rilv_tbl_in(i+4000).rul_id			:=l_rulv_tbl_in(i+4000).id;
    l_rilv_tbl_in(i+4000).uom_code	:='HR';
    l_rilv_tbl_in(i+4000).duration			:=THU_REACTION_TIMES_tbl(i);
    l_rilv_tbl_in(i+4000).object_version_number :=1;
    l_rilv_tbl_in(i+4000).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilv_tbl_in(i+4000).CREATION_DATE := g_CREATION_DATE;
    l_rilv_tbl_in(i+4000).CREATED_BY := g_CREATED_BY;
    l_rilv_tbl_in(i+4000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilv_tbl_in(i+4000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilv_tbl_in(i+4000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilv_tbl_in(i+4000).object_version_number        := 1;
END IF; ---THU_REACTION_TIMES_tbl

IF FRI_REACTION_TIMES_tbl(i) IS NOT NULL
THEN
  l_tgdv_ext_tbl_in(i+5000).id		:=okc_p_util.raw_to_number(sys_guid());
    l_tgdv_ext_tbl_in(i+5000).day_of_week  := 'FRI';
    l_tgdv_ext_tbl_in(i+5000).dnz_chr_id  :=l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_ext_tbl_in(i+5000).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_ext_tbl_in(i+5000).CREATED_BY := g_CREATED_BY;
    l_tgdv_ext_tbl_in(i+5000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_ext_tbl_in(i+5000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_ext_tbl_in(i+5000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_ext_tbl_in(i+5000).Object_Version_Number        := 1;
l_tgdv_ext_tbl_in(i+5000).SFWT_FLAG                       := 'N' ;
 l_tgdv_ext_tbl_in(i+5000).TZE_ID                                   := NULL ;
 l_tgdv_ext_tbl_in(i+5000).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_ext_tbl_in(i+5000).DESCRIPTION                              := NULL ;
 l_tgdv_ext_tbl_in(i+5000).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_ext_tbl_in(i+5000).COMMENTS                                 := NULL ;
l_tgdv_ext_tbl_in(i+5000).MONTH                                   := NULL ;
 l_tgdv_ext_tbl_in(i+5000).DAY                                      := NULL ;
 l_tgdv_ext_tbl_in(i+5000).HOUR                                    := NULL ;
 l_tgdv_ext_tbl_in(i+5000).MINUTE                                   := NULL ;
 l_tgdv_ext_tbl_in(i+5000).SECOND                                  := NULL ;
 l_tgdv_ext_tbl_in(i+5000).NTH                                     := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE1                               := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE2                               := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE3                               := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE4                             := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE5                              := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE6                               := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE7                               := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE8                               := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE9                              := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE10                              := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE11                             := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE12                              := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE13                             := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE14                              := NULL ;
 l_tgdv_ext_tbl_in(i+5000).ATTRIBUTE15                             := NULL ;


    l_rilv_tbl_in(i+5000).tve_id 			:=l_tgdv_ext_tbl_in(i+5000).id;
    l_rilv_tbl_in(i+5000).rul_id			:=l_rulv_tbl_in(i+4000).id;
    l_rilv_tbl_in(i+5000).uom_code	:='HR';
    l_rilv_tbl_in(i+5000).duration			:=FRI_REACTION_TIMES_tbl(i);
    l_rilv_tbl_in(i+5000).object_version_number :=1;
    l_rilv_tbl_in(i+5000).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilv_tbl_in(i+5000).CREATION_DATE := g_CREATION_DATE;
    l_rilv_tbl_in(i+5000).CREATED_BY := g_CREATED_BY;
    l_rilv_tbl_in(i+5000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilv_tbl_in(i+5000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilv_tbl_in(i+5000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilv_tbl_in(i+5000).object_version_number        := 1;
END IF; ---FRI_REACTION_TIMES_tbl

IF SAT_REACTION_TIMES_tbl(i) IS NOT NULL
THEN
  l_tgdv_ext_tbl_in(i+6000).id		:=okc_p_util.raw_to_number(sys_guid());
    l_tgdv_ext_tbl_in(i+6000).day_of_week  := 'SAT';
    l_tgdv_ext_tbl_in(i+6000).dnz_chr_id  :=l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_ext_tbl_in(i+6000).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_ext_tbl_in(i+6000).CREATED_BY := g_CREATED_BY;
    l_tgdv_ext_tbl_in(i+6000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_ext_tbl_in(i+6000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_ext_tbl_in(i+6000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_ext_tbl_in(i+6000).Object_Version_Number        := 1;
l_tgdv_ext_tbl_in(i+6000).SFWT_FLAG                       := 'N' ;
 l_tgdv_ext_tbl_in(i+6000).TZE_ID                                   := NULL ;
 l_tgdv_ext_tbl_in(i+6000).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_ext_tbl_in(i+6000).DESCRIPTION                              := NULL ;
 l_tgdv_ext_tbl_in(i+6000).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_ext_tbl_in(i+6000).COMMENTS                                 := NULL ;
l_tgdv_ext_tbl_in(i+6000).MONTH                                   := NULL ;
 l_tgdv_ext_tbl_in(i+6000).DAY                                      := NULL ;
 l_tgdv_ext_tbl_in(i+6000).HOUR                                    := NULL ;
 l_tgdv_ext_tbl_in(i+6000).MINUTE                                   := NULL ;
 l_tgdv_ext_tbl_in(i+6000).SECOND                                  := NULL ;
 l_tgdv_ext_tbl_in(i+6000).NTH                                     := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE1                               := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE2                               := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE3                               := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE4                             := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE5                              := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE6                               := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE7                               := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE8                               := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE9                              := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE10                              := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE11                             := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE12                              := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE13                             := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE14                              := NULL ;
 l_tgdv_ext_tbl_in(i+6000).ATTRIBUTE15                             := NULL ;


    l_rilv_tbl_in(i+6000).tve_id 			:=l_tgdv_ext_tbl_in(i+6000).id;
    l_rilv_tbl_in(i+6000).rul_id			:=l_rulv_tbl_in(i+4000).id;
    l_rilv_tbl_in(i+6000).uom_code	:='HR';
    l_rilv_tbl_in(i+6000).duration			:=SAT_REACTION_TIMES_tbl(i);
    l_rilv_tbl_in(i+6000).object_version_number :=1;
    l_rilv_tbl_in(i+6000).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilv_tbl_in(i+6000).CREATION_DATE := g_CREATION_DATE;
    l_rilv_tbl_in(i+6000).CREATED_BY := g_CREATED_BY;
    l_rilv_tbl_in(i+6000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilv_tbl_in(i+6000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilv_tbl_in(i+6000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilv_tbl_in(i+6000).object_version_number        := 1;
END IF; ---SAT_REACTION_TIMES_tbl
IF SUN_RESOLUTION_TIMES_tbl(i) IS NOT NULL
THEN
  l_tgdv_rcn_tbl_in(i).id		:=okc_p_util.raw_to_number(sys_guid());
    l_tgdv_rcn_tbl_in(i).day_of_week  := 'SUN';
    l_tgdv_rcn_tbl_in(i).dnz_chr_id  :=l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_rcn_tbl_in(i).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_rcn_tbl_in(i).CREATED_BY := g_CREATED_BY;
    l_tgdv_rcn_tbl_in(i).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_rcn_tbl_in(i).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_rcn_tbl_in(i).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_rcn_tbl_in(i).Object_Version_Number        := 1;
l_tgdv_rcn_tbl_in(i).SFWT_FLAG                       := 'N' ;
 l_tgdv_rcn_tbl_in(i).TZE_ID                                   := NULL ;
 l_tgdv_rcn_tbl_in(i).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_rcn_tbl_in(i).DESCRIPTION                              := NULL ;
 l_tgdv_rcn_tbl_in(i).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_rcn_tbl_in(i).COMMENTS                                 := NULL ;
l_tgdv_rcn_tbl_in(i).MONTH                                   := NULL ;
 l_tgdv_rcn_tbl_in(i).DAY                                      := NULL ;
 l_tgdv_rcn_tbl_in(i).HOUR                                    := NULL ;
 l_tgdv_rcn_tbl_in(i).MINUTE                                   := NULL ;
 l_tgdv_rcn_tbl_in(i).SECOND                                  := NULL ;
 l_tgdv_rcn_tbl_in(i).NTH                                     := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE1                               := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE2                               := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE3                               := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE4                             := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE5                              := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE6                               := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE7                               := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE8                               := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE9                              := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE10                              := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE11                             := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE12                              := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE13                             := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE14                              := NULL ;
 l_tgdv_rcn_tbl_in(i).ATTRIBUTE15                             := NULL ;


    l_rilt_tbl_in(i).tve_id 			:=l_tgdv_rcn_tbl_in(i).id;
    l_rilt_tbl_in(i).rul_id			:=l_rulv_tbl_in(i+ 5000).id;
    l_rilt_tbl_in(i).uom_code	:='HR';
    l_rilt_tbl_in(i).duration			:=SUN_RESOLUTION_TIMES_tbl(i);
    l_rilt_tbl_in(i).object_version_number :=1;
    l_rilt_tbl_in(i).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilt_tbl_in(i).CREATION_DATE := g_CREATION_DATE;
    l_rilt_tbl_in(i).CREATED_BY := g_CREATED_BY;
    l_rilt_tbl_in(i).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilt_tbl_in(i).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilt_tbl_in(i).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilt_tbl_in(i).object_version_number        := 1;

END IF; ---SUN_RESOLUTION_TIMES_tbl

IF MON_RESOLUTION_TIMES_tbl(i) IS NOT NULL
THEN
  l_tgdv_rcn_tbl_in(i+1000).id		:=okc_p_util.raw_to_number(sys_guid());
    l_tgdv_rcn_tbl_in(i+1000).day_of_week  := 'MON';
    l_tgdv_rcn_tbl_in(i+1000).dnz_chr_id  :=l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_rcn_tbl_in(i+1000).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_rcn_tbl_in(i+1000).CREATED_BY := g_CREATED_BY;
    l_tgdv_rcn_tbl_in(i+1000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_rcn_tbl_in(i+1000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_rcn_tbl_in(i+1000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_rcn_tbl_in(i+1000).Object_Version_Number        := 1;
l_tgdv_rcn_tbl_in(i+1000).SFWT_FLAG                       := 'N' ;
 l_tgdv_rcn_tbl_in(i+1000).TZE_ID                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).DESCRIPTION                              := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).COMMENTS                                 := NULL ;
l_tgdv_rcn_tbl_in(i+1000).MONTH                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).DAY                                      := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).HOUR                                    := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).MINUTE                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).SECOND                                  := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).NTH                                     := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE1                               := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE2                               := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE3                               := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE4                             := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE5                              := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE6                               := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE7                               := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE8                               := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE9                              := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE10                              := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE11                             := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE12                              := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE13                             := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE14                              := NULL ;
 l_tgdv_rcn_tbl_in(i+1000).ATTRIBUTE15                             := NULL ;


    l_rilt_tbl_in(i+1000).tve_id 			:=l_tgdv_rcn_tbl_in(i+1000).id;
    l_rilt_tbl_in(i+1000).rul_id			:=l_rulv_tbl_in(i+5000).id;
    l_rilt_tbl_in(i+1000).uom_code	:='HR';
    l_rilt_tbl_in(i+1000).duration			:=MON_RESOLUTION_TIMES_tbl(i);
    l_rilt_tbl_in(i+1000).object_version_number :=1;
    l_rilt_tbl_in(i+1000).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilt_tbl_in(i+1000).CREATION_DATE := g_CREATION_DATE;
    l_rilt_tbl_in(i+1000).CREATED_BY := g_CREATED_BY;
    l_rilt_tbl_in(i+1000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilt_tbl_in(i+1000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilt_tbl_in(i+1000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilt_tbl_in(i+1000).object_version_number        := 1;
END IF; ---MON_RESOLUTION_TIMES_tbl


IF TUE_RESOLUTION_TIMES_tbl(i) IS NOT NULL
THEN
    l_tgdv_rcn_tbl_in(i+2000).day_of_week  := 'TUE';
    l_tgdv_rcn_tbl_in(i+2000).dnz_chr_id  := l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_rcn_tbl_in(i+2000).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_rcn_tbl_in(i+2000).CREATED_BY := g_CREATED_BY;
    l_tgdv_rcn_tbl_in(i+2000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_rcn_tbl_in(i+2000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_rcn_tbl_in(i+2000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_rcn_tbl_in(i+2000).object_version_number        := 1;
l_tgdv_rcn_tbl_in(i+2000).SFWT_FLAG                       := 'N' ;
 l_tgdv_rcn_tbl_in(i+2000).TZE_ID                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).DESCRIPTION                              := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).COMMENTS                                 := NULL ;
l_tgdv_rcn_tbl_in(i+2000).MONTH                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).DAY                                      := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).HOUR                                    := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).MINUTE                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).SECOND                                  := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).NTH                                     := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE1                               := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE2                               := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE3                               := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE4                             := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE5                              := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE6                               := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE7                               := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE8                               := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE9                              := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE10                              := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE11                             := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE12                              := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE13                             := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE14                              := NULL ;
 l_tgdv_rcn_tbl_in(i+2000).ATTRIBUTE15                             := NULL ;

    l_rilt_tbl_in(i+2000).tve_id 			:=l_tgdv_rcn_tbl_in(i+2000).id;
    l_rilt_tbl_in(i+2000).rul_id			:=l_rulv_tbl_in(i+5000).id;
    l_rilt_tbl_in(i+2000).uom_code	:='HR';
    l_rilt_tbl_in(i+2000).duration			:=TUE_RESOLUTION_TIMES_tbl(i);
    l_rilt_tbl_in(i+2000).object_version_number :=1;
    l_rilt_tbl_in(i+2000).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilt_tbl_in(i+2000).CREATION_DATE := g_CREATION_DATE;
    l_rilt_tbl_in(i+2000).CREATED_BY := g_CREATED_BY;
    l_rilt_tbl_in(i+2000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilt_tbl_in(i+2000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilt_tbl_in(i+2000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilt_tbl_in(i+2000).object_version_number        := 1;
END IF; ---TUE_RESOLUTION_TIMES_tbl
IF WED_RESOLUTION_TIMES_tbl(i) IS NOT NULL
THEN
  l_tgdv_rcn_tbl_in(i+3000).id		:=okc_p_util.raw_to_number(sys_guid());
    l_tgdv_rcn_tbl_in(i+3000).day_of_week  := 'WED';
    l_tgdv_rcn_tbl_in(i+3000).dnz_chr_id  :=l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_rcn_tbl_in(i+3000).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_rcn_tbl_in(i+3000).CREATED_BY := g_CREATED_BY;
    l_tgdv_rcn_tbl_in(i+3000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_rcn_tbl_in(i+3000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_rcn_tbl_in(i+3000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_rcn_tbl_in(i+3000).Object_Version_Number        := 1;
l_tgdv_rcn_tbl_in(i+3000).SFWT_FLAG                       := 'N' ;
 l_tgdv_rcn_tbl_in(i+3000).TZE_ID                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).DESCRIPTION                              := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).COMMENTS                                 := NULL ;
l_tgdv_rcn_tbl_in(i+3000).MONTH                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).DAY                                      := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).HOUR                                    := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).MINUTE                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).SECOND                                  := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).NTH                                     := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE1                               := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE2                               := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE3                               := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE4                             := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE5                              := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE6                               := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE7                               := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE8                               := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE9                              := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE10                              := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE11                             := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE12                              := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE13                             := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE14                              := NULL ;
 l_tgdv_rcn_tbl_in(i+3000).ATTRIBUTE15                             := NULL ;


    l_rilt_tbl_in(i+3000).tve_id 			:=l_tgdv_rcn_tbl_in(i+3000).id;
    l_rilt_tbl_in(i+3000).rul_id			:=l_rulv_tbl_in(i+5000).id;
    l_rilt_tbl_in(i+3000).uom_code	:='HR';
    l_rilt_tbl_in(i+3000).duration			:=WED_RESOLUTION_TIMES_tbl(i);
    l_rilt_tbl_in(i+3000).object_version_number :=1;
    l_rilt_tbl_in(i+3000).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilt_tbl_in(i+3000).CREATION_DATE := g_CREATION_DATE;
    l_rilt_tbl_in(i+3000).CREATED_BY := g_CREATED_BY;
    l_rilt_tbl_in(i+3000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilt_tbl_in(i+3000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilt_tbl_in(i+3000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilt_tbl_in(i+3000).object_version_number        := 1;
END IF; ---WED_RESOLUTION_TIMES_tbl

IF THU_RESOLUTION_TIMES_tbl(i) IS NOT NULL
THEN
  l_tgdv_rcn_tbl_in(i+4000).id		:=okc_p_util.raw_to_number(sys_guid());
    l_tgdv_rcn_tbl_in(i+4000).day_of_week  := 'THU';
    l_tgdv_rcn_tbl_in(i+4000).dnz_chr_id  :=l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_rcn_tbl_in(i+4000).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_rcn_tbl_in(i+4000).CREATED_BY := g_CREATED_BY;
    l_tgdv_rcn_tbl_in(i+4000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_rcn_tbl_in(i+4000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_rcn_tbl_in(i+4000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_rcn_tbl_in(i+4000).Object_Version_Number        := 1;
l_tgdv_rcn_tbl_in(i+4000).SFWT_FLAG                       := 'N' ;
 l_tgdv_rcn_tbl_in(i+4000).TZE_ID                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).DESCRIPTION                              := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).COMMENTS                                 := NULL ;
l_tgdv_rcn_tbl_in(i+4000).MONTH                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).DAY                                      := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).HOUR                                    := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).MINUTE                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).SECOND                                  := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).NTH                                     := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE1                               := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE2                               := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE3                               := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE4                             := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE5                              := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE6                               := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE7                               := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE8                               := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE9                              := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE10                              := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE11                             := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE12                              := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE13                             := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE14                              := NULL ;
 l_tgdv_rcn_tbl_in(i+4000).ATTRIBUTE15                             := NULL ;


    l_rilt_tbl_in(i+4000).tve_id 			:=l_tgdv_rcn_tbl_in(i+4000).id;
    l_rilt_tbl_in(i+4000).rul_id			:=l_rulv_tbl_in(i+5000).id;
    l_rilt_tbl_in(i+4000).uom_code	:='HR';
    l_rilt_tbl_in(i+4000).duration			:=THU_RESOLUTION_TIMES_tbl(i);
    l_rilt_tbl_in(i+4000).object_version_number :=1;
    l_rilt_tbl_in(i+4000).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilt_tbl_in(i+4000).CREATION_DATE := g_CREATION_DATE;
    l_rilt_tbl_in(i+4000).CREATED_BY := g_CREATED_BY;
    l_rilt_tbl_in(i+4000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilt_tbl_in(i+4000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilt_tbl_in(i+4000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilt_tbl_in(i+4000).object_version_number        := 1;
END IF; ---THU_RESOLUTION_TIMES_tbl

IF FRI_RESOLUTION_TIMES_tbl(i) IS NOT NULL
THEN
  l_tgdv_rcn_tbl_in(i+5000).id		:=okc_p_util.raw_to_number(sys_guid());
    l_tgdv_rcn_tbl_in(i+5000).day_of_week  := 'FRI';
    l_tgdv_rcn_tbl_in(i+5000).dnz_chr_id  :=l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_rcn_tbl_in(i+5000).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_rcn_tbl_in(i+5000).CREATED_BY := g_CREATED_BY;
    l_tgdv_rcn_tbl_in(i+5000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_rcn_tbl_in(i+5000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_rcn_tbl_in(i+5000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_rcn_tbl_in(i+5000).Object_Version_Number        := 1;
l_tgdv_rcn_tbl_in(i+5000).SFWT_FLAG                       := 'N' ;
 l_tgdv_rcn_tbl_in(i+5000).TZE_ID                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).DESCRIPTION                              := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).COMMENTS                                 := NULL ;
l_tgdv_rcn_tbl_in(i+5000).MONTH                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).DAY                                      := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).HOUR                                    := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).MINUTE                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).SECOND                                  := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).NTH                                     := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE1                               := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE2                               := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE3                               := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE4                             := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE5                              := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE6                               := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE7                               := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE8                               := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE9                              := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE10                              := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE11                             := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE12                              := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE13                             := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE14                              := NULL ;
 l_tgdv_rcn_tbl_in(i+5000).ATTRIBUTE15                             := NULL ;


    l_rilt_tbl_in(i+5000).tve_id 			:=l_tgdv_rcn_tbl_in(i+5000).id;
    l_rilt_tbl_in(i+5000).rul_id			:=l_rulv_tbl_in(i+5000).id;
    l_rilt_tbl_in(i+5000).uom_code	:='HR';
    l_rilt_tbl_in(i+5000).duration			:=FRI_RESOLUTION_TIMES_tbl(i);
    l_rilt_tbl_in(i+5000).object_version_number :=1;
    l_rilt_tbl_in(i+5000).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilt_tbl_in(i+5000).CREATION_DATE := g_CREATION_DATE;
    l_rilt_tbl_in(i+5000).CREATED_BY := g_CREATED_BY;
    l_rilt_tbl_in(i+5000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilt_tbl_in(i+5000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilt_tbl_in(i+5000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilt_tbl_in(i+5000).object_version_number        := 1;
END IF; ---FRI_RESOLUTION_TIMES_tbl

IF SAT_RESOLUTION_TIMES_tbl(i) IS NOT NULL
THEN
  l_tgdv_rcn_tbl_in(i+6000).id		:=okc_p_util.raw_to_number(sys_guid());
    l_tgdv_rcn_tbl_in(i+6000).day_of_week  := 'SAT';
    l_tgdv_rcn_tbl_in(i+6000).dnz_chr_id  :=l_clev_tbl_in(i).dnz_chr_Id;
    l_tgdv_rcn_tbl_in(i+6000).CREATION_DATE := g_CREATION_DATE;
    l_tgdv_rcn_tbl_in(i+6000).CREATED_BY := g_CREATED_BY;
    l_tgdv_rcn_tbl_in(i+6000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_tgdv_rcn_tbl_in(i+6000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_tgdv_rcn_tbl_in(i+6000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_tgdv_rcn_tbl_in(i+6000).Object_Version_Number        := 1;
l_tgdv_rcn_tbl_in(i+6000).SFWT_FLAG                       := 'N' ;
 l_tgdv_rcn_tbl_in(i+6000).TZE_ID                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).TVE_ID_LIMITED                           := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).DESCRIPTION                              := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).SHORT_DESCRIPTION                       := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).COMMENTS                                 := NULL ;
l_tgdv_rcn_tbl_in(i+6000).MONTH                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).DAY                                      := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).HOUR                                    := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).MINUTE                                   := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).SECOND                                  := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).NTH                                     := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE_CATEGORY                       := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE1                               := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE2                               := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE3                               := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE4                             := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE5                              := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE6                               := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE7                               := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE8                               := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE9                              := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE10                              := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE11                             := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE12                              := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE13                             := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE14                              := NULL ;
 l_tgdv_rcn_tbl_in(i+6000).ATTRIBUTE15                             := NULL ;


    l_rilt_tbl_in(i+6000).tve_id 			:=l_tgdv_rcn_tbl_in(i+6000).id;
    l_rilt_tbl_in(i+6000).rul_id			:=l_rulv_tbl_in(i+5000).id;
    l_rilt_tbl_in(i+6000).uom_code	:='HR';
    l_rilt_tbl_in(i+6000).duration			:=SAT_RESOLUTION_TIMES_tbl(i);
    l_rilt_tbl_in(i+6000).object_version_number :=1;
    l_rilt_tbl_in(i+6000).dnz_chr_id			         := l_clev_tbl_in(i).dnz_chr_Id;
    l_rilt_tbl_in(i+6000).CREATION_DATE := g_CREATION_DATE;
    l_rilt_tbl_in(i+6000).CREATED_BY := g_CREATED_BY;
    l_rilt_tbl_in(i+6000).LAST_UPDATE_DATE := g_LAST_UPDATE_DATE;
    l_rilt_tbl_in(i+6000).LAST_UPDATED_BY := g_LAST_UPDATED_BY;
    l_rilt_tbl_in(i+6000).LAST_UPDATE_LOGIN := g_LAST_UPDATE_LOGIN;
    l_rilt_tbl_in(i+6000).object_version_number        := 1;
END IF; ---SAT_RESOLUTION_TIMES_tbl

                END LOOP;
                           -- -- dbms_output.put_line('Test6');
        END IF;
IF L_validate_flag = 'Y' THEN




 If l_clev_tbl_in.count > 0 Then
   l_error_message := 'okc_cle_pvt -';
           okc_cle_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_clev_tbl      =>    l_clev_tbl_in,
                                x_clev_tbl      =>    x_clev_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
        End If;

                l_Clev_tbl_in.DELETE;

IF l_Cimv_tbl_in.COUNT>0
      THEN
   l_error_message := 'okc_cim_pvt -';
         okc_cim_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_cimv_tbl      =>    l_cimv_tbl_in,
                                x_cimv_tbl      =>    x_cimv_tbl_in);
dbms_output.put_line('Value of l_return_status='||l_return_status);
      END IF;
                l_Cimv_tbl_in.DELETE;


IF l_rgpv_tbl_in.COUNT>0
      THEN
   l_error_message := 'okc_rgp_pvt -';
okc_rgp_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rgpv_tbl      =>    l_rgpv_tbl_in,
                                x_rgpv_tbl      =>    x_rgpv_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
      END IF;
                l_rgpv_tbl_in.DELETE;


IF l_rulv_tbl_in.COUNT>0
      THEN
   l_error_message := 'okc_rul_pvt -';
           okc_rul_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rulv_tbl      =>    l_rulv_tbl_in,
                                x_rulv_tbl      =>    x_rulv_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
END IF;
l_rulv_tbl_in.delete;

 IF l_Cplv_tbl_In.COUNT>0
      THEN
   l_error_message := 'okc_cpl_pvt -';
	okc_cpl_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_cplv_tbl      =>    l_cplv_tbl_in,
                                x_cplv_tbl      =>    x_cplv_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
 END IF;
                l_Cplv_Tbl_In.DELETE;

 IF l_ctcv_tbl_In.COUNT>0
      THEN
   l_error_message := 'okc_ctc_pvt -';
	okc_ctc_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_ctcv_tbl      =>    l_ctcv_tbl_in,
                                x_ctcv_tbl      =>    x_ctcv_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
END IF;
                l_ctcv_Tbl_In.DELETE;

/*----------------------------------------*/

IF l_isev_rel_tbl_in.count > 0
THEN
l_error_message := 'okc_time_pvt.Insert_ise_Row_Upg -';
	okc_time_pvt.Insert_ise_Row_Upg(l_isev_rel_tbl_in);
END IF;
    l_isev_rel_tbl_in.delete;
    /*-----------------------------------------*/
 IF l_isev_ext_tbl_In.COUNT>0
      THEN
   l_error_message := 'okc_time_pvt.Insert_ise_Row_Upg -';
	okc_time_pvt.Insert_ise_Row_Upg(l_isev_ext_tbl_in);
 END IF;
                l_isev_ext_Tbl_In.DELETE;

 IF l_igsv_ext_tbl_In.COUNT>0
      THEN
   l_error_message := 'okc_time_pvt.Insert_igs_Row_Upg -';
	okc_time_pvt.Insert_igs_Row_Upg( l_igsv_ext_tbl_in);
 END IF;
                l_igsv_ext_Tbl_In.DELETE;


 IF l_ctiv_tbl_In.COUNT>0
      THEN
   l_error_message := 'okc_cti_pvt -';
--	okc_cti_pvt.Insert_Row_Upg( l_return_status , l_ctiv_tbl_in);
okc_cti_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_ctiv_tbl      =>    l_ctiv_tbl_in,
                                x_ctiv_tbl      =>    x_ctiv_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);

 END IF;
                l_ctiv_Tbl_In.DELETE;
IF l_tgdv_ext_tbl_in.COUNT>0
      THEN
      l_error_message := 'okc_Time_pvt -';
	okc_Time_pvt.Insert_Tgd_Row_Upg( l_tgdv_ext_tbl_in);
      END IF;
                l_tgdv_ext_tbl_in.DELETE;

IF l_rilv_tbl_in.COUNT>0
      THEN
      l_error_message := 'okc_ril_pvt -';
--	okc_ril_pvt.Insert_Row_Upg( l_return_status , l_rilv_tbl_in);
	okc_ril_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rilv_tbl      =>    l_rilv_tbl_in,
                                x_rilv_tbl      =>    x_rilv_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
END IF;
    l_rilv_tbl_in.DELETE;

IF l_tgdv_rcn_tbl_in.COUNT>0
      THEN
      l_error_message := 'okc_Time_pvt -';
	okc_Time_pvt.Insert_Tgd_Row_Upg( l_tgdv_rcn_tbl_in);
      END IF;
                l_tgdv_rcn_tbl_in.DELETE;

IF l_rilt_tbl_in.COUNT>0
      THEN
      l_error_message := 'okc_ril_pvt -';
--	okc_ril_pvt.Insert_Row_Upg( l_return_status , l_rilt_tbl_in);
	okc_ril_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rilv_tbl      =>    l_rilt_tbl_in,
                                x_rilv_tbl      =>    x_rilt_tbl_in);

dbms_output.put_line('Value of l_return_status='||l_return_status);
END IF;
    l_rilt_tbl_in.DELETE;



END IF;

----------===================N=============================

IF L_validate_flag = 'N' THEN

IF l_Clev_tbl_in.COUNT>0
      THEN
   l_error_message := 'okc_cle_pvt -';
   -- dbms_output.put_line('In Sert');
	okc_cle_pvt.Insert_Row_Upg( l_return_status , l_clev_tbl_in);
      END IF;
                l_Clev_tbl_in.DELETE;

IF l_Cimv_tbl_in.COUNT>0
      THEN
   l_error_message := 'okc_cim_pvt -';
	okc_cim_pvt.Insert_Row_Upg( l_return_status , l_cimv_tbl_in);
      END IF;
                l_Cimv_tbl_in.DELETE;


IF l_rgpv_tbl_in.COUNT>0
      THEN
   l_error_message := 'okc_rgp_pvt -';
	okc_rgp_pvt.Insert_Row_Upg( l_return_status , l_rgpv_tbl_in);
      END IF;
                l_rgpv_tbl_in.DELETE;


IF l_rulv_tbl_in.COUNT>0
      THEN
   l_error_message := 'okc_rul_pvt -';
	okc_rul_pvt.Insert_Row_Upg( l_return_status , l_rulv_tbl_in);
END IF;
l_rulv_tbl_in.delete;

 IF l_Cplv_tbl_In.COUNT>0
      THEN
   l_error_message := 'okc_cpl_pvt -';
	okc_cpl_pvt.Insert_Row_Upg( l_return_status , l_cplv_tbl_in);
 END IF;
                l_Cplv_Tbl_In.DELETE;
 IF l_ctcv_tbl_In.COUNT>0
      THEN
   l_error_message := 'okc_ctc_pvt -';
	okc_ctc_pvt.Insert_Row_Upg( l_return_status , l_ctcv_tbl_in);
END IF;
                l_ctcv_Tbl_In.DELETE;
/*----------------------------------------*/
IF l_isev_rel_tbl_in.count > 0
THEN
l_error_message := 'okc_time_pvt.Insert_ise_Row_Upg -';
	okc_time_pvt.Insert_ise_Row_Upg(l_isev_rel_tbl_in);
END IF;
    l_isev_rel_tbl_in.delete;
    /*-----------------------------------------*/
 IF l_isev_ext_tbl_In.COUNT>0
      THEN
   l_error_message := 'okc_time_pvt.Insert_ise_Row_Upg -';
	okc_time_pvt.Insert_ise_Row_Upg(l_isev_ext_tbl_in);
 END IF;
                l_isev_ext_Tbl_In.DELETE;

 IF l_igsv_ext_tbl_In.COUNT>0
      THEN
   l_error_message := 'okc_time_pvt.Insert_igs_Row_Upg -';
	okc_time_pvt.Insert_igs_Row_Upg( l_igsv_ext_tbl_in);
 END IF;
                l_igsv_ext_Tbl_In.DELETE;


 IF l_ctiv_tbl_In.COUNT>0
      THEN
   l_error_message := 'okc_cti_pvt -';
	okc_cti_pvt.Insert_Row_Upg( l_return_status , l_ctiv_tbl_in);
 END IF;
                l_ctiv_Tbl_In.DELETE;
IF l_tgdv_ext_tbl_in.COUNT>0
      THEN
      l_error_message := 'okc_Time_pvt -';
	okc_Time_pvt.Insert_Tgd_Row_Upg( l_tgdv_ext_tbl_in);
      END IF;
                l_tgdv_ext_tbl_in.DELETE;

IF l_rilv_tbl_in.COUNT>0
      THEN
      l_error_message := 'okc_ril_pvt -';
	okc_ril_pvt.Insert_Row_Upg( l_return_status , l_rilv_tbl_in);
END IF;
    l_rilv_tbl_in.DELETE;

IF l_tgdv_rcn_tbl_in.COUNT>0
      THEN
      l_error_message := 'okc_Time_pvt -';
	okc_Time_pvt.Insert_Tgd_Row_Upg( l_tgdv_rcn_tbl_in);
      END IF;
                l_tgdv_rcn_tbl_in.DELETE;

IF l_rilt_tbl_in.COUNT>0
      THEN
      l_error_message := 'okc_ril_pvt -';
	okc_ril_pvt.Insert_Row_Upg( l_return_status , l_rilt_tbl_in);
END IF;
    l_rilt_tbl_in.DELETE;

END IF;
  FORALL i in 1 .. COVERAGE_BUSS_PROCESS_ID_tbl.COUNT

          UPDATE oks_cov_txn_groups_int_all
          SET    INTERFACED_STATUS_FLAG  = 'S',
                 LAST_UPDATED_BY         = -1,
                 LAST_UPDATE_DATE        = sysdate,
                 LAST_UPDATE_LOGIN       = -1
          WHERE  coverage_bus_process_id = COVERAGE_BUSS_PROCESS_ID_tbl(i);

          commit;

    exit when get_buss_process_cur%notfound;
       EXCEPTION
       WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20000,'Error in Business Process Interface');
   END;
END LOOP;

IF  get_buss_process_cur%ISOPEN
        THEN
           CLOSE get_buss_process_cur;
        END IF;
 exception when others then
			ROLLBACK;
            RAISE_APPLICATION_ERROR(-20000,'Error in Business Process Interface');
  -- dbms_output.put_line('Outer Block'||sqlerrm);

END; ---Business_Processes_migrate

PROCEDURE Bill_Types_Migrate (P_FromId        IN  NUMBER,
                            P_ToId          IN  NUMBER,
                            P_VALIDATE_FLAG IN  VARCHAR2,
                            P_LOG_PARAMETER IN  VARCHAR2) IS

CURSOR get_bill_types (p_fromId IN NUMBER,p_toId IN NUMBER) IS
SELECT
 obt.COV_BP_BILLING_TYPE_ID         ,
 obt.UPTO_AMOUNT                    ,
 obt.PERCENT_COVER                  ,
 obt.BILLING_TYPE_ID                ,
 obt.COVERAGE_BUS_PROCESS_ID        ,
 obt.ATTRIBUTE_CATEGORY             ,
 obt.ATTRIBUTE1                     ,
 obt.ATTRIBUTE2                     ,
 obt.ATTRIBUTE3                     ,
 obt.ATTRIBUTE4                     ,
 obt.ATTRIBUTE5                     ,
 obt.ATTRIBUTE6                     ,
 obt.ATTRIBUTE7                     ,
 obt.ATTRIBUTE8                     ,
 obt.ATTRIBUTE9                     ,
 obt.ATTRIBUTE10                    ,
 obt.ATTRIBUTE11                    ,
 obt.ATTRIBUTE12                    ,
 obt.ATTRIBUTE13                    ,
 obt.ATTRIBUTE14                    ,
 obt.ATTRIBUTE15                    ,
 okl.id                             ,
 okl.dnz_chr_id                     ,
 okl.sts_code                       ,
 okl.start_date                     ,
 okl.end_date                       ,
 okl.currency_code
FROM
    oks_cov_bill_types_int_all obt ,
    oks_cov_txn_groups_int_all obp,
    okc_k_lines_b okl,
    oks_coverages_int_all cov,
    oks_con_lines_int_all lines,
    oks_con_headers_int_all head

WHERE
    obt.COVERAGE_BUS_PROCESS_ID  =  obp.COVERAGE_BUS_PROCESS_ID
 AND okl.upg_Orig_System_Ref= g_bpline_ref --'Int_Buss_Process_Line'
 AND okl.upg_Orig_System_Ref_id = obp.coverage_bus_process_id
 AND okl.lse_id = 3
 AND obt.coverage_id = obp.coverage_id
 AND obt.interfaced_status_flag is null
 AND cov.interfaced_status_flag = 'S'
 AND lines.interfaced_status_flag = 'S'
 AND head.interfaced_status_flag = 'S'
 AND obp.coverage_id = cov.coverage_id
 AND cov.coverage_id = lines.coverage_id
 AND lines.contract_id = head.contract_id
 AND head.batch_number between p_FromId and P_ToId;

l_validate_flag VARCHAR2(1) := p_validate_flag;

l_error_message varchar2(2000);
l_return_status varchar2(2);
 COV_BP_BILLING_TYPE_ID_tbl             Num_Tbl_type;
 UPTO_AMOUNT_tbl                        Num_Tbl_type;
 PERCENT_COVER_tbl                      Num_Tbl_type;
 BILLING_TYPE_ID_tbl                    Num_Tbl_type;
 COVERAGE_BUS_PROCESS_ID_tbl            Num_Tbl_type;
 CURRENCY_CODE_Tbl	             	Vc15_Tbl_Type;
 ATTRIBUTE_CATEGORY_tbl                 Vc150_Tbl_Type;
 ATTRIBUTE1_tbl                         Vc150_Tbl_Type;
 ATTRIBUTE2_tbl                         Vc150_Tbl_Type;
 ATTRIBUTE3_tbl                         Vc150_Tbl_Type;
 ATTRIBUTE4_tbl                         Vc150_Tbl_Type;
 ATTRIBUTE5_tbl                         Vc150_Tbl_Type;
 ATTRIBUTE6_tbl                         Vc150_Tbl_Type;
 ATTRIBUTE7_tbl                         Vc150_Tbl_Type;
 ATTRIBUTE8_tbl                         Vc150_Tbl_Type;
 ATTRIBUTE9_tbl                         Vc150_Tbl_Type;
 ATTRIBUTE10_tbl                        Vc150_Tbl_Type;
 ATTRIBUTE11_tbl                        Vc150_Tbl_Type;
 ATTRIBUTE12_tbl                        Vc150_Tbl_Type;
 ATTRIBUTE13_tbl                        Vc150_Tbl_Type;
 ATTRIBUTE14_tbl                        Vc150_Tbl_Type;
 ATTRIBUTE15_tbl                        Vc150_Tbl_Type;
 id_tbl                                 NUM_Tbl_type;
 dnz_chr_id_tbl                         NUM_Tbl_type;
 sts_code_tbl                           Vc30_Tbl_Type;
 start_date_tbl                         Date_Tbl_Type;
 end_date_tbl                           Date_Tbl_Type;

 TYPE K_Status_rec IS RECORD (old_status Varchar2(30),new_status Varchar2(30));
TYPE K_Status_Tab is TABLE OF K_Status_Rec INDEX BY BINARY_Integer;
l_status_tab  K_Status_Tab;
 FUNCTION Get_new_status(p_k_status_id IN Number)
 RETURN Varchar2 IS
   l_new_status Varchar2(30);
BEGIN
   Return(l_status_tab(p_k_status_id).new_status);
END Get_new_status;

Begin -- Main Begin of Bill Types --
---- dbms_output.put_line('Test');
    open get_bill_types (p_FromId,p_ToID);
        loop
            BEGIN
        fetch get_bill_types bulk collect into
         COV_BP_BILLING_TYPE_ID_tbl,
         UPTO_AMOUNT_tbl,
         PERCENT_COVER_tbl,
         BILLING_TYPE_ID_tbl,
         COVERAGE_BUS_PROCESS_ID_tbl,
         ATTRIBUTE_CATEGORY_tbl,
         ATTRIBUTE1_tbl,
         ATTRIBUTE2_tbl,
         ATTRIBUTE3_tbl,
         ATTRIBUTE4_tbl,
         ATTRIBUTE5_tbl,
         ATTRIBUTE6_tbl,
         ATTRIBUTE7_tbl,
         ATTRIBUTE8_tbl,
         ATTRIBUTE9_tbl,
         ATTRIBUTE10_tbl,
         ATTRIBUTE11_tbl,
         ATTRIBUTE12_tbl,
         ATTRIBUTE13_tbl,
         ATTRIBUTE14_tbl,
         ATTRIBUTE15_tbl,
         id_tbl,
         dnz_chr_id_tbl,
         sts_code_tbl,
         start_date_tbl,
         end_date_tbl,
         currency_code_tbl
        LIMIT 1000;

        -- dbms_output.put_line('Value of COV_BP_BILLING_TYPE_ID_tbl.COUNT='||TO_CHAR(COV_BP_BILLING_TYPE_ID_tbl.COUNT));
     /*
        if (get_bill_types%notfound) then
            close get_bill_types;
        end if;
       */
          IF ( COV_BP_BILLING_TYPE_ID_tbl.COUNT > 0) THEN
             FOR i IN COV_BP_BILLING_TYPE_ID_tbl.FIRST .. COV_BP_BILLING_TYPE_ID_tbl.LAST
                LOOP
                -- dbms_output.put_line('Test44');
                    l_clev_tbl_in(i).id        :=  okc_p_util.raw_to_number(sys_guid());
                    l_clev_tbl_in(i).CREATION_DATE := sysdate;
                    l_clev_tbl_in(i).CREATED_BY := -1;
                    l_clev_tbl_in(i).LAST_UPDATE_DATE := sysdate;
                    l_clev_tbl_in(i).LAST_UPDATED_BY := -1;
                    l_clev_tbl_in(i).LAST_UPDATE_LOGIN := -1;
                    l_clev_tbl_in(i).object_version_number  := 1;
                    l_clev_tbl_in(i).dnz_chr_id	:= dnz_chr_id_tbl(i);
                    l_clev_tbl_in(i).cle_id		:= Id_Tbl(i);
                    l_clev_tbl_in(i).chr_id		:= null;
	                l_clev_tbl_in(i).sfwt_flag	:='N';
                    l_clev_tbl_in(i).lse_id		:= 5;
                    l_clev_tbl_in(i).sts_code	:=sts_code_tbl(i);
                  --  l_clev_tbl_in(i).orig_system_id1 := NULL;
	                l_clev_tbl_in(i).display_sequence	:=1;
                                    -- dbms_output.put_line('Test55');
                	l_clev_tbl_in(i).Name		:='Upgraded';      --Name;
                	l_clev_tbl_in(i).exception_yn	:='N';  --	clarify
                	l_clev_tbl_in(i).Currency_Code	:=Currency_Code_Tbl(i);
                    l_clev_tbl_in(i).start_date :=start_date_tbl(i);
                    l_clev_tbl_in(i).end_date   :=end_date_tbl(i);
                	l_clev_tbl_in(i).attribute1	       :=Attribute1_Tbl(i);
                	l_clev_tbl_in(i).attribute2	       :=Attribute2_Tbl(i);
                	l_clev_tbl_in(i).attribute3	       :=Attribute3_Tbl(i);
                	l_clev_tbl_in(i).attribute4	       :=Attribute4_Tbl(i);
                	l_clev_tbl_in(i).attribute5	       :=Attribute5_Tbl(i);
                	l_clev_tbl_in(i).attribute6	       :=Attribute6_Tbl(i);
                   	l_clev_tbl_in(i).attribute7	       :=Attribute7_Tbl(i);
                	l_clev_tbl_in(i).attribute8	       :=Attribute8_Tbl(i);
                	l_clev_tbl_in(i).attribute9	       :=Attribute9_Tbl(i);
                	l_clev_tbl_in(i).attribute10	  :=Attribute10_Tbl(i);
                	l_clev_tbl_in(i).attribute11	  :=Attribute11_Tbl(i);
                	l_clev_tbl_in(i).attribute12	  :=Attribute12_Tbl(i);
                	l_clev_tbl_in(i).attribute13	  :=Attribute13_Tbl(i);
                	l_clev_tbl_in(i).attribute14	  :=Attribute14_Tbl(i);
                	l_clev_tbl_in(i).attribute15	  :=Attribute15_Tbl(i);
                	l_clev_tbl_in(i).attribute_Category	:=ATTRIBUTE_CATEGORY_tbl(i);
                    l_clev_tbl_in(i).Upg_Orig_System_Ref    :=g_btline_ref ;
                                    -- dbms_output.put_line('Test66');
     l_clev_tbl_in(i).Upg_Orig_System_Ref_Id :=COV_BP_BILLING_TYPE_ID_tbl(i);
     l_clev_tbl_in(i).INVOICE_LINE_LEVEL_IND                  :=Null;
    l_clev_tbl_in(i).DPAS_RATING                             :=Null;
    l_clev_tbl_in(i).TEMPLATE_USED                            :=Null;
    l_clev_tbl_in(i).PRICE_TYPE                             :=Null;
    --l_clev_tbl_in(i).UOM_CODE                                :=Null;
    l_clev_tbl_in(i).LINE_NUMBER                     		:='4';
    l_clev_tbl_in(i).TRN_CODE                                 :=Null;
    l_clev_tbl_in(i).LAST_UPDATE_LOGIN                        :=Null;
    l_clev_tbl_in(i).HIDDEN_IND                               :=Null;
    l_clev_tbl_in(i).DATE_TERMINATED                        :=Null;
    l_clev_tbl_in(i).CLE_ID_RENEWED_TO                        :=Null;
    l_clev_tbl_in(i).CURRENCY_CODE_RENEWED                    :=Null;
    l_clev_tbl_in(i).PRICE_NEGOTIATED_RENEWED                 :=Null;
                                        -- dbms_output.put_line('Test77');
    l_clev_tbl_in(i).cle_id_renewed           :=NULL;
    l_clev_tbl_in(i).comments                 :=NULL;
    l_clev_tbl_in(i).price_unit               :=NULL;
    l_clev_tbl_in(i).price_unit_percent       :=NULL;
    l_clev_tbl_in(i).price_negotiated         :=NULL;
    l_clev_tbl_in(i).price_level_ind          :='N';
    l_clev_tbl_in(i).block23text              :=NULL;
        l_clev_tbl_in(i).program_application_id:= fnd_global.prog_appl_id;
        l_clev_tbl_in(i).program_id:= fnd_global.CONC_PROGRAM_ID;
   -- -- dbms_output.put_line('Test');

	l_cimv_tbl_in(i).cle_id		    := l_clev_tbl_in(i).Id;
	l_cimv_tbl_in(i).chr_id		    := null;
	l_cimv_tbl_in(i).cle_id_for	    := Null;
	l_cimv_tbl_in(i).object1_id1	    := Billing_Type_Id_Tbl(i);
  	l_cimv_tbl_in(i).object1_id2	    := '#';
	l_cimv_tbl_in(i).JTOT_OBJECT1_CODE    := 'OKX_BILLTYPE';
	l_cimv_tbl_in(i).exception_yn	    := 'N';
	l_cimv_tbl_in(i).number_of_items    := 1;
	l_cimv_tbl_in(i).dnz_chr_id	    := dnz_chr_id_tbl(i);
   	l_cimv_tbl_in(i).id        := okc_p_util.raw_to_number(sys_guid());
	l_cimv_tbl_in(i).CREATION_DATE := sysdate;
     l_cimv_tbl_in(i).CREATED_BY := -1 ;
     l_cimv_tbl_in(i).LAST_UPDATE_DATE := sysdate;
     l_cimv_tbl_in(i).LAST_UPDATED_BY := -1 ;
     l_cimv_tbl_in(i).LAST_UPDATE_LOGIN := -1 ;
     l_cimv_tbl_in(i).object_version_number        := 1;
     l_cimv_tbl_in(i).CLE_ID_FOR                  :=Null;
     l_cimv_tbl_in(i).PRICED_ITEM_YN              :=Null;
     l_cimv_tbl_in(i).UPG_ORIG_SYSTEM_REF         :=Null;
     l_cimv_tbl_in(i).UPG_ORIG_SYSTEM_REF_ID      :=Null;
	 l_cimv_tbl_in(i).uom_code	             := Null;

        l_cimv_tbl_in(i).program_application_id:= fnd_global.prog_appl_id;
        l_cimv_tbl_in(i).program_id:= fnd_global.CONC_PROGRAM_ID;

        l_rgpv_tbl_in(i).cle_id	:= l_clev_tbl_in(i).Id;
        l_rgpv_tbl_in(i).sfwt_flag	:= 'N';
        l_rgpv_tbl_in(i).rgd_code	:= 'SVC_K';
        l_rgpv_tbl_in(i).rgp_type	:= 'KRG';
        l_rgpv_tbl_in(i).id        := okc_p_util.raw_to_number(sys_guid());
        l_rgpv_tbl_in(i).CREATION_DATE := sysdate;
        l_rgpv_tbl_in(i).CREATED_BY := -1 ;
        l_rgpv_tbl_in(i).LAST_UPDATE_DATE := sysdate;
        l_rgpv_tbl_in(i).LAST_UPDATED_BY := -1 ;
        l_rgpv_tbl_in(i).LAST_UPDATE_LOGIN := -1 ;
        l_rgpv_tbl_in(i).object_version_number        := 1;
      l_rgpv_tbl_in(i).dnz_chr_id:=dnz_chr_id_tbl(i);
	l_rgpv_tbl_in(i).CHR_ID                                   :=Null;
        l_rgpv_tbl_in(i).PARENT_RGP_ID                            :=Null;
	l_rgpv_tbl_in(i).SAT_CODE                                 :=Null;
	l_rgpv_tbl_in(i).COMMENTS                                 :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE_CATEGORY                       :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE1                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE2                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE3                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE4                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE5                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE6                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE7                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE8                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE9                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE10                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE11                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE12                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE13                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE14                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE15                              :=Null;



IF ((upto_amount_Tbl(i) IS NOT NULL) OR    (Percent_cover_Tbl(i) IS NOT NULL)) THEN

   l_rulv_tbl_in(i).rgp_id	       	    := l_rgpv_tbl_in(i).id;
   l_rulv_tbl_in(i).sfwt_flag                 := 'N';
   l_rulv_tbl_in(i).rule_information_category := 'LMT';
   l_rulv_tbl_in(i).rule_information2	    := upto_amount_Tbl(i);
   l_rulv_tbl_in(i).rule_information4	    := Percent_cover_Tbl(i);
   l_rulv_tbl_in(i).std_template_yn   := 'N';
   l_rulv_tbl_in(i).warn_yn           := 'N';
   l_rulv_tbl_in(i).dnz_chr_id        :=dnz_chr_id_tbl(i);
   l_rulv_tbl_in(i).id        := okc_p_util.raw_to_number(sys_guid());
   l_rulv_tbl_in(i).CREATION_DATE := sysdate;
   l_rulv_tbl_in(i).CREATED_BY := -1 ;
   l_rulv_tbl_in(i).LAST_UPDATE_DATE := sysdate;
   l_rulv_tbl_in(i).LAST_UPDATED_BY := -1;
   l_rulv_tbl_in(i).LAST_UPDATE_LOGIN := -1;
   l_rulv_tbl_in(i).object_version_number        := 1;
   l_rulv_tbl_in(i).OBJECT1_ID1                              :=NULL;
   l_rulv_tbl_in(i).OBJECT2_ID1                              :=NULL;
   l_rulv_tbl_in(i).OBJECT3_ID1                              :=NULL;
   l_rulv_tbl_in(i).OBJECT1_ID2                              :=NULL;
   l_rulv_tbl_in(i).OBJECT2_ID2                              :=NULL;
   l_rulv_tbl_in(i).OBJECT3_ID2                              :=NULL;
   l_rulv_tbl_in(i).JTOT_OBJECT1_CODE                        :=NULL;
   l_rulv_tbl_in(i).JTOT_OBJECT2_CODE                        :=NULL;
   l_rulv_tbl_in(i).JTOT_OBJECT3_CODE                        :=NULL;
   l_rulv_tbl_in(i).PRIORITY                                 :=NULL;
   l_rulv_tbl_in(i).COMMENTS                                 :=NULL;
   l_rulv_tbl_in(i).ATTRIBUTE_CATEGORY                       :=NULL;
   l_rulv_tbl_in(i).ATTRIBUTE1                               :=NULL;
   l_rulv_tbl_in(i).ATTRIBUTE2                               :=NULL;
   l_rulv_tbl_in(i).ATTRIBUTE3                               :=NULL;
   l_rulv_tbl_in(i).ATTRIBUTE4                               :=NULL;
   l_rulv_tbl_in(i).ATTRIBUTE5                               :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE6                               :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE7                               :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE8                               :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE9                               :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE10                              :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE11                              :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE12                              :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE13                              :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE14                              :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE15                              :=NULL;
l_rulv_tbl_in(i).TEXT                                     :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION1                        :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION3                        :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION5                        :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION6                        :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION7                        :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION8                        :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION9                        :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION10                       :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION11                       :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION12                       :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION13                       :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION14                       :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION15                       :=NULL;
End If;

end loop;

end if;

If l_validate_flag = 'Y' THEN
	IF l_Clev_tbl_in.COUNT>0      	THEN
    l_Error_Message := 'okc_cle_pvt';
         okc_cle_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_clev_tbl      =>    l_clev_tbl_in,
                                x_clev_tbl      =>    x_clev_tbl_in);
   	END IF;

	IF l_rgpv_tbl_in.COUNT>0      	THEN
    l_Error_Message := 'okc_rgp_pvt';
        okc_rgp_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rgpv_tbl      =>    l_rgpv_tbl_in,
                                x_rgpv_tbl      =>    x_rgpv_tbl_in);
      	END IF;

	IF l_rulv_tbl_in.COUNT>0      	THEN

    l_Error_Message := 'okc_rul_pvt';
           okc_rul_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rulv_tbl      =>    l_rulv_tbl_in,
                                x_rulv_tbl      =>    x_rulv_tbl_in);

	END IF;

	IF l_Cimv_tbl_in.COUNT>0      	THEN
    l_Error_Message := 'okc_cim_pvt';
         okc_cim_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_cimv_tbl      =>    l_cimv_tbl_in,
                                x_cimv_tbl      =>    x_cimv_tbl_in);
      	END IF;

END IF;


if l_validate_flag = 'N' THEN

	IF l_Clev_tbl_in.COUNT>0      	THEN
    l_Error_Message := 'okc_cle_pvt';
	okc_cle_pvt.Insert_Row_Upg( l_return_status , l_clev_tbl_in);
      	END IF;

	IF l_rgpv_tbl_in.COUNT>0      	THEN
    l_Error_Message := 'okc_rgp_pvt';
	okc_rgp_pvt.Insert_Row_Upg( l_return_status , l_rgpv_tbl_in);
      	END IF;

	IF l_rulv_tbl_in.COUNT>0      	THEN

    l_Error_Message := 'okc_rul_pvt';
	okc_rul_pvt.Insert_Row_Upg( l_return_status , l_rulv_tbl_in);
	END IF;


	IF l_Cimv_tbl_in.COUNT>0      	THEN
    l_Error_Message := 'okc_cim_pvt';
	okc_cim_pvt.Insert_Row_Upg( l_return_status , l_cimv_tbl_in);
      	END IF;

END IF;
                l_Cimv_tbl_in.DELETE;
                  l_rgpv_tbl_in.DELETE;
                 l_rulv_tbl_in.DELETE;
                 l_Clev_tbl_in.DELETE;
                    -- dbms_output.put_line('Before Commit');

          FORALL i in 1 .. COV_BP_BILLING_TYPE_ID_tbl.COUNT

          UPDATE oks_cov_bill_types_int_all
          SET    INTERFACED_STATUS_FLAG  = 'S',
                 LAST_UPDATED_BY         = -1,
                 LAST_UPDATE_DATE        = sysdate,
                 LAST_UPDATE_LOGIN       = -1
          WHERE  COV_BP_BILLING_TYPE_ID = COV_BP_BILLING_TYPE_ID_tbl(i);

          commit;

    exit when get_bill_types%notfound;
       EXCEPTION
       WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20000,'Error in Bill Type Interface');
   END;


end loop;
IF  get_bill_types%ISOPEN
        THEN
           CLOSE get_bill_types;
        END IF;


end; -- Bill_Types_Migrate


PROCEDURE Bill_Rates_Migrate (P_FromId        IN  NUMBER,
                            P_ToId          IN  NUMBER,
                            P_VALIDATE_FLAG IN  VARCHAR2,
                            P_LOG_PARAMETER IN  VARCHAR2) IS

CURSOR get_bill_rates_cur (P_FromId IN NUMBER,P_TOId IN NUMBER) IS
select
	obr.COVERAGE_BILL_RATE_ID,
obr.COVERAGE_BILLING_TYPE_ID,
obr.BILL_RATE_CODE,
obr.UNIT_OF_MEASURE_CODE,
obr.FLAT_RATE,
obr.PERCENT_RATE,
obr.ATTRIBUTE_CATEGORY,
obr.ATTRIBUTE1,
obr.ATTRIBUTE2,
obr.ATTRIBUTE3,
obr.ATTRIBUTE4,
obr.ATTRIBUTE5,
obr.ATTRIBUTE6,
obr.ATTRIBUTE7,
obr.ATTRIBUTE8,
obr.ATTRIBUTE9,
obr.ATTRIBUTE10,
obr.ATTRIBUTE11,
obr.ATTRIBUTE12,
obr.ATTRIBUTE13,
obr.ATTRIBUTE14,
obr.ATTRIBUTE15,
okl.id,
okl.sts_code,
okl.start_date,
okl.end_date,
okl.dnz_chr_id,
okl.currency_code
FROM    oks_cov_bill_rates_int_all obr ,
        oks_cov_bill_types_int_all obt,
        okc_k_lines_b okl,
        oks_cov_txn_groups_int_all obp,
        oks_coverages_int_all cov,
        oks_con_lines_int_all lines,
        oks_con_headers_int_all head
WHERE   obr.COVERAGE_BILLING_TYPE_ID = obt.COV_BP_BILLING_TYPE_ID
AND     okl.upg_Orig_System_Ref= g_btline_ref
AND     okl.upg_Orig_System_Ref_Id = obt.COV_BP_BILLING_TYPE_ID
AND     okl.lse_id = 5
AND     obr.interfaced_status_flag is null
AND     obt.interfaced_status_flag = 'S'
AND     head.interfaced_status_flag = 'S'
AND     lines.interfaced_status_flag = 'S'
AND     cov.interfaced_status_flag = 'S'
AND     obp.interfaced_status_flag = 'S'
AND     obt.interfaced_status_flag = 'S'
AND     head.batch_number between p_fromid and p_toid
AND     head.contract_id = lines.contract_id
AND     lines.coverage_id = cov.coverage_id
AND     cov.coverage_id = obp.coverage_id
AND     obp.COVERAGE_BUS_PROCESS_ID = obt.COVERAGE_BUS_PROCESS_ID
AND     obp.coverage_id = obt.coverage_id;



l_validate_flag VARCHAR2(1) := p_validate_flag;

l_error_message   varchar2(2000);
l_return_status   varchar2(2);
  COVERAGE_BILL_RATE_ID_tbl       NUM_TBL_TYPE ;
  COVERAGE_BILLING_TYPE_ID_tbl    NUM_TBL_TYPE ;
  BILL_RATE_CODE_tbl     	  VC30_TBL_TYPE;
  UNIT_OF_MEASURE_CODE_tbl	  Vc15_Tbl_Type;
  FLAT_RATE_tbl			  NUM_TBL_TYPE;
  PERCENT_RATE_tbl		  NUM_TBL_TYPE;
  ATTRIBUTE_CATEGORY_tbl          Vc150_Tbl_Type;
  ATTRIBUTE1_tbl     		  Vc150_Tbl_Type;
  ATTRIBUTE2_tbl     Vc150_Tbl_Type;
  ATTRIBUTE3_tbl     Vc150_Tbl_Type;
  ATTRIBUTE4_tbl     Vc150_Tbl_Type;
  ATTRIBUTE5_tbl     Vc150_Tbl_Type;
  ATTRIBUTE6_tbl     Vc150_Tbl_Type;
  ATTRIBUTE7_tbl     Vc150_Tbl_Type;
  ATTRIBUTE8_tbl     Vc150_Tbl_Type;
  ATTRIBUTE9_tbl     Vc150_Tbl_Type;
  ATTRIBUTE10_tbl     Vc150_Tbl_Type;
  ATTRIBUTE11_tbl     Vc150_Tbl_Type;
  ATTRIBUTE12_tbl     Vc150_Tbl_Type;
  ATTRIBUTE13_tbl     Vc150_Tbl_Type;
  ATTRIBUTE14_tbl     Vc150_Tbl_Type;
  ATTRIBUTE15_tbl     Vc150_Tbl_Type;
  ID_tbl              NUM_TBL_TYPE ;
  sts_code_tbl        Vc30_Tbl_Type;
  start_date_tbl      Date_Tbl_Type;
  end_date_tbl      Date_Tbl_Type;
  dnz_chr_id_tbl        Num_Tbl_Type;
  CURRENCY_CODE_Tbl		Vc15_Tbl_Type;

  FUNCTION GetTimeUom(P_Uom_Code IN VARCHAR2)
   RETURN Varchar2 IS
   l_TimeUnit VARCHAR2(3):= NULL;
  BEGIN
  IF Upper(P_Uom_Code)='DAY'
  THEN l_TimeUnit:='DAY';
  ELSIF Upper(P_Uom_Code)='HOUR'
  THEN l_TimeUnit:='HR';
  ELSIF Upper(P_Uom_Code)='MINUTE'
  THEN l_TimeUnit:='MIN';
  ELSIF Upper(P_Uom_Code)='WEEK'
  THEN l_TimeUnit:='WK';
  ELSIF Upper(P_Uom_Code)='MONTH'
  THEN l_TimeUnit:='MTH';
  ELSIF Upper(P_Uom_Code)='YEAR'
  THEN l_TimeUnit:='YR';
  END IF;
  RETURN l_TimeUnit;
  END  GetTimeUom;
begin
---- dbms_output.put_line('Test');

open get_bill_rates_cur (p_fromid,p_toid);
loop
begin
fetch get_bill_rates_cur bulk collect into
  COVERAGE_BILL_RATE_ID_tbl,
  COVERAGE_BILLING_TYPE_ID_tbl,
  BILL_RATE_CODE_tbl,
  UNIT_OF_MEASURE_CODE_tbl,
  FLAT_RATE_tbl,
  PERCENT_RATE_tbl,
  ATTRIBUTE_CATEGORY_tbl,
  ATTRIBUTE1_tbl,
  ATTRIBUTE2_tbl,
  ATTRIBUTE3_tbl,
  ATTRIBUTE4_tbl,
  ATTRIBUTE5_tbl,
  ATTRIBUTE6_tbl,
  ATTRIBUTE7_tbl,
  ATTRIBUTE8_tbl,
  ATTRIBUTE9_tbl,
  ATTRIBUTE10_tbl,
  ATTRIBUTE11_tbl,
  ATTRIBUTE12_tbl,
  ATTRIBUTE13_tbl,
  ATTRIBUTE14_tbl,
  ATTRIBUTE15_tbl,
  id_tbl ,
  sts_code_tbl,
  start_date_tbl,
  end_date_tbl,
  dnz_chr_id_tbl,
  currency_code_tbl
  limit 1000;
/*
if (get_bill_rates_cur%notfound) then
            close get_bill_rates_cur;
        end if;
        */
        if   (COVERAGE_BILL_RATE_ID_tbl.count > 0) then
---- dbms_output.put_line('Test2');
   FOR  i IN COVERAGE_BILL_RATE_ID_tbl.FIRST .. COVERAGE_BILL_RATE_ID_tbl.LAST
    LOOP
    l_clev_tbl_in(i).id        	:=  okc_p_util.raw_to_number(sys_guid());
    l_clev_tbl_in(i).CREATION_DATE := sysdate;
    l_clev_tbl_in(i).CREATED_BY 	:= -1;
    l_clev_tbl_in(i).LAST_UPDATE_DATE := sysdate;
    l_clev_tbl_in(i).LAST_UPDATED_BY 	:= -1 ;
    l_clev_tbl_in(i).LAST_UPDATE_LOGIN := -1 ;
    l_clev_tbl_in(i).object_version_number  := 1;
    l_clev_tbl_in(i).cle_id		:= Id_Tbl(i);
    l_clev_tbl_in(i).chr_id		:= null;
	l_clev_tbl_in(i).sfwt_flag	:='N';
	l_clev_tbl_in(i).lse_id	:= 6;
	l_clev_tbl_in(i).sts_code	:= sts_code_tbl(i); --Get_New_Status(Contract_Line_Status_Id_Tbl(i));
	l_clev_tbl_in(i).display_sequence	:=1;
     l_clev_tbl_in(i).start_date := Start_Date_Tbl(i);
     l_clev_tbl_in(i).end_date   :=END_Date_Tbl(i);
	l_clev_tbl_in(i).Currency_Code	:=Currency_Code_Tbl(i);
	l_clev_tbl_in(i).Name		     :='Migrated Bill Rate ';
	l_clev_tbl_in(i).exception_yn	    :='N';  --	clarify
	l_clev_tbl_in(i).attribute1	           :=Attribute1_Tbl(i);
	l_clev_tbl_in(i).attribute2	           :=Attribute2_Tbl(i);
	l_clev_tbl_in(i).attribute3	           :=Attribute3_Tbl(i);
	l_clev_tbl_in(i).attribute4	           :=Attribute4_Tbl(i);
	l_clev_tbl_in(i).attribute5	           :=Attribute5_Tbl(i);
	l_clev_tbl_in(i).attribute6	           :=Attribute6_Tbl(i);
	l_clev_tbl_in(i).attribute7	           :=Attribute7_Tbl(i);
	l_clev_tbl_in(i).attribute8	           :=Attribute8_Tbl(i);
	l_clev_tbl_in(i).attribute9	           :=Attribute9_Tbl(i);
	l_clev_tbl_in(i).attribute10	:=Attribute10_Tbl(i);
	l_clev_tbl_in(i).attribute11	:=Attribute11_Tbl(i);
	l_clev_tbl_in(i).attribute12	:=Attribute12_Tbl(i);
	l_clev_tbl_in(i).attribute13	:=Attribute13_Tbl(i);
	l_clev_tbl_in(i).attribute14	:=Attribute14_Tbl(i);
	l_clev_tbl_in(i).attribute15	:=Attribute15_Tbl(i);
	l_clev_tbl_in(i).attribute_Category	:=ATTRIBUTE_CATEGORY_tbl(i);
    l_clev_tbl_in(i).dnz_chr_id        := dnz_chr_id_tbl(i);
    l_clev_tbl_in(i).Upg_Orig_System_Ref    :='OKS_COV_BILL_RATES_INT_ALL'; --'Migrated_BILL_RATES';
    l_clev_tbl_in(i).Upg_Orig_System_Ref_Id :=Coverage_Bill_Rate_ID_Tbl(i);
    l_clev_tbl_in(i).INVOICE_LINE_LEVEL_IND                  :=Null;
    l_clev_tbl_in(i).DPAS_RATING                             :=Null;
    l_clev_tbl_in(i).TEMPLATE_USED                            :=Null;
    l_clev_tbl_in(i).PRICE_TYPE                             :=Null;
 --   l_clev_tbl_in(i).UOM_CODE                                :=Null;
    l_clev_tbl_in(i).LINE_NUMBER                     		:='6';
    l_clev_tbl_in(i).TRN_CODE                                 :=Null;
    l_clev_tbl_in(i).HIDDEN_IND                               :=Null;
    l_clev_tbl_in(i).DATE_TERMINATED                        :=Null;
    l_clev_tbl_in(i).CLE_ID_RENEWED_TO                        :=Null;
    l_clev_tbl_in(i).CURRENCY_CODE_RENEWED                    :=Null;
    l_clev_tbl_in(i).PRICE_NEGOTIATED_RENEWED                 :=Null;
    l_clev_tbl_in(i).cle_id_renewed           :=NULL;
    l_clev_tbl_in(i).comments                 :=NULL;
    l_clev_tbl_in(i).price_unit               :=NULL;
    l_clev_tbl_in(i).price_unit_percent       :=NULL;
    l_clev_tbl_in(i).price_negotiated         :=NULL;
    l_clev_tbl_in(i).price_level_ind          :='N';
    l_clev_tbl_in(i).block23text              :=NULL;
        l_clev_tbl_in(i).program_application_id:= fnd_global.prog_appl_id;
        l_clev_tbl_in(i).program_id:= fnd_global.CONC_PROGRAM_ID;

    l_rgpv_tbl_in(i).cle_id		         := l_clev_tbl_in(i).Id;
    l_rgpv_tbl_in(i).sfwt_flag	         := 'N';
    l_rgpv_tbl_in(i).rgd_code	          := 'SVC_K';
    l_rgpv_tbl_in(i).rgp_type	          := 'KRG';
    l_rgpv_tbl_in(i).id                   := okc_p_util.raw_to_number(sys_guid());
    l_rgpv_tbl_in(i).CREATION_DATE        := sysdate;
    l_rgpv_tbl_in(i).CREATED_BY         := -1;
    l_rgpv_tbl_in(i).LAST_UPDATE_DATE   := sysdate;
    l_rgpv_tbl_in(i).LAST_UPDATED_BY    := -1;
    l_rgpv_tbl_in(i).LAST_UPDATE_LOGIN  := -1;
    l_rgpv_tbl_in(i).object_version_number        := 1;
    l_rgpv_tbl_in(i).dnz_chr_id         :=dnz_chr_id_tbl(i);
    l_rgpv_tbl_in(i).CHR_ID                                   :=Null;
    l_rgpv_tbl_in(i).PARENT_RGP_ID                            :=Null;
    l_rgpv_tbl_in(i).SAT_CODE                                 :=Null;
    l_rgpv_tbl_in(i).COMMENTS                                 :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE_CATEGORY                       :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE1                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE2                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE3                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE4                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE5                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE6                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE7                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE8                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE9                               :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE10                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE11                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE12                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE13                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE14                              :=Null;
	l_rgpv_tbl_in(i).ATTRIBUTE15                              :=Null;


  IF ((BILL_RATE_CODE_TBL(i) IS Not NULL)
   AND (Unit_Of_Measure_Code_Tbl(i) IS Not NULL))
THEN
   l_rulv_tbl_in(i).rgp_id	       	:= l_rgpv_tbl_in(i).id;
   l_rulv_tbl_in(i).sfwt_flag           := 'N';
   l_rulv_tbl_in(i).OBJECT1_ID1         := Null;
   l_rulv_tbl_in(i).OBJECT1_ID2         := Null;
   l_rulv_tbl_in(i).JTOT_OBJECT1_code  	:= Null;
   l_rulv_tbl_in(i).rule_information_category := 'RSL';
   l_rulv_tbl_in(i).rule_information1   := gettimeuom(Unit_Of_Measure_Code_Tbl(i));
   l_rulv_tbl_in(i).rule_information2	:= Flat_Rate_Tbl(i);
   l_rulv_tbl_in(i).rule_information3	:= Percent_Rate_Tbl(i);
   l_rulv_tbl_in(i).rule_information4	:= BILL_RATE_CODE_Tbl(i);
   l_rulv_tbl_in(i).std_template_yn           	:= 'N';
   l_rulv_tbl_in(i).warn_yn                   	:= 'N';
   l_rulv_tbl_in(i).dnz_chr_id                	:= dnz_chr_id_Tbl(i);
   l_rulv_tbl_in(i).id                      	:= okc_p_util.raw_to_number(sys_guid());
   l_rulv_tbl_in(i).CREATION_DATE        :=sysdate;
   l_rulv_tbl_in(i).CREATED_BY              	:= -1;
   l_rulv_tbl_in(i).LAST_UPDATE_DATE  := sysdate;
   l_rulv_tbl_in(i).LAST_UPDATED_BY    := -1;
   l_rulv_tbl_in(i).LAST_UPDATE_LOGIN:= -1;
   l_rulv_tbl_in(i).object_version_number  := 1;
   l_rulv_tbl_in(i).OBJECT2_ID1                              :=NULL;
   l_rulv_tbl_in(i).OBJECT3_ID1                              :=NULL;
   l_rulv_tbl_in(i).OBJECT2_ID2                              :=NULL;
   l_rulv_tbl_in(i).OBJECT3_ID2                              :=NULL;
   l_rulv_tbl_in(i).JTOT_OBJECT2_CODE                        :=NULL;
   l_rulv_tbl_in(i).JTOT_OBJECT3_CODE                        :=NULL;
   l_rulv_tbl_in(i).PRIORITY                                 :=NULL;
   l_rulv_tbl_in(i).COMMENTS                                 :=NULL;
   l_rulv_tbl_in(i).ATTRIBUTE_CATEGORY                       :=NULL;
   l_rulv_tbl_in(i).ATTRIBUTE1                               :=NULL;
   l_rulv_tbl_in(i).ATTRIBUTE2                               :=NULL;
   l_rulv_tbl_in(i).ATTRIBUTE3                               :=NULL;
   l_rulv_tbl_in(i).ATTRIBUTE4                               :=NULL;
   l_rulv_tbl_in(i).ATTRIBUTE5                               :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE6                               :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE7                               :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE8                               :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE9                               :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE10                              :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE11                              :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE12                              :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE13                              :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE14                              :=NULL;
l_rulv_tbl_in(i).ATTRIBUTE15                              :=NULL;
l_rulv_tbl_in(i).TEXT                                     :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION5                        :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION6                        :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION7                        :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION8                        :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION9                        :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION10                       :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION11                       :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION12                       :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION13                       :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION14                       :=NULL;
l_rulv_tbl_in(i).RULE_INFORMATION15                       :=NULL;
 end if;
end loop;
end if;
IF l_validate_flag = 'Y' THEN
	IF l_Clev_tbl_in.COUNT>0      	THEN
    	l_Error_Message := 'okc_cle_pvt';
         okc_cle_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_clev_tbl      =>    l_clev_tbl_in,
                                x_clev_tbl      =>    x_clev_tbl_in);
   	END IF;

	IF l_rgpv_tbl_in.COUNT>0      	THEN
   		l_Error_Message := 'okc_rgp_pvt';
        okc_rgp_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rgpv_tbl      =>    l_rgpv_tbl_in,
                                x_rgpv_tbl      =>    x_rgpv_tbl_in);
    END IF;

	IF l_rulv_tbl_in.COUNT>0      	THEN
    	l_Error_Message := 'okc_rul_pvt';
        okc_rul_pvt.Insert_Row(
                                p_api_version   =>  l_api_version,
                                p_init_msg_list =>    l_init_msg_list,
                                x_return_status =>    l_return_status ,
                                x_msg_count     =>    l_msg_count,
                                x_msg_data      =>    l_msg_data,
                                p_rulv_tbl      =>    l_rulv_tbl_in,
                                x_rulv_tbl      =>    x_rulv_tbl_in);

	END IF;


END IF;

IF l_validate_flag = 'N' THEN

		IF l_Clev_tbl_in.COUNT>0      THEN
				l_error_message := 'okc_cle_pvt -';
				okc_cle_pvt.Insert_Row_Upg( l_return_status , l_clev_tbl_in);
		END IF;
				l_Clev_tbl_in.DELETE;


		IF l_rgpv_tbl_in.COUNT>0      THEN
				l_error_message := 'okc_rgp_pvt -';
				okc_rgp_pvt.Insert_Row_Upg( l_return_status , l_rgpv_tbl_in);
		END IF;
				l_rgpv_tbl_in.DELETE;


		IF l_rulv_tbl_in.COUNT>0      THEN
				l_error_message := 'okc_rul_pvt -';
				okc_rul_pvt.Insert_Row_Upg( l_return_status , l_rulv_tbl_in);
		END IF;
				l_rulv_tbl_in.delete;

END IF;
        FORALL i in 1 .. COVERAGE_BILL_RATE_ID_tbl.COUNT

          UPDATE oks_cov_bill_rates_int_all
          SET    INTERFACED_STATUS_FLAG  = 'S',
                 LAST_UPDATED_BY         = -1,
                 LAST_UPDATE_DATE        = sysdate,
                 LAST_UPDATE_LOGIN       = -1
          WHERE  COVERAGE_BILL_RATE_ID = COVERAGE_BILL_RATE_ID_tbl(i);

          commit;

    exit when get_bill_rates_cur%notfound;
       EXCEPTION
       WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20000,'Error in Bill Rate Interface');
   END;

end loop;

IF  get_bill_rates_cur%ISOPEN
        THEN
           CLOSE get_bill_rates_cur;
        END IF;

end ;---Bill_Rates_Migrate

PROCEDURE Print_report      (   P_FromId        IN  NUMBER,
                                P_ToId          IN  NUMBER) IS


Cursor get_con_headers (p_from_id in NUMBER,p_to_id in NUMBER)
IS    SELECT contract_number,
           contract_id,
           interfaced_status_flag,
           batch_number
    FROM  OKS_CON_HEADERS_INT_ALL
    WHERE BATCH_NUMBER between p_from_id and p_to_id;

Cursor get_con_lines(p_id IN NUMBER)
IS     SELECT Contract_Id,
              Contract_line_id,
              Coverage_Id,
              Interfaced_status_flag
        FROM  OKS_CON_LINES_INT_ALL lines
        WHERE lines.contract_id = p_id;

Cursor get_coverages(p_id IN NUMBER)
IS      SELECT Coverage_id,
               NAME,
               Interfaced_status_flag
        FROM   OKS_COVERAGES_INT_ALL cov
        WHERE  cov.coverage_id = p_id;

Cursor get_Buss_Process (p_id in NUMBER)
IS      SELECT  Coverage_Bus_process_id,
                Business_process_id,
                Interfaced_Status_flag
        FROM    oks_cov_txn_groups_int_all txn
        WHERE   txn.coverage_id = p_id;

Cursor get_bill_types (p_id in NUMBER)
IS      SELECT  Interfaced_Status_flag,
                COV_BP_BILLING_TYPE_ID,
                Upto_amount,
                Percent_Cover
        FROM    oks_cov_bill_types_int_all
        WHERE   coverage_bus_process_id = p_id;

Cursor get_bill_rates (p_id in NUMBER)
IS      SELECT  Interfaced_Status_flag,
                COVERAGE_BILL_RATE_ID
        FROM    oks_cov_bill_rates_int_all
        WHERE   COVERAGE_BILLING_TYPE_ID = p_id;

BEGIN

for gen_con_head_rec in get_con_headers(p_fromid,p_toid) LOOP

fnd_file.new_line(FND_FILE.OUTPUT, 2);
fnd_file.new_line(FND_FILE.OUTPUT, 2);

fnd_file.put_line(FND_FILE.OUTPUT,'Batch Number   :'||gen_con_head_rec.batch_number);
fnd_file.put_line(FND_FILE.OUTPUT,'Contract Number:'||gen_con_head_rec.Contract_number);
fnd_file.put_line(FND_FILE.OUTPUT,'Migrated       :'||gen_con_head_rec.interfaced_status_flag);

    If gen_con_head_rec.interfaced_status_flag = 'S' THEN

        for gen_con_line_rec in get_con_lines(gen_con_head_rec.contract_id) LOOP

        fnd_file.put_line(FND_FILE.OUTPUT,'Service Line   :'||gen_con_line_rec.Contract_line_id);
        fnd_file.put_line(FND_FILE.OUTPUT,'Migrated       :'||gen_con_line_rec.interfaced_status_flag);

            If gen_con_line_rec.interfaced_status_flag = 'S' THEN

                for get_coverages_rec in get_coverages(gen_con_line_rec.coverage_id) Loop

                    fnd_file.put_line(FND_FILE.OUTPUT,'Coverage       :'||get_coverages_rec.NAME);
                    fnd_file.put_line(FND_FILE.OUTPUT,'Migrated       :'||get_coverages_rec.interfaced_status_flag);

                END LOOP;

            END IF;

        END LOOP;

    END IF;

END LOOP;

END; --Print_report


END OKS_COVERAGES_MIGRATION;


/
