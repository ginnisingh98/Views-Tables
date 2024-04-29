--------------------------------------------------------
--  DDL for Package Body OKS_INTEGRATION_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_INTEGRATION_UTIL_PUB" AS
/* $Header: OKSRIUTB.pls 120.2 2006/05/30 19:32:02 jvarghes noship $ */


-- Global constant for the maximum allowed sub-requests (parallel workers)
 MAX_JOBS		NUMBER := 20;

-- Global vars to hold the min and max hdr_id for each sub-request range
 type range_rec is record (
 	lo number,
	hi number,
	jobno number);
 type rangeArray is VARRAY(50) of range_rec;
 range_arr rangeArray;
 g_instance_id integer := 0;

FUNCTION get_instance_id
    return integer is
    cursor inst_csr is
       select instance_number from v$instance;
BEGIN
    IF g_instance_id = 0 THEN
       OPEN inst_csr;
       FETCH inst_csr into g_instance_id;
       CLOSE inst_csr;
    END IF;
    RETURN g_instance_id;
END;


/**************************************************************************
***   Function checks if a service line already exists in the order details
***************************************************************************/

Function Get_Order_Line_Id
(
     P_Order_Line_id  IN    NUMBER
)
Return Number
Is

            Cursor l_order_csr Is
                             Select Order_Line_Id1
                             From Oks_K_Order_Details
                             Where  Order_Line_Id1 = to_char(P_Order_Line_id);

            l_order_exists_rec           l_order_csr%rowtype;
Begin
            Open  l_order_csr;
            Fetch l_order_csr Into l_order_exists_rec;

		If l_order_csr%Notfound then
			Close l_order_csr;
			Return (Null);
 		End If;

            close l_order_csr;
		Return (l_order_exists_rec.Order_Line_Id1);

End Get_Order_Line_Id;


/**************************************************************************
***    procedure to populate the order details table with all the services
***    from okx_order_lines_v
***************************************************************************/

PROCEDURE Create_K_Order_Details
(
			p_header_id	  IN   NUMBER
,			x_return_status	  OUT NOCOPY  Varchar2
,                       x_msg_count       OUT  NOCOPY Number
,                       x_msg_data        OUT  NOCOPY Varchar2
)
IS



    -- Cursor to select the service items from order lines

    Cursor Order_Dtl_cur Is
            Select Id1, Id2, Service_End_Date
            From  okx_order_lines_v   ol
            Where ol.Header_id     = P_header_id
            And   ol.Service_reference_Type_Code IN ('CUSTOMER_PRODUCT','ORDER');

    -- Cursor to check if all other orders has to be linked with
    -- this order when apply all flag is set to 'Y'

    Cursor line_dtl_cur Is
             select order_line_id1, order_line_id2, line_renewal_type, renewal_type,
                    po_required_yn, renewal_pricing_type,markup_percent,billing_profile_id,
                    chr_id, cle_id, cod_type, cod_id, end_date,contact_id, email_id, phone_id, fax_id, site_id
                   ,renewal_approval_flag   --Bug# 5173373
             from   Oks_K_Order_Details
             where Link_Order_Header_ID = P_header_id
             And   APPLY_ALL_YN = 'Y';

    -- Cursor to check if all other orders has to be linked with
    -- this order when service end dates falls on the same day

    Cursor line_enddate_cur (l_ser_end_date date) Is
             select order_line_id1, order_line_id2, line_renewal_type, renewal_type,
                    po_required_yn, renewal_pricing_type,markup_percent,
                    chr_id, cle_id, cod_type, cod_id, end_date,contact_id, email_id, phone_id, fax_id, site_id
             from   Oks_K_Order_Details
             where Link_Order_Header_ID = P_header_id
             And   Cod_Type = 'NCT'
             And   trunc(end_date) = trunc(l_ser_end_date);

    -- Cursor to select all the contact lines for the service

    Cursor Order_contacts_cur (order_line_id VARCHAR2) Is
		 select Cro_Code, Jtot_Object_Code, Object1_Id1, Object1_Id2
		 from  oks_k_order_contacts_v
		 where  cod_id in (select id from Oks_K_Order_Details
				    where Order_Line_Id1 = order_line_id);

  line_dtl_rec                line_dtl_cur%rowtype;
  line_enddate_rec            line_enddate_cur%rowtype;
  order_contacts_rec          order_contacts_cur%rowtype;

  l_msg_count                 Number;
  l_msg_data                  Varchar2(2000);

  l_cocv_tbl_in               Oks_Coc_Pvt.cocv_tbl_type;
  l_cocv_tbl_out              Oks_Coc_Pvt.cocv_tbl_type;

  l_covd_tbl_in               Oks_Cod_Pvt.codv_tbl_type;
  l_covd_tbl_out              Oks_Cod_Pvt.codv_tbl_type;

  l_order_id                  Oks_K_Order_Details.order_line_id1%type;


  l_api_version		     CONSTANT	NUMBER	:= 1.0;
  l_init_msg_list	     CONSTANT	VARCHAR2(1) := OKC_API.G_FALSE;
  l_return_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_index		     VARCHAR2(2000);

  l_id1                      Number;
  l_id2                      VARCHAR2(40);
  l_ser_end_date             date;

BEGIN

  Open Order_Dtl_cur;

  Loop

    l_covd_tbl_in.delete;
    l_covd_tbl_out.delete;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    Fetch Order_Dtl_cur into l_id1, l_id2, l_ser_end_date;

    EXIT WHEN Order_Dtl_cur%NOTFOUND;

    l_order_id     := Get_Order_Line_Id (
                                    P_Order_Line_id => l_id1
                                   );

    If l_order_id Is Null Then


      --  check if any other service line exists for order header id


           l_covd_tbl_in(1).order_line_id1         := TO_CHAR(l_id1);
           l_covd_tbl_in(1).order_line_id2         := NVL(l_id2,'#');
           l_covd_tbl_in(1).link_order_header_id   := p_header_id;
           l_covd_tbl_in(1).end_date               := l_ser_end_date;
           l_covd_tbl_in(1).line_renewal_type      := 'FUL';
           l_covd_tbl_in(1).apply_all_yn           := 'N';

           Open  line_dtl_cur;
           Fetch line_dtl_cur Into line_dtl_rec;

           If line_dtl_cur%Notfound then
               l_covd_tbl_in(1).cod_type          := 'NCT';
               l_covd_tbl_in(1).apply_all_yn      := 'Y';

               -- End if;
               -- If the service end dates falls on the same day
	       -- then copy from the existing order line

/*  --commented for Extwarranty consolidation enhancement
    -- may 29-2002 vigandhi
	       If line_dtl_rec.end_date is NULL or
	       (trunc(line_dtl_rec.end_date) <> trunc(l_ser_end_date)) THEN

               Open  line_enddate_cur (l_ser_end_date);
               Fetch line_enddate_cur Into line_enddate_rec;

	       If line_enddate_cur%Notfound THEN
                   l_covd_tbl_in(1).cod_type          := 'NCT';
               ELSE
		   l_covd_tbl_in(1).cod_type             := 'LTO';
		   l_covd_tbl_in(1).link_ord_line_id1    := line_enddate_rec.Order_Line_Id1;
		   l_covd_tbl_in(1).link_ord_line_id2    := line_enddate_rec.Order_Line_Id2;
		   l_covd_tbl_in(1).renewal_type         := line_enddate_rec.renewal_type;
		   l_covd_tbl_in(1).po_required_yn       := line_enddate_rec.po_required_yn;
		   l_covd_tbl_in(1).renewal_pricing_type := line_enddate_rec.renewal_pricing_type;
		   l_covd_tbl_in(1).markup_percent       := line_enddate_rec.markup_percent;
		   l_covd_tbl_in(1).cod_id               := line_enddate_rec.cod_id;
		   l_covd_tbl_in(1).link_chr_id          := line_enddate_rec.chr_id;
		   l_covd_tbl_in(1).link_cle_id          := line_enddate_rec.cle_id;
		   l_covd_tbl_in(1).contact_id           := line_enddate_rec.contact_id;
		   l_covd_tbl_in(1).email_id             := line_enddate_rec.email_id;
		   l_covd_tbl_in(1).phone_id             := line_enddate_rec.phone_id;
		   l_covd_tbl_in(1).fax_id               := line_enddate_rec.fax_id;
		   l_covd_tbl_in(1).site_id              := line_enddate_rec.site_id;

               End if;

	       Close line_enddate_cur;
*/

            Else
	       l_covd_tbl_in(1).cod_type             := 'LTO';
	       l_covd_tbl_in(1).line_renewal_type    := line_dtl_rec.line_renewal_type; --mmadhavi added for bug 4339533
	       l_covd_tbl_in(1).link_ord_line_id1    := line_dtl_rec.Order_Line_Id1;
	       l_covd_tbl_in(1).link_ord_line_id2    := line_dtl_rec.Order_Line_Id2;
	       l_covd_tbl_in(1).renewal_type         := line_dtl_rec.renewal_type;
	       l_covd_tbl_in(1).renewal_approval_flag := line_dtl_rec.renewal_approval_flag;  -- Bug# 5173373
	       l_covd_tbl_in(1).po_required_yn       := line_dtl_rec.po_required_yn;
	       l_covd_tbl_in(1).renewal_pricing_type := line_dtl_rec.renewal_pricing_type;
	       l_covd_tbl_in(1).markup_percent       := line_dtl_rec.markup_percent;
	       l_covd_tbl_in(1).cod_id               := line_dtl_rec.cod_id;
	       l_covd_tbl_in(1).link_chr_id          := line_dtl_rec.chr_id;
	       l_covd_tbl_in(1).link_cle_id          := line_dtl_rec.cle_id;
	       l_covd_tbl_in(1).contact_id           := line_dtl_rec.contact_id;
	       l_covd_tbl_in(1).email_id             := line_dtl_rec.email_id;
	       l_covd_tbl_in(1).phone_id             := line_dtl_rec.phone_id;
	       l_covd_tbl_in(1).fax_id               := line_dtl_rec.fax_id;
	       l_covd_tbl_in(1).site_id              := line_dtl_rec.site_id;
	       l_covd_tbl_in(1).billing_profile_id   := line_dtl_rec.billing_profile_id;   -- New parameter added vigandhi(29-May2002)


 	    End If;

	    Close line_dtl_cur;

            oks_order_details_pub.Insert_order_Detail
            (
    	           p_api_version	=> l_api_version,
    	           p_init_msg_list	=> l_init_msg_list,
    	           x_return_status	=> l_return_status,
    	           x_msg_count		=> x_msg_count,
    	           x_msg_data		=> x_msg_data,
    	           p_codv_tbl		=> l_covd_tbl_in,
    	           x_codv_tbl		=> l_covd_tbl_out
             );


            If NOT l_return_status = 'S' then
		 Raise G_EXCEPTION_HALT_VALIDATION;
            End If;
             --Commit;

	    If l_covd_tbl_in(1).cod_type = 'LTO' THEN

	      For order_contacts_rec in order_contacts_cur (l_covd_tbl_in(1).link_ord_line_id1)
	      Loop
                l_cocv_tbl_in.delete;

		l_cocv_tbl_in(1).cod_id   := l_covd_tbl_out(1).id;
		l_cocv_tbl_in(1).cro_code := order_contacts_rec.cro_code;
		l_cocv_tbl_in(1).jtot_object_code := order_contacts_rec.jtot_object_code;
		l_cocv_tbl_in(1).object1_id1 := order_contacts_rec.object1_id1;
		l_cocv_tbl_in(1).object1_id2 := order_contacts_rec.object1_id2;

                oks_order_contacts_pub.Insert_order_contact
                (
    	                   p_api_version	=> l_api_version,
    	                   p_init_msg_list	=> l_init_msg_list,
    	                   x_return_status	=> l_return_status,
    	                   x_msg_count          => x_msg_count,
    	                   x_msg_data		=> x_msg_data,
    	                   p_cocv_tbl		=> l_cocv_tbl_in,
    	                   x_cocv_tbl		=> l_cocv_tbl_out
                );

                If NOT l_return_status = 'S' then
		    		 Raise G_EXCEPTION_HALT_VALIDATION;
                End If;
                --Commit;
	      End Loop; -- order contact loop

	    End if; --- for cod type 'LTO'
/*
            If l_return_status <> 'S' then
                OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'HEADER (HEADER)');
	        Raise G_EXCEPTION_HALT_VALIDATION;
             end if;
*/
    End If;

  End Loop;
  --Commit;
  Exception
	When  G_EXCEPTION_HALT_VALIDATION Then
		x_return_status := l_return_status;
		Null;
	When  Others Then
	      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   		OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END Create_K_Order_Details;



/*
 * Given the wrong date format and the date in that wrong format. This procduere will
 * update the oks_rules_b table with the correct date format. rule_informationX has to be
 * updated. X is the value of p_rule_num.
*/

PROCEDURE Convert_Dates(p_category_code IN VARCHAR2,
                        p_format        IN VARCHAR2,
                        p_date          IN VARCHAR2,
                        p_rule_num      IN NUMBER,
                        p_rule_id       IN NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER
                        ) IS
    l_day   VARCHAR2(30);
    l_month VARCHAR2(30);
    l_year  VARCHAR2(30);
    l_time  VARCHAR2(30) := '00:00:00';
    l_date  VARCHAR2(30);
Begin
    x_return_status  := OKC_API.G_RET_STS_SUCCESS;
    l_day := to_char(to_date(p_date, p_format), 'DD');
    l_month := to_char(to_date(p_date, p_format), 'MM');
    l_year := to_char(to_date(p_date, p_format), 'YYYY');
    l_date := l_year || '/' || l_month || '/' || l_day || ' ' || l_time;

    If p_rule_num = 2 then
        update okc_rules_b set
        rule_information2 = l_date
        ---where rule_information_category = p_category_code and rule_information2 = p_date;
        where id = p_rule_id;
    Elsif p_rule_num = 3 then
        update okc_rules_b set
        rule_information3 = l_date
        ---where rule_information_category = p_category_code and rule_information3 = p_date;
        where id = p_rule_id;
    Elsif p_rule_num = 4 then
        update okc_rules_b set
        rule_information4 = l_date
        ---where rule_information_category = p_category_code and rule_information4 = p_date;
        where id = p_rule_id;
    End if;
    commit;

    Exception
        when others then
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
          Debug_Log(p_error_msg => SQLERRM,
                    x_msg_data  => x_msg_data,
                    x_msg_count => x_msg_count,
                    x_return_status => x_return_status);

End Convert_Dates;


PROCEDURE Get_Dates(
				p_from_id    IN   Number,
                    p_to_id      IN   Number
				)
IS

TYPE V_ARRAY IS VARRAY(20) of VARCHAR2(20);
l_category_code1 V_ARRAY := V_ARRAY('CCR', 'CVN', 'IBR', 'RVE', 'SLL');
l_category_code2 V_ARRAY := V_ARRAY('REN', 'SBG');

l_format        V_ARRAY := V_ARRAY('DD-MON-YY', 'DD-MON-YYYY', 'DD MON, YYYY', 'DD MON, YY',
                                   'MM/DD/YYYY', 'MM/DD/YY', 'YYYY/DD/MM', 'DD MONTH, YYYY',
                                   'DD MONTH, YY', 'MM-DD-YY', 'MM-DD-YYYY', 'DD-MM-YY',
                                   'DD-MM-YYYY', 'DD-MONTH-YY', 'DD-MONTH-YYYY');
l_count_code NUMBER;
l_count_format NUMBER;
l_date         DATE;
l_num1          NUMBER;
x_return_status  varchar2(2);
x_msg_data      VARCHAR2(1950);
x_msg_count     NUMBER;


-- category can be: CCR, CVN, IBR, RVE, SLL
----CURSOR rule_info2(category VARCHAR2, format VARCHAR2) IS
CURSOR rule_info2(category VARCHAR2) IS
select id rul_id, rule_information2 rul2
from okc_rules_b
where rgp_id between p_from_id and p_to_id
and   rule_information_category  = category;

-----and length(rule_information2) = length(format);

-- category can be: REN, SBG
---CURSOR rule_info3_4(category VARCHAR2, format VARCHAR2) IS
CURSOR rule_info3_4(category VARCHAR2) IS
select id rul_id, rule_information3 rul3, rule_information4 rul4
from okc_rules_b
where rgp_id between p_from_id and p_to_id
and   rule_information_category  = category;

-----and length(rule_information3) = length(format) or length(rule_information4) = length(format);


Begin
 x_return_status  := OKC_API.G_RET_STS_SUCCESS;
 l_count_code := 1;
 While(l_count_code <= l_category_code1.COUNT) Loop
    l_count_format := 1;
    While(l_count_format <= l_format.COUNT) Loop
        -----for ruleInfo2 in rule_info2(l_category_code1(l_count_code), l_format(l_count_format)) Loop
        for ruleInfo2 in rule_info2(l_category_code1(l_count_code)) Loop
            begin
              l_date := to_date(ruleInfo2.rul2, l_format(l_count_format) );
              if ( ruleInfo2.rul2 = to_char(l_date, l_format(l_count_format) )  ) then
                  Convert_Dates(p_category_code => l_category_code1(l_count_code),
                        p_format => l_format(l_count_format),
                        p_date   => ruleInfo2.rul2,
                        p_rule_num => 2,
				    p_rule_id  => ruleInfo2.rul_id,
                        x_return_status => x_return_status,
                        x_msg_data      => x_msg_data,
                        x_msg_count => x_msg_count);
              End If;
               Exception
                 When Others Then
                   null;
                   -- no need to record any error messages here. This part is when the
                   -- date does not match the date format when calling to_date.
             End;
        End Loop;
        l_count_format := l_count_format + 1;
    End Loop;
    l_count_code := l_count_code + 1;
 End Loop;

 l_count_code := 1;
 While(l_count_code <= l_category_code2.COUNT) Loop
    l_count_format := 1;
    While(l_count_format <= l_format.COUNT) Loop
        -----for ruleInfo3 in rule_info3_4(l_category_code2(l_count_code), l_format(l_count_format)) Loop
        for ruleInfo3 in rule_info3_4(l_category_code2(l_count_code)) Loop
            begin
              l_date := to_date(ruleInfo3.rul3, l_format(l_count_format));
              if ( ruleInfo3.rul3 = to_char(l_date, l_format(l_count_format) )  ) then
                Convert_Dates(p_category_code => l_category_code2(l_count_code),
                        p_format => l_format(l_count_format),
                        p_date   => ruleInfo3.rul3,
                        p_rule_num => 3,
				    p_rule_id  => ruleInfo3.rul_id,
                        x_return_status => x_return_status,
                        x_msg_data      => x_msg_data,
                        x_msg_count => x_msg_count);
              End If;
              if ( ruleInfo3.rul4 = to_char(l_date, l_format(l_count_format) )  ) then
                Convert_Dates(p_category_code => l_category_code2(l_count_code),
                        p_format => l_format(l_count_format),
                        p_date   => ruleInfo3.rul4,
                        p_rule_num => 4,
				    p_rule_id  => ruleInfo3.rul_id,
                        x_return_status => x_return_status,
                        x_msg_data      => x_msg_data,
                        x_msg_count => x_msg_count);
              End If;

               Exception
                    When Others Then
                    null;
                    -- no need to record any error messages here. This part is when the
                   -- date does not match the date format when calling to_date.
             End;
        End Loop;
        l_count_format := l_count_format + 1;
    End Loop;
    l_count_code := l_count_code + 1;
 End Loop;
 commit;
 Exception
   When others then
     x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
     Debug_Log(p_error_msg => SQLERRM,
                    x_msg_data  => x_msg_data,
                    x_msg_count => x_msg_count,
                    x_return_status => x_return_status);

End Get_Dates;


Procedure Debug_Log(p_error_msg           IN VARCHAR2,
                    x_msg_data            OUT NOCOPY VARCHAR2,
                    x_msg_count           OUT NOCOPY NUMBER,
                    x_return_status       OUT NOCOPY VARCHAR2) IS

    l_file_name     VARCHAR2(200);
    l_file_loc      BFILE;
    l_file_type     utl_file.file_type;
    l_location      VARCHAR2(32000);
    l_comma_loc     NUMBER;
    l_error_msg     VARCHAR2(32000) := p_error_msg;

    cursor get_dir is
    select value
    from v$parameter
    where name = 'utl_file_dir';

    Begin
        x_return_status  := OKC_API.G_RET_STS_SUCCESS;

        --If FND_PROFILE.VALUE('OKS_DEBUG') = 'Y' Then

            l_file_name := 'ERM_' || to_char(sysdate, 'MM/DD/YYYY_HH24:MI:SS') || '_'
            || '.out';

            Open get_dir;
            Fetch get_dir into l_location;
            Close get_dir;

            If l_location is not null Then
                l_comma_loc := instr(l_location, ',');
                If l_comma_loc <> 0 Then
                    l_location := substr(l_location, 1, l_comma_loc - 1);
                End If;
            End If;

            l_file_type := utl_file.fopen(location  => l_location,
                                          filename  => l_file_name,
                                          open_mode => 'a');

            utl_file.put_line(file    => l_file_type,
                              buffer  => l_error_msg );

            utl_file.fflush(file  => l_file_type);
            utl_file.fclose(l_file_type);
       -- End If;

     Exception
       when utl_file.INVALID_PATH then
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
              x_msg_data := l_error_msg || ' Invalid Path';
              x_msg_count:= 1;
              OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               'Invalid path'
              );
       when utl_file.INVALID_OPERATION then
             x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             x_msg_data := l_error_msg || ' Invalid operation';
             x_msg_count:= 1;
             OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               'Invalid operation'
              );

       when others then
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            x_msg_data := l_error_msg || ' ' || SQLERRM;
            x_msg_count:= 1;
            OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               SQLERRM
              );

    End Debug_Log;


procedure split_range (
  p_lo number,
  p_hi number,
  p_buckets number) is
  l_lo number := p_lo;
  l_idx1 number := range_arr.count + 1;
  l_idx2 number := range_arr.count + p_buckets;
  l_bucket_width integer;
begin
  if p_buckets = 0 then
	return;
  end if;
  if range_arr.count > 0 then
	-- so we don't overlap high value of previous range
	l_lo := p_lo + 1;
  end if;

  l_bucket_width := (p_hi - l_lo) / p_buckets;

  range_arr.extend(p_buckets);
  for idx in l_idx1..l_idx2 loop
	range_arr(idx).lo := l_lo + ((idx - l_idx1) * l_bucket_width);
	if idx < l_idx2 then
		range_arr(idx).hi := range_arr(idx).lo + l_bucket_width -1;
	else
		range_arr(idx).hi := p_hi;
	end if;
  end loop;

end split_range;


function generate_ranges (
	p_lo number,
	p_hi number,
	p_avg number,
	p_stddev number,
	p_total number) return integer is
	l_total_buckets integer := 0;

	l_stdlo number := greatest(round(p_avg - p_stddev), p_lo);
	l_stdhi number := least(round(p_avg + p_stddev), p_hi);
	l_stddev_percent number := 0.66;  -- the area covered by +/-1 stddev
	l_outlier_buckets integer := 0;
	l_std_buckets integer := 0;
	l_lo_buckets integer := 0;
	l_hi_buckets integer := 0;
	l_outlier_entries_per_bucket number := 0;
	modidx integer;

begin
	range_arr := rangeArray();
	-- number of buckets is set to 20
	l_total_buckets := least(MAX_JOBS,p_hi - p_lo);

	l_outlier_buckets := l_total_buckets * (1 - l_stddev_percent);
	if l_outlier_buckets > 0 then
	   l_outlier_entries_per_bucket := p_total * (1 - l_stddev_percent)
					/ l_outlier_buckets ;
	end if;
	for idx in 1..l_outlier_buckets loop
		modidx := mod(idx,2);
		-- alternate assignment between hi and lo buckets
		if modidx = 1
		   AND (p_hi - (l_hi_buckets+1) * l_outlier_entries_per_bucket)
		   > l_stdhi then
			-- allocate buckets for positive outliers
			l_hi_buckets := l_hi_buckets + 1;
		elsif modidx = 0
		   AND (p_lo + (l_lo_buckets+1) * l_outlier_entries_per_bucket)
		   < l_stdlo then
			-- allocate buckets for negative outliers
			l_lo_buckets := l_lo_buckets + 1;
		-- else min or max has been consumed, save bucket for middle
		end if;
	end loop;

	-- compute middle buckets
	l_std_buckets := l_total_buckets - l_lo_buckets - l_hi_buckets;

	-- in case low-high allocations yielded zero buckets.
	-- i.e., outliers were folded into middle buckets.
	if l_lo_buckets = 0 then
		l_stdlo := p_lo;
	end if;
	if l_hi_buckets = 0 then
		l_stdhi := p_hi;
	end if;


	-- ranges for negative outliers
	split_range(p_lo, l_stdlo, l_lo_buckets);
	-- ranges for +/-1 stddev from mean
	split_range(l_stdlo, l_stdhi, l_std_buckets);
	-- ranges for positive outliers
	split_range(l_stdhi, p_hi, l_hi_buckets);

	return l_total_buckets;
end generate_ranges;


PROCEDURE upgrade_rule_dates
(
 x_return_status            OUT NOCOPY VARCHAR2
)
IS

cursor l_csp_agg_csr is
  select min(id) minid, max(id) maxid,
         count(id) total,
	 avg(id) avgid, stddev(id) stdid
  from   okc_rule_groups_b
  where  rgd_code = 'SVC_K';

cursor l_jobs_csr(l_job number) is
  select count(*)
  from   user_jobs
  where  job = l_job;

l_agg_rec l_csp_agg_csr%ROWTYPE;
l_subrequests integer;
l_ret integer;
l_job_count integer := 0;

BEGIN
   X_return_status := 'S';

   open l_csp_agg_csr;
   fetch l_csp_agg_csr into l_agg_rec;
   close l_csp_agg_csr;

   -- populate lo,hi varrays
   l_subrequests :=
   generate_ranges(l_agg_rec.minid, l_agg_rec.maxid, l_agg_rec.avgid,
                   l_agg_rec.stdid, l_agg_rec.total);

   for idx in 1..l_subrequests loop

   ----errorout('1  range '||range_arr(idx).lo||'hi '||range_arr(idx).hi);
       dbms_job.submit(range_arr(idx).jobno,
                       'OKS_INTEGRATION_UTIL_PUB.get_dates(' ||
                       range_arr(idx).lo ||','|| range_arr(idx).hi ||');',
                       instance => get_instance_id);
       commit;

   end loop;

   loop
       for idx in 1..l_subrequests loop
           open l_jobs_csr(range_arr(idx).jobno);
           fetch l_jobs_csr into l_job_count;
           close l_jobs_csr;
           if l_job_count > 0 then
              exit;
           end if;
       end loop;
       if l_job_count > 0 then
          dbms_lock.sleep(60);
       else
          exit;
       end if;
   end loop;


EXCEPTION
       WHEN OTHERS THEN
		---errorout('spawn jobs '||sqlerrm);
        --dbms_output.put_line(SQLERRM);
                X_return_status := 'E';

END upgrade_rule_dates;




END OKS_INTEGRATION_UTIL_PUB;

/
