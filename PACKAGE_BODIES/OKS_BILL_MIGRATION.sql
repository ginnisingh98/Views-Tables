--------------------------------------------------------
--  DDL for Package Body OKS_BILL_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BILL_MIGRATION" AS
/* $Header: OKSBMIGB.pls 120.1 2005/10/03 07:52:21 upillai noship $ */


  G_DESCRIPTIVE_FLEXFIELD_NAME CONSTANT VARCHAR2(200) := 'OKC Rule Developer DF';
  G_DF_COUNT                   CONSTANT NUMBER(2)     := 15;

-- Global vars to hold the min and max hdr_id for each sub-request range
 type range_rec is record (
 	lo number,
	hi number,
	jobno number);
 type rangeArray is VARRAY(50) of range_rec;
 range_arr rangeArray;
 g_instance_id integer := 0;
--------------------------------------------------------------------------------
-------------- Global Varibale declarations for Rules Migration ----------------
--------------------------------------------------------------------------------
-- Global constant for the threshold count before splitting into sub-requests
         MAX_SINGLE_REQUEST	NUMBER := 500;

-- Global constant for the maximum allowed sub-requests (parallel workers)
         MAX_JOBS		NUMBER := 30;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--             Generate Range and Split Function.                                         --
--------------------------------------------------------------------------------------------

procedure split_range (
 p_lo number,
 p_hi number,
 p_buckets number) is
 -- splits range (p_lo=>p_hi) into p_buckets pieces and appends to VArrays.
 l_lo number := p_lo;
 l_idx1 number := range_arr.count + 1;
 l_idx2 number := range_arr.count + p_buckets;
 l_bucket_width integer;
begin
  If p_buckets = 0 then
     return;
  End if;

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
	l_total_buckets := MAX_JOBS;

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


/***********************function generate_ranges (
     p_lo  IN number,
     p_hi  IN number,
     p_avg In number,
     p_stddev IN number,
     p_total  IN number,
     p_sub_requests IN number) return integer is

 l_total_buckets integer := 0;
 l_stdlo number := greatest(round(p_avg - p_stddev), p_lo);
 l_stdhi number := least(round(p_avg + p_stddev), p_hi);
 l_stddev_percent number   := 0.66;  -- the area covered by +/-1 stddev
 l_outlier_buckets integer := 0;
 l_std_buckets integer     := 0;
 l_lo_buckets integer      := 0;
 l_hi_buckets integer      := 0;
 l_outlier_entries_per_bucket number := 0;
 modidx integer;
begin
  range_arr := rangeArray();

  l_total_buckets := greatest(nvl(p_sub_requests,3), least(p_total/MAX_SINGLE_REQUEST, MAX_JOBS));

  l_outlier_buckets := l_total_buckets * (1 - l_stddev_percent);
  if l_outlier_buckets > 0 then
     l_outlier_entries_per_bucket := p_total * (1 - l_stddev_percent)
                                                  / l_outlier_buckets ;
  end if;

  for idx in 1..l_outlier_buckets
  loop
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
end generate_ranges;***************/




-----------------------------------------------------------------------------------

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


PROCEDURE update_lvl_elements
     (
       p_lvl_element_tbl      IN  oks_bill_level_elements_pvt.letv_tbl_type
      ,x_lvl_element_tbl      OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type
      ,x_return_status        OUT NOCOPY Varchar2
      ,x_msg_count            OUT NOCOPY Number
      ,x_msg_data             OUT NOCOPY Varchar2
     )
IS
     l_lvl_element_tbl_in     oks_bill_level_elements_pvt.letv_tbl_type;
     l_lvl_element_tbl_out    oks_bill_level_elements_pvt.letv_tbl_type;
     l_api_version            CONSTANT NUMBER     	:= 1.0;
     l_init_msg_list          CONSTANT VARCHAR2(1) := OKC_API.G_FALSE;
     l_return_status	      VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_index                  NUMBER;
     l_module                 VARCHAR2(50) := 'TBL_RULE.CREATE_ROWS';
     l_debug                  BOOLEAN      := TRUE;


BEGIN
  x_return_status := l_return_status;
END update_lvl_elements;


  FUNCTION Create_Timevalue (p_chr_id IN NUMBER,p_start_date IN DATE) RETURN NUMBER Is
    l_p_tavv_tbl     OKC_TIME_PUB.TAVV_TBL_TYPE;
    l_x_tavv_tbl     OKC_TIME_PUB.TAVV_TBL_TYPE;
    l_api_version    Number := 1.0;
    l_init_msg_list  Varchar2(1) := 'T';
    l_return_status  varchar2(200);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
  Begin
return(null);
  End Create_Timevalue;


PROCEDURE BILL_UPGRADATION_ALL
(
 x_return_status            OUT NOCOPY VARCHAR2
)
IS

cursor l_header_agg_csr is
  select min(id) minid, max(id) maxid, count(*) total,
	 avg(id) avgid, stddev(id) stdid
  from   okc_statuses_b  sta,
	    okc_k_headers_b hdr
  where  hdr.id not in (-2,-1)
  and    sta.ste_code not in ('TERMINATED','ENTERED','CANCELLED')
  and    sta.code =    hdr.sts_code
  and    hdr.scs_code in ('SERVICE','WARRANTY');

cursor l_jobs_csr(l_job number) is
  select count(*)
  from   user_jobs
  where  job = l_job;

---------------------------------------------------------------------
--Newly added cursor to check whether migration has already happened.
---------------------------------------------------------------------
cursor l_check_mig_csr is
  SELECT   'x'
    FROM OKS_STREAM_LEVELS_B;



l_agg_rec l_header_agg_csr%ROWTYPE;
l_subrequests integer;
l_ret integer;
l_job_count integer := 0;
l_dummy varchar2(10);

BEGIN
   X_return_status := 'S';
   --------------------------------------------------------------------
   --The following cursor added to check whether migration has occured.
   --------------------------------------------------------------------
   open l_check_mig_csr ;
   fetch l_check_mig_csr into l_dummy;
   If l_check_mig_csr%FOUND then
      return;
   else
      close l_check_mig_csr;
   end if;


   open l_header_agg_csr;
   fetch l_header_agg_csr into l_agg_rec;
   close l_header_agg_csr;

   -- populate lo,hi varrays
   l_subrequests :=
   generate_ranges(l_agg_rec.minid, l_agg_rec.maxid, l_agg_rec.avgid,
                   l_agg_rec.stdid, l_agg_rec.total);

   for idx in 1..l_subrequests loop
       dbms_job.submit(range_arr(idx).jobno,
                       'OKS_BILL_MIGRATION.BILL_UPGRADATION(' ||
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
		---dbms_output.put_line(sqlerrm);
                X_return_status := 'E';

END BILL_UPGRADATION_ALL;


PROCEDURE BILL_UPGRADATION_ALL_OM
(
 x_return_status            OUT NOCOPY VARCHAR2
)
IS

cursor l_header_agg_csr is
  select min(id) minid, max(id) maxid, count(*) total,
	 avg(id) avgid, stddev(id) stdid
  from   okc_statuses_b  sta,
	    okc_k_headers_b hdr
  where  hdr.id not in (-2,-1)
  and    sta.ste_code not in ('TERMINATED','ENTERED','CANCELLED')
  and    sta.code =    hdr.sts_code
  and    hdr.scs_code = 'WARRANTY';
  ----and    hdr.scs_code in ('SERVICE','WARRANTY');

cursor l_jobs_csr(l_job number) is
  select count(*)
  from   user_jobs
  where  job = l_job;

cursor l_check_mig_csr is
select 'x'
  FROM okc_k_lines_b lines
 where lines.lse_id = 19
   and (  exists ( select 1 from okc_k_rel_objs rel
                    where rel.cle_id = lines.id )
          or
          exists ( select 1 from okc_k_rel_objs rel2 ,
                                 okc_k_lines_b line2
                    where line2.cle_id = lines.id
                      and rel2.cle_id = line2.id
                      and line2.lse_id = 25 )
         )
   AND EXISTS
       (SELECT 1 FROM OKS_BILL_CONT_LINES BCL
         WHERE BCL.CLE_ID = LINES.ID );

l_agg_rec l_header_agg_csr%ROWTYPE;
l_subrequests integer;
l_ret integer;
l_job_count integer := 0;
l_dummy varchar2(10);

BEGIN
--dbms_output.put_line('The start Time =  '|| to_char(sysdate , 'dd-mm-yy-hh:mi:ss'));

   X_return_status := 'S';
   open l_check_mig_csr ;
   fetch l_check_mig_csr into l_dummy;
   if l_check_mig_csr%FOUND then
      return;
   end if;
   close l_check_mig_csr;

   open l_header_agg_csr;
   fetch l_header_agg_csr into l_agg_rec;
   close l_header_agg_csr;

   -- populate lo,hi varrays
   l_subrequests :=
   generate_ranges(l_agg_rec.minid, l_agg_rec.maxid, l_agg_rec.avgid,
                   l_agg_rec.stdid, l_agg_rec.total);

   for idx in 1..l_subrequests loop
       dbms_job.submit(range_arr(idx).jobno,
                       'OKS_BILL_MIGRATION.BILL_UPGRADATION_OM(' ||
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
--dbms_output.put_line('The start Time =  '|| to_char(sysdate , 'dd-mm-yy-hh:mi:ss'));


EXCEPTION
       WHEN OTHERS THEN
		---dbms_output.put_line(sqlerrm);
                X_return_status := 'E';

END BILL_UPGRADATION_ALL_OM;


PROCEDURE Update_Line_Numbers
(
 p_chr_id_lo                 IN NUMBER DEFAULT NULL,
 p_chr_id_hi                 IN NUMBER DEFAULT NULL
)
IS

BEGIN
 null;
END Update_Line_Numbers;

PROCEDURE migrate_line_numbers
(
 x_return_status            OUT NOCOPY VARCHAR2
)
IS
Begin
 null;
END migrate_Line_Numbers;



Procedure MIGRATE_CURRENCY
IS
--- Global Constants -- this will be moved to package header
  G_RET_STS_SUCCESS		        CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		        CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_ERROR;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_APP_NAME			        CONSTANT VARCHAR2(3)   :=  'OKS';

Cursor l_contract_csr IS
Select  hdr.ID
	,hdr.CONTRACT_NUMBER
	,hdr.CURRENCY_CODE
	,hdr.AUTHORING_ORG_ID
From OKC_K_HEADERS_B hdr
Where exists (Select 1
              From okc_k_lines_b ln
                  ,oks_bill_cont_lines bcl
              Where hdr.id = ln.dnz_chr_id
                and ln.id = bcl.cle_id );

Cursor l_bill_lines_csr(p_dnz_chr_id Number) IS
Select bcl.ID BclID
    ,bcl.BTN_ID BtnID
    ,bcl.CLE_ID LineID
    ,bcl.AMOUNT Amount
    ,bcl.CURRENCY_CODE
From OKS_BILL_CONT_LINES bcl
    ,OKC_K_LINES_B kln
Where kln.DNZ_CHR_ID    = p_dnz_chr_id
  and bcl.CLE_ID        = kln.ID
  and bcl.BTN_ID is Null
  and bcl.BILL_ACTION   = 'RI' for update;

Cursor l_rule_info_csr(p_dnz_chr_id Number) IS
   Select rul.Rule_Information1 ConvRate
        ,to_date(rul.rule_information2,'YYYY/MM/DD HH24:MI:SS') ConvDate
        ,rul.rule_information3 EuroRate
        ,rul.jtot_object1_code ConvTypeCode
        ,con.NAME ConvType
    From OKX_CONVERSION_TYPES_V con
         ,OKC_RULES_B rul
         ,OKC_RULE_GROUPS_B rgp
    Where  rgp.DNZ_CHR_ID = p_dnz_chr_id
       and rul.Rgp_Id     = rgp.Id
       and rul.RULE_INFORMATION_CATEGORY = 'CVN'
       and con.ID1 = rul.OBJECT1_ID1;

l_cont_rec l_contract_csr%rowtype ;
l_bill_line_rec l_bill_lines_csr%rowtype ;
l_rule_info_rec l_rule_info_csr%rowtype ;

l_migration_req Varchar2(1) ;
l_euro_code     Varchar2(15);
l_euro_amount   Number;
l_conversion_rate Number ;
x_return_status Varchar2(10);
BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    DBMS_TRANSACTION.SAVEPOINT('MAIN');
    -- Setting OKC Context
    okc_context.set_okc_org_context;

    -- Open the contract cursor
    Open l_contract_csr ;
    Loop
        Fetch l_contract_csr into l_cont_rec ;
        Exit when  l_contract_csr%NotFound;

        DBMS_TRANSACTION.SAVEPOINT('CONTRACT_LINE');

        -- Update currency code for all bill cont lines for this contract -BTN ID not null
         Begin
            --dbms_output.put_line('Before Updating the bill cont lines for  Contract'||l_cont_rec.ID) ;

           Update OKS_BILL_CONT_LINES
             Set CURRENCY_CODE = l_cont_rec.CURRENCY_CODE
             Where CLE_ID in (select kln.ID
                           from OKC_K_LINES_B kln
                           Where kln.DNZ_CHR_ID  = l_cont_rec.ID )
               And BTN_ID  is Not Null;



           Exception When Others then
               DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('CONTRACT_LINE');
         End ;

         -- Call OKC API to find the contract requires migration or not
        l_migration_req  := OKC_CURRENCY_API.IS_EURO_CONVERSION_NEEDED(l_cont_rec.CURRENCY_CODE) ;



        If l_migration_req = 'Y' then
               -- Get Conversion Date and Rate for contract
               Open l_rule_info_csr(l_cont_rec.ID) ;
                  Fetch l_rule_info_csr into l_rule_info_rec ;

               -- Get Euro currency code
               l_euro_code := OKC_CURRENCY_API.GET_EURO_CURRENCY_CODE(l_cont_rec.CURRENCY_CODE) ;
               -- dbms_output.put_line('After Getting the Euro Curr for  Contract '||l_euro_code) ;

            -- Update Euro currency code and Euro Amount for all bill cont lines with  BTN ID  Null
            Open l_bill_lines_csr(l_cont_rec.ID) ;
            Loop
                Fetch l_bill_lines_csr into l_bill_line_rec ;
                Exit When l_bill_lines_csr%NotFound ;

                -- Get the Euro converted amount for bill cont line
                l_conversion_rate := l_rule_info_rec.ConvRate ;
                -- l_bill_line_rec.Amount is Not Null
                --   and
                If   ( l_rule_info_rec.ConvType is Not Null
                   and l_rule_info_rec.ConvRate is Not Null )
                   then
                       OKC_CURRENCY_API.CONVERT_AMOUNT ( p_FROM_CURRENCY     => l_cont_rec.CURRENCY_CODE
				                                ,p_TO_CURRENCY       => l_euro_code
				                                ,p_CONVERSION_DATE   => l_rule_info_rec.ConvDate
				                                ,p_CONVERSION_TYPE   => l_rule_info_rec.ConvType
				                                ,p_AMOUNT            => l_bill_line_rec.Amount
				                                ,x_CONVERSION_RATE   => l_conversion_rate
				                                ,x_CONVERTED_AMOUNT  => l_euro_amount);

                    -- Update Bill Cont Lines with Euro Amount
                    Begin
                          --dbms_output.put_line('Before Updating Converted amount '||l_bill_line_rec.BclID) ;
                        Update OKS_BILL_CONT_LINES
                          Set CURRENCY_CODE = l_euro_code
                             ,AMOUNT       = l_euro_amount
                        Where ID = l_bill_line_rec.BclID ;
                          --dbms_output.put_line('After  Updating Converted amount '||l_bill_line_rec.BclID) ;

                    Exception When Others then
                        DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('CONTRACT_LINE');
                    End ;

               End If; -- Conversion type and conversion rate

            End Loop ;

                 -- dbms_output.put_line('After  After Final Commit for contract  '||l_cont_rec.ID) ;
            Close l_bill_lines_csr ;

         Else -- if migration is not required, update currency code for this for lines with BTN id Null

              -- Update currency code for all bill cont lines for this contract -- BTN ID null
            Begin
                 --dbms_output.put_line('Before Updating the bill cont lines for  Contract- BTN ID null'||l_cont_rec.ID) ;

               Update OKS_BILL_CONT_LINES
                 Set CURRENCY_CODE = l_cont_rec.CURRENCY_CODE
                 Where CLE_ID in (select kln.ID
                              from OKC_K_LINES_B kln
                              Where kln.DNZ_CHR_ID  = l_cont_rec.ID )
                  And BTN_ID  is Null;

                  -- dbms_output.put_line('After Updating the bill cont lines for Contract- BTN ID null'||l_cont_rec.ID) ;
                Exception When Others then
                  DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('CONTRACT_LINE');
             End ;

        End If; -- migration req

        ---Commit ;
    End Loop ; -- Contract cursor
    Close l_contract_csr ;

               --dbms_output.put_line('Currency migration program has completed with NO errors ') ;
EXCEPTION
    WHEN Others THEN
       DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('MAIN');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.SET_MESSAGE
   	  (   p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
          );
END; -- Procedure MIGRATE_CURRENCY

PROCEDURE one_time_billing
(
p_invoice_rule_id                    NUMBER,
p_cle_id                             NUMBER,
x_return_status           OUT NOCOPY VARCHAR2
)
IS
        l_lvl_element_tbl_in       oks_bill_level_elements_pvt.letv_tbl_type;
        l_lvl_element_tbl_out      oks_bill_level_elements_pvt.letv_tbl_type;
        l_SLL_tbl_type             OKS_BILL_SCH.StreamLvl_tbl; --stream_lvl_tbl;
        l_bil_sch_out_tbl          OKS_BILL_SCH.ItemBillSch_tbl; --item_bill_sch_tbl;
        l_lvl_element_tbl          oks_bill_level_elements_pvt.letv_tbl_type;
        l_bill_cont_tbl            OKS_BILL_MIGRATION.bill_cont_tbl;
        l_bill_sub_tbl             OKS_BILL_MIGRATION.bill_cont_tbl;

	l_rule_id		   NUMBER := 0;
        l_start_date		   DATE;
        l_end_date		   DATE;
	l_duration		   NUMBER := 0;
	l_time  	 	   VARCHAR2(450) ;
	l_return_status 	   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	l_ctr			   NUMBER := 0;
	l_tbl_ctr		   NUMBER := 0;
        l_invoice_rule_id          NUMBER :=0;
	l_lvl_rec_ctr		   NUMBER := 0;
	l_bill_count		   NUMBER := 0;
	l_bill_ctr		   NUMBER := 0;
	l_lvl_ctr		   NUMBER := 0;
	l_lvl_count		   NUMBER := 0;
	l_lvl_sum		   NUMBER := 0;
	l_bill_sum		   NUMBER := 0;
        l_msg_data		   VARCHAR2(2000);
        l_msg_count                NUMBER:=0;
        l_diff		           NUMBER :=0;
        l_flag                     VARCHAR2(1);
        l_max_date_billed_to       DATE:= NULL;


CURSOR top_line_grp_csr (p_cle_id NUMBER) IS
       SELECT 	lines.id,lines.lse_id lse_id,lines.cle_id,lines.dnz_chr_id,
		lines.start_date,NVL(lines.date_terminated,lines.end_date) end_date,
                lines.date_terminated,
		rgp.id rgp_id
       FROM 	okc_k_lines_b lines,okc_rule_groups_b rgp
       WHERE	lines.dnz_chr_id = rgp.dnz_chr_id
       AND	lines.id = rgp.cle_id
       AND	lines.lse_id IN (1,12,19)
       and      lines.id = p_cle_id;

--Lines and group information

CURSOR line_grp_csr (p_cle_id NUMBER) IS
       SELECT 	lines.id,lines.lse_id lse_id,lines.cle_id,lines.dnz_chr_id,
	 	lines.start_date,NVL(lines.date_terminated,lines.end_date) end_date,
                lines.date_terminated
       FROM 	okc_k_lines_b lines
       WHERE	lines.cle_id = p_cle_id
       AND	lines.lse_id in (7,8,9,10,11,13,18,25,35);


--Rule information

CURSOR rules_csr (p_rgp_id NUMBER) IS
       SELECT	a.id,a.object1_id1,a.object2_id1,
              	a.object3_id1,a.jtot_object1_code,a.jtot_object2_code,
	        a.rule_information_category,
		a.rule_information1,a.rule_information2,
		a.rule_information3,a.rule_information4,
		a.rule_information5,a.rule_information6,
		a.rule_information7,a.rule_information8,
                a.created_by,a.creation_date,a.last_updated_by,a.last_update_date,
                a.last_update_login
       FROM	okc_rules_b a
       WHERE	a.rule_information_category = 'SBG'
       AND	a.rgp_id = p_rgp_id;


--Bill cont lines
CURSOR bill_cont_csr (p_cle_id NUMBER) IS
       SELECT   cle_id,
                amount
       FROM     oks_bill_cont_lines
       WHERE    cle_id = p_cle_id
       AND      bill_action = 'RI';

--Bill sub lines
CURSOR bill_sub_csr (p_cle_id NUMBER) IS
       SELECT   cle_id,
                amount
       FROM     oks_bill_sub_lines
       WHERE    cle_id = p_cle_id;



--Level element information

CURSOR level_elements_csr (p_id NUMBER) IS
       SELECT	lvl.id id, lvl.sequence_number sequence_number,
                lvl.date_start date_start, lvl.amount amount,
                lvl.date_completed date_completed
       FROM	oks_level_elements lvl,oks_stream_levels_b rule
       WHERE	lvl.rul_id = rule.id
       AND      rule.cle_id = p_id
       ORDER BY lvl.date_start;


BEGIN
--initialize status
    x_return_status	 := l_return_status;

    FOR top_line_grp_rec IN top_line_grp_csr (p_cle_id)
    LOOP
        l_bill_count := 0;

        IF top_line_grp_rec.date_terminated IS NOT NULL
           AND top_line_grp_rec.date_terminated < SYSDATE  THEN



            SELECT   COUNT(cle_id)
            INTO     l_bill_count
            FROM     oks_bill_cont_lines
            WHERE    cle_id = top_line_grp_rec.id
            AND      bill_action = 'RI';

        END IF; --IF top_line_grp_rec.date_terminated IS NOT NULL and < sysdate

        IF l_bill_count = 0
        THEN

                l_tbl_ctr :=0;
                l_lvl_element_tbl_in.delete;
                l_lvl_element_tbl_out.delete;
                l_SLL_tbl_type.delete;


         FOR rules_rec IN rules_csr (top_line_grp_rec.rgp_id)
         LOOP

         -- only for one time billing
         -- two condition for one time billing
         -- 1. when rule_information2 is null and rule_information3(bill_upto) is null/not null or less than line_end_date
         -- 2. when rule_information2 is null and rule_information3(bill_upto) is null/not null or greater/equal than line_end_date

         IF (rules_rec.rule_information2 IS NULL
                     AND (top_line_grp_rec.end_date
                                   > NVL(TO_DATE(SUBSTR(rules_rec.rule_information3,1,21),'YYYY/MM/DD HH24:MI:SS'),top_line_grp_rec.end_date-1)))
         THEN

            l_max_date_billed_to := NULL;

            --get MAX date from oks_bill_cont_lines
            SELECT   MAX(date_billed_to)
            INTO     l_max_date_billed_to
            FROM     oks_bill_cont_lines
            WHERE    cle_id = top_line_grp_rec.id
            AND      bill_action = 'RI';


            IF l_max_date_billed_to IS NULL THEN
              IF rules_rec.rule_information3 IS NOT NULL  THEN

               IF top_line_grp_rec.end_date > TO_DATE(SUBSTR(rules_rec.rule_information3,1,21),'YYYY/MM/DD HH24:MI:SS')
               THEN

                  l_max_date_billed_to := TO_DATE(SUBSTR(rules_rec.rule_information3,1,21),'YYYY/MM/DD HH24:MI:SS');
               END IF; --top_line_grp_rec.end_date > TO_DATE(SUBSTR(rules_rec.rule_information3,1,21),'YYYY/MM/DD HH24:MI:SS')

              ELSE                 --RI3 NOT NULL

                  l_max_date_billed_to := top_line_grp_rec.end_date;

              END IF; --IF rules_rec.rule_information3 IS NOT NULL
            END IF; --l_max_date_billed_to IS NULL

            IF l_max_date_billed_to IS NOT NULL THEN
                l_tbl_ctr := 0;
                l_duration := NULL;
                l_time := NULL;

                 OKC_TIME_UTIL_PUB.get_duration(
                                   top_line_grp_rec.start_date
                                  ,l_max_date_billed_to
                                  ,l_duration
                                  ,l_time
                                  ,l_return_status
			          );


                    IF l_return_status = 'S' THEN
                       l_start_date := top_line_grp_rec.start_date;

                        --## create rule for one time billing in days
                      l_tbl_ctr := l_tbl_ctr + 1;


                      l_SLL_tbl_type(l_tbl_ctr).cle_id                 :=  p_cle_id;
                      l_SLL_tbl_type(l_tbl_ctr).sequence_no            :=  l_tbl_ctr;
                      l_SLL_tbl_type(l_tbl_ctr).level_periods          :=  1;
                      l_SLL_tbl_type(l_tbl_ctr).uom_per_period         :=  l_duration;
                      l_SLL_tbl_type(l_tbl_ctr).level_amount           :=  NULL;
                      l_SLL_tbl_type(l_tbl_ctr).invoice_offset_days    :=  NVL(rules_rec.rule_information7,0);
                      l_SLL_tbl_type(l_tbl_ctr).uom_code               :=  l_time;

                    END IF;

                IF l_max_date_billed_to + 1 <= top_line_grp_rec.end_date  THEN
                   l_duration := NULL;
                   l_time := NULL;

                   OKC_TIME_UTIL_PUB.get_duration(
                                  l_max_date_billed_to +1
                                  ,top_line_grp_rec.end_date
                                  ,l_duration
                                  ,l_time
                                  ,l_return_status
			          );


                    IF l_return_status = 'S'   THEN
                        l_start_date := top_line_grp_rec.start_date;

                        --## create rule for one time billing in days
                        l_tbl_ctr := l_tbl_ctr + 1;


                      l_SLL_tbl_type(l_tbl_ctr).cle_id                 :=  p_cle_id;
                      l_SLL_tbl_type(l_tbl_ctr).sequence_no            :=  l_tbl_ctr;
                      l_SLL_tbl_type(l_tbl_ctr).level_periods          :=  1;
                      l_SLL_tbl_type(l_tbl_ctr).uom_per_period         :=  l_duration;
                      l_SLL_tbl_type(l_tbl_ctr).level_amount           :=  NULL;
                      l_SLL_tbl_type(l_tbl_ctr).invoice_offset_days    :=  NVL(rules_rec.rule_information7,0);
                      l_SLL_tbl_type(l_tbl_ctr).uom_code               :=  l_time;

                   END IF;

                 END IF; --IF l_max_billed_to <= top_line_grp_rec.end_date

            END IF; --l_max_billed_date is not null


         ELSIF (rules_rec.rule_information2 IS NULL AND
               (top_line_grp_rec.end_date
                             <= TO_DATE(SUBSTR(rules_rec.rule_information3,1,21),'YYYY/MM/DD HH24:MI:SS')))
         THEN
--errorout('here 2');
                l_tbl_ctr := 0;
                l_duration := NULL;
                l_time := NULL;

                 OKC_TIME_UTIL_PUB.get_duration(
                                   top_line_grp_rec.start_date
                                  ,top_line_grp_rec.end_date
                                  ,l_duration
                                  ,l_time
                                  ,l_return_status
			          );


                    IF l_return_status = 'S'  THEN
                        l_start_date := top_line_grp_rec.start_date;

                        --## create rule for one time billing in days
                        l_tbl_ctr := l_tbl_ctr + 1;


                      l_SLL_tbl_type(l_tbl_ctr).cle_id                 :=  p_cle_id;
                      l_SLL_tbl_type(l_tbl_ctr).sequence_no            :=  l_tbl_ctr;
                      l_SLL_tbl_type(l_tbl_ctr).level_periods          :=  1;
                      l_SLL_tbl_type(l_tbl_ctr).uom_per_period         :=  l_duration;
                      l_SLL_tbl_type(l_tbl_ctr).level_amount           :=  NULL;
                      l_SLL_tbl_type(l_tbl_ctr).invoice_offset_days    :=  NVL(rules_rec.rule_information7,0);
                      l_SLL_tbl_type(l_tbl_ctr).uom_code               :=  l_time;


                END IF;

        END IF;
 END LOOP; --end of loop rules_rec
 x_return_status := l_return_status;

 IF l_SLL_tbl_type.COUNT > 0  THEN
               -- Call bill API
    oks_bill_sch.create_bill_sch_rules(p_billing_type    => 'T',
                                       p_sll_tbl         =>  l_SLL_tbl_type,
                                       p_invoice_rule_id =>  p_invoice_rule_id,
                                       x_bil_sch_out_tbl =>  l_bil_sch_out_tbl,
                                       x_return_status   =>  l_return_status);

    --errorout('l_return_status'||l_return_status);
    --check status of create_bill_sch_rules and call update_lvl_element
    IF l_return_status = 'S' THEN
       -- Top line amount will be updated only for usage (lse_id = 12)
       IF top_line_grp_rec.lse_id = 12 THEN

          l_bill_count := 0;

          SELECT   COUNT(cle_id)
          INTO     l_bill_count
          FROM     oks_bill_cont_lines
          WHERE    cle_id = top_line_grp_rec.id
          AND	     bill_action = 'RI';

          IF l_bill_count > 0 THEN
            l_lvl_rec_ctr := 0;
            l_lvl_element_tbl.delete;

            FOR level_elements_rec  IN level_elements_csr (p_cle_id)
            LOOP

              l_lvl_rec_ctr := l_lvl_rec_ctr + 1;
              IF l_bill_count > 0 THEN
                 l_lvl_rec_ctr := 1;

                  l_lvl_element_tbl(l_lvl_rec_ctr).id := level_elements_rec.id;
                  l_lvl_element_tbl(l_lvl_rec_ctr).sequence_number := level_elements_rec.sequence_number;
                  l_lvl_element_tbl(l_lvl_rec_ctr).amount := level_elements_rec.amount;
                  l_lvl_element_tbl(l_lvl_rec_ctr).date_completed := level_elements_rec.date_completed;
               END IF; --IF l_bill_count > 0

             END LOOP; -- FOR bill_element_rec IN bill_element_csr


             l_tbl_ctr := 0;
             l_bill_cont_tbl.delete;

             FOR bill_cont_rec IN bill_cont_csr (top_line_grp_rec.id)
             LOOP
               l_tbl_ctr := l_tbl_ctr + 1;

               l_bill_cont_tbl(l_tbl_ctr).cle_id := bill_cont_rec.cle_id;
               l_bill_cont_tbl(l_tbl_ctr).amount := bill_cont_rec.amount;

             END LOOP; -- FOR bill_cont_rec IN bill_cont_csr


             l_tbl_ctr :=0;
             l_diff :=0;

             if l_bill_count > 0  then
                    l_diff := l_diff + (l_lvl_element_tbl(1).amount - l_bill_cont_tbl(1).amount);
                    l_lvl_element_tbl(1).amount := l_bill_cont_tbl(1).amount;
                    l_lvl_element_tbl(1).date_completed := sysdate;
             end if;

             l_lvl_element_tbl(l_lvl_element_tbl.count).amount := l_lvl_element_tbl(l_lvl_element_tbl.count).amount + l_diff;

             IF l_lvl_element_tbl.COUNT > 0 THEN

                l_bill_ctr:= 0 ;

                FOR l_bill_ctr in l_lvl_element_tbl.FIRST .. l_lvl_element_tbl.LAST
                LOOP
                   UPDATE OKS_LEVEL_ELEMENTS
                   SET amount = l_lvl_element_tbl(l_bill_ctr).amount,
                       date_completed = l_lvl_element_tbl(l_bill_ctr).date_completed
                   WHERE id = l_lvl_element_tbl(l_bill_ctr).id;
                END LOOP;

              END IF; --l_lvl_element_tbl.COUNT >0




          END IF;-- IF l_bill_count > 0

         END IF; --top_line_grp_rec.lse_id = 12

       END IF; -- IF l_return_status = 'S' --status of create_bill_sch_rules
   END IF;            -----------l_SLL_tbl_type.COUNT

   -- check status of top line
   IF l_return_status = 'S'    THEN
         --**********subline loop

    FOR line_grp_rec IN line_grp_csr (top_line_grp_rec.id)
    LOOP

       l_bill_count := 0;

       SELECT   COUNT(cle_id)
       INTO     l_bill_count
       FROM     oks_bill_sub_lines
       WHERE    cle_id = line_grp_rec.id;


       IF l_bill_count > 0 THEN

         l_lvl_rec_ctr := 0;
         l_lvl_element_tbl.delete;

         FOR level_elements_rec  IN level_elements_csr (line_grp_rec.id)
         LOOP

                  l_lvl_rec_ctr := l_lvl_rec_ctr + 1;

                  l_lvl_element_tbl(l_lvl_rec_ctr).id := level_elements_rec.id;
                  l_lvl_element_tbl(l_lvl_rec_ctr).sequence_number := level_elements_rec.sequence_number;
                  l_lvl_element_tbl(l_lvl_rec_ctr).amount := level_elements_rec.amount;
                  l_lvl_element_tbl(l_lvl_rec_ctr).date_completed := level_elements_rec.date_completed;

          END LOOP; -- FOR bill_element_rec IN bill_element_csr




           l_tbl_ctr := 0;
           l_bill_sub_tbl.delete;
           FOR bill_sub_rec IN bill_sub_csr (line_grp_rec.id)
           LOOP
               l_tbl_ctr := l_tbl_ctr + 1;

               l_bill_sub_tbl(l_tbl_ctr).cle_id := bill_sub_rec.cle_id;
               l_bill_sub_tbl(l_tbl_ctr).amount := bill_sub_rec.amount;


           END LOOP; -- FOR bill_sub_rec IN bill_sub_csr


           l_bill_ctr :=0;
           l_diff :=0;
           if l_bill_count >0 then
                    l_diff := l_diff + (l_lvl_element_tbl(1).amount - l_bill_sub_tbl(1).amount);
                    l_lvl_element_tbl(1).amount := l_bill_sub_tbl(1).amount;
                    l_lvl_element_tbl(1).date_completed := sysdate;
            end if;

            l_lvl_element_tbl(l_lvl_element_tbl.count).amount := l_lvl_element_tbl(l_lvl_element_tbl.count).amount + l_diff;

            IF l_lvl_element_tbl.COUNT > 0 THEN

                  ---------updating directly
                  l_bill_ctr:= 0 ;

                  FOR l_bill_ctr in l_lvl_element_tbl.FIRST .. l_lvl_element_tbl.LAST
                  LOOP
                    UPDATE OKS_LEVEL_ELEMENTS
                    SET amount = l_lvl_element_tbl(l_bill_ctr).amount,
                       date_completed = l_lvl_element_tbl(l_bill_ctr).date_completed
                    WHERE id = l_lvl_element_tbl(l_bill_ctr).id;
                  END LOOP;


               END IF; --  IF l_lvl_element_tbl.COUNT > 0



          END IF; -- IF l_bill_count > 0

   END LOOP; --line_grp_rec
--end subline loop
   END IF; --lF l_return_status = 'S'

  END IF; -- IF l_bill_count = 0

  END LOOP; --top_line_grp_rec
x_return_status := l_return_status;

END one_time_billing;




Procedure Create_Billing_Schd
(
  P_srv_sdt          IN  Date
, P_srv_edt          IN  Date
, P_amount           IN  Number
, P_chr_id           IN  Number
, P_rule_id          IN  Varchar2
, P_line_id          IN  Number
, P_invoice_rule_id  IN  Number
, X_msg_data         OUT NOCOPY Varchar2
, X_msg_count        OUT NOCOPY Number
, X_Return_status    OUT NOCOPY Varchar2
)
Is

      l_sll_tbl                           OKS_BILL_SCH.StreamLvl_tbl;
      l_bil_sch_out                       OKS_BILL_SCH.ItemBillSch_tbl;
      l_api_version                       CONSTANT NUMBER := 1.0 ;
      l_init_msg_list                     CONSTANT VARCHAR2(1) := 'T' ;
      l_return_status                     VARCHAR2(1) ;
      l_duration                          Number;
      l_timeunits                         Varchar2(25);
      l_top_line_sll_id   number ;
      l_sub_line_sll_id   number ;
      l_sub_sll_level_id  number ;
      l_top_sll_level_id  number ;
	 l_top_sll_amount    number ;


      cursor l_price_csr(pl_top_line_id in number)  is
       select sum(nvl(price_negotiated , 0))
       from okc_k_lines_b where cle_id = pl_top_line_id and lse_id = 25;


      cursor l_sub_line_csr (p_top_line_id in number ) is
      select lines.id               sub_line_id
 	    ,lines.start_date       sub_line_start_date
            ,lines.end_date         sub_line_end_date
            ,lines.date_terminated  sub_line_date_terminated
            ,lines.price_negotiated sub_line_price_negotiated
        from okc_k_lines_b     lines
       where lines.cle_id = p_top_line_id
         AND lines.lse_id = 25;

     l_sub_line_rec      l_sub_line_csr%rowtype ;

     FUNCTION get_seq_id RETURN NUMBER IS
     BEGIN
       RETURN(okc_p_util.raw_to_number(sys_guid()));
     END get_seq_id;

  Begin
    l_top_line_sll_id  := get_seq_id ;

    INSERT INTO OKS_STREAM_LEVELS_B
    (id, chr_id, cle_id,dnz_chr_id , sequence_no, uom_code , start_date,  end_date,
     level_periods,  uom_per_period,  object_version_number,
     created_by ,  creation_date, last_updated_by,  last_update_date  )
    VALUES
    (l_top_line_sll_id, null, p_line_id, p_chr_id, 1, 'DAY', p_srv_sdt, p_srv_edt,
     1, (p_srv_edt - p_srv_sdt +1), 1 ,
     -1 , sysdate , -1 , sysdate);


     l_top_sll_level_id     := get_seq_id ;

     l_top_sll_amount := 0;
     open l_price_csr(p_line_id );
     fetch l_price_csr into l_top_sll_amount ;
     close l_price_csr;

     insert into oks_level_elements
    	(id , sequence_number , date_start , amount , date_transaction, date_to_interface ,date_completed ,
     object_version_number , rul_id ,created_by , creation_date , last_updated_by , last_update_date ,
     cle_id, parent_cle_id, dnz_chr_id, date_end)
     values (l_top_sll_level_id,1 , p_srv_sdt ,l_top_sll_amount , sysdate ,sysdate ,sysdate ,1 ,l_top_line_sll_id ,
     -1 , sysdate , -1 , sysdate,
     p_line_id, p_line_id, p_chr_id, p_srv_edt );

     for l_sub_line_rec in l_sub_line_csr(p_line_id )
     loop
       l_sub_line_sll_id := get_seq_id ;


       INSERT INTO OKS_STREAM_LEVELS_B
       (id, chr_id, cle_id,dnz_chr_id , sequence_no, uom_code , start_date,  end_date,
        level_periods,  uom_per_period,  object_version_number,
        created_by ,  creation_date, last_updated_by,  last_update_date  )
       VALUES(l_sub_line_sll_id, null, l_sub_line_rec.sub_line_id, p_chr_id, 1, 'DAY', p_srv_sdt, p_srv_edt,
        1, (p_srv_edt - p_srv_sdt +1), 1 ,
        -1 , sysdate , -1 , sysdate);





         l_sub_sll_level_id := get_seq_id ;

         insert into oks_level_elements
    	    (id , sequence_number , date_start , amount , date_transaction, date_to_interface ,date_completed ,
         object_version_number , rul_id ,created_by , creation_date , last_updated_by , last_update_date ,
         cle_id, parent_cle_id, dnz_chr_id, date_end)
         values (l_sub_sll_level_id,1 , l_sub_line_rec.sub_line_start_date ,l_sub_line_rec.sub_line_price_negotiated
         ,sysdate ,sysdate ,sysdate ,1 ,l_sub_line_sll_id , -1 , sysdate , -1 , sysdate,
         l_sub_line_rec.sub_line_id , p_line_id, p_chr_id,l_sub_line_rec.sub_line_end_date  );
     end loop;

     x_return_status := l_return_status;

Exception
       When  G_EXCEPTION_HALT_VALIDATION Then
             x_return_status := l_return_status;
             Null;
       When  Others Then
             x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

End Create_Billing_schd ;



/*****************************************************************
 This procedure is called to create Billing Schedules for the
 Extended warranty lines created from OM. The Date Completed of
 the level elements will be updated with the current date.
 These contracts will opened up in the Authoring form.
*******************************************************************/

PROCEDURE BILL_UPGRADATION_OM
(
 p_chr_id_lo                 IN NUMBER DEFAULT NULL,
 p_chr_id_hi                 IN NUMBER DEFAULT NULL
)
IS

l_return_status 	   VARCHAR2(1) ;
l_msg_data		   VARCHAR2(2000);
l_msg_count                NUMBER:=0;
i                          NUMBER ;



--Top Lines and group information

CURSOR top_line_grp_csr  IS
       SELECT 	lines.id id,lines.lse_id lse_id,lines.dnz_chr_id dnz_chr_id,
		lines.start_date start_date,NVL(lines.date_terminated,lines.end_date) end_date,
                lines.date_terminated date_terminated,lines.upg_orig_system_ref upg_orig_system_ref,
                lines.upg_orig_system_ref_id upg_orig_system_ref_id
       FROM 	okc_k_lines_b lines,
                okc_k_headers_b  hdr,
                okc_statuses_b  sta
       where    hdr.id BETWEEN p_chr_id_lo AND p_chr_id_hi
         and    sta.ste_code not in ('TERMINATED','ENTERED','CANCELLED')
         and    sta.code =    hdr.sts_code
         and    hdr.scs_code = 'WARRANTY'
         and    lines.lse_id = 19
         and    lines.dnz_chr_id = hdr.id
         and    lines.sts_code <> 'TERMINATED'
         AND ( nvl(lines.upg_orig_system_ref,'x') <> 'MIG_BILL' )
         and (  exists ( select 1 from okc_k_rel_objs rel
                      where rel.cle_id = lines.id )
              or
              exists ( select 1 from okc_k_rel_objs rel2 ,
                                     okc_k_lines_b line2
                      where line2.cle_id = lines.id
                        and rel2.cle_id = line2.id
                        and line2.lse_id = 25 ) );

CURSOR l_sll_csr(p_top_line_id  NUMBER) IS
       SELECT COUNT(id)
       FROM OKS_STREAM_LEVELS_B
       WHERE CLE_ID = p_top_line_id;

L_SLL_COUNT   NUMBER;

  Type l_num_tbl is table of NUMBER index  by BINARY_INTEGER ;
  Type l_date_tbl is table of DATE  index  by BINARY_INTEGER ;
  Type l_chr_tbl is table of Varchar2(2000) index  by BINARY_INTEGER ;


l_id                    l_num_tbl;
l_lse_id                l_num_tbl;
l_dnz_chr_id            l_num_tbl;
l_start_date            l_date_tbl;
l_end_date              l_date_tbl;
l_date_terminated       l_date_tbl;
l_upg_orig_system_ref     l_chr_tbl;
l_upg_orig_system_ref_id  l_num_tbl;

Begin

l_return_status := 'S';
DBMS_TRANSACTION.SAVEPOINT('BEFORE_TRANSACTION');

OPEN  top_line_grp_csr ;
LOOP
 FETCH top_line_grp_csr bulk collect into   l_id  ,
                                            l_lse_id ,
                                            l_dnz_chr_id  ,
                                            l_start_date,
                                            l_end_date ,
                                            l_date_terminated ,
                                            l_upg_orig_system_ref,
                                            l_upg_orig_system_ref_id LIMIT 10000;

  IF l_id.COUNT > 0 THEN
   FOR I IN l_id.FIRST .. l_id.LAST
   LOOP


     OPEN l_sll_csr(l_ID(i)) ;
     FETCH  l_sll_csr  INTO L_SLL_COUNT ;
     CLOSE l_sll_csr;

     IF L_SLL_COUNT = 0 THEN

        -- call to create billing schedule
        Create_Billing_Schd(
                      P_srv_sdt          => l_start_date(i)
                    , P_srv_edt          => l_end_date(i)
                    , P_amount           => Null
                    , P_chr_id           => l_dnz_chr_id(i)
                    , P_rule_id          => Null
                    , P_line_id          => l_id(i)
                    , P_invoice_rule_id  => -2
                    , X_msg_data         => l_msg_data
                    , X_msg_count        => l_msg_count
                    , X_Return_status    => l_return_status);


         IF  L_RETURN_STATUS = OKC_API.G_RET_STS_SUCCESS THEN

            -- call to create billing records (Bcl / Bsl)
            CREATE_BILL_DTLS
                   ( p_dnz_chr_id                   => l_dnz_chr_id(i),
		     P_top_line_id                  => l_id(i),
		     p_top_line_start_date          => l_start_date(i),
		     p_top_line_end_date            => l_end_date(i),
		     p_top_line_UPG_ORIG_SYSTEM_REF => l_upg_orig_system_ref(i),
		     p_top_line_UPG_ORIG_SYSTEM_id  => l_upg_orig_system_ref_id(i),
		     p_top_line_date_terminated     => l_date_terminated(i),
                     X_Return_status                => l_return_status );
          END IF ;
       Else                 ----sll count > 0
            CREATE_BILL_DTLS
                   ( p_dnz_chr_id                   => l_dnz_chr_id(i),
		     p_top_line_id                  => l_id(i),
		     p_top_line_start_date          => l_start_date(i),
		     p_top_line_end_date            => l_end_date(i),
		     p_top_line_UPG_ORIG_SYSTEM_REF => l_upg_orig_system_ref(i),
		     p_top_line_UPG_ORIG_SYSTEM_id  => l_upg_orig_system_ref_id(i),
		     p_top_line_date_terminated     => l_date_terminated(i),
                     X_Return_status                => l_return_status );
       END IF ;

       L_SLL_COUNT := 0 ;
     END LOOP;              -----l_id tbl loop
  END IF;                   ---l_id tbl count chk

COMMIT;

EXIT WHEN top_line_grp_csr%NOTFOUND ;
END LOOP;   --MAIN LOOP END

COMMIT;



EXCEPTION WHEN OTHERS THEN
    DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
    l_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.SET_MESSAGE
   	  (
          p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
          );


END BILL_UPGRADATION_OM; -- Procedure Migration for OM contracts



PROCEDURE BILL_UPGRADATION
(
 p_chr_id_lo                 IN NUMBER DEFAULT NULL,
 p_chr_id_hi                 IN NUMBER DEFAULT NULL
)
IS

  Type l_num_tbl is table of NUMBER index  by BINARY_INTEGER ;
  Type l_date_tbl is table of DATE  index  by BINARY_INTEGER ;
  Type l_chr_tbl is table of Varchar2(2000) index  by BINARY_INTEGER ;



CURSOR top_line_grp_csr  IS
SELECT 	lines.id id,lines.lse_id lse_id,lines.cle_id cle_id,lines.dnz_chr_id,
     	lines.start_date start_date,NVL(lines.date_terminated,lines.end_date) end_date,
        lines.date_terminated date_terminated,	rgp.id rgp_id, rul.object1_id1 inv_rul_id
  FROM 	okc_k_lines_b lines,
        okc_rule_groups_b rgp,
        okc_rules_b rul
 WHERE	lines.id = rgp.cle_id
   AND	lines.lse_id in (1,12,19)
   AND  lines.sts_code not in ('TERMINATED','ENTERED','CANCELLED')
   and  lines.dnz_chr_id = rgp.dnz_chr_id
   AND  lines.dnz_chr_id between P_chr_id_lo and p_chr_id_hi
   AND  (( lines.upg_orig_system_ref IS NULL
           and  not  exists ( select 1 from okc_k_rel_objs rel
                                      where rel.cle_id = lines.id and rownum < 2 ) )
            OR ( nvl(lines.upg_orig_system_ref,'MIG_NOBILL') = 'MIG_BILL'))
    AND NOT EXISTS
           (SELECT 1 FROM oks_stream_levels_b sll
            WHERE sll.cle_id = lines.id )
   AND rul.rgp_id(+) = rgp.id
   AND rul.rule_information_category(+) = 'IRE';


l_id                 l_num_tbl;
l_lse_id             l_num_tbl;
l_cle_id             l_num_tbl;
l_dnz_chr_id         l_num_tbl;
l_start_dt           l_date_tbl;
l_end_dt             l_date_tbl;
l_date_terminated    l_date_tbl;
l_rgp_id             l_num_tbl;
l_inv_rul_id         l_chr_tbl;


L_ERRM  VARCHAR2(1000);


--Level element information

CURSOR level_elements_csr (p_id NUMBER) IS
       SELECT	lvl.id id, lvl.sequence_number sequence_number,
                lvl.date_start date_start, lvl.amount amount,
                lvl.date_completed date_completed
       FROM	oks_level_elements lvl, oks_stream_levels_b rule
       WHERE	lvl.rul_id = rule.id
       AND      rule.cle_id = p_id
       ORDER BY lvl.date_start;


--Lines  information

CURSOR line_grp_csr (p_cle_id NUMBER) IS
       SELECT 	lines.id,lines.lse_id lse_id,lines.cle_id,lines.dnz_chr_id,
	 	lines.start_date,NVL(lines.date_terminated,lines.end_date) end_date,
                lines.date_terminated
       FROM 	okc_k_lines_b lines
       WHERE	lines.cle_id = p_cle_id
       AND	lines.lse_id in (7,8,9,10,11,13,18,25,35)
       and  not  exists ( select 1 from okc_k_rel_objs rel
                          where rel.cle_id = lines.id );


--Rule information for top line

CURSOR rules_csr (p_rgp_id NUMBER) IS
       SELECT	a.id,a.object1_id1,a.object2_id1,
              	a.object3_id1,a.jtot_object1_code,a.jtot_object2_code,
	        a.rule_information_category,
		a.rule_information1,a.rule_information2,
		a.rule_information3,a.rule_information4,
		a.rule_information5,a.rule_information6,
		a.rule_information7,a.rule_information8,
                a.created_by,a.creation_date,a.last_updated_by,a.last_update_date,
                a.last_update_login
       FROM	okc_rules_b a
       WHERE	a.rule_information_category = 'SBG'
       AND	a.rgp_id = p_rgp_id;


--Bill cont lines
CURSOR bill_cont_csr (p_cle_id NUMBER) IS
       SELECT   cle_id,
                amount
       FROM     oks_bill_cont_lines
       WHERE    cle_id = p_cle_id
       AND      bill_action = 'RI';

--Bill sub lines
CURSOR bill_sub_csr (p_cle_id NUMBER) IS
       SELECT   cle_id,
                amount
       FROM     oks_bill_sub_lines
       WHERE    cle_id = p_cle_id;

l_lvl_element_tbl_in       oks_bill_level_elements_pvt.letv_tbl_type;
l_lvl_element_tbl_out      oks_bill_level_elements_pvt.letv_tbl_type;
l_SLL_tbl_type             OKS_BILL_SCH.StreamLvl_tbl; --stream_lvl_tbl;
l_bil_sch_out_tbl          OKS_BILL_SCH.ItemBillSch_tbl; --item_bill_sch_tbl;
l_lvl_element_tbl          oks_bill_level_elements_pvt.letv_tbl_type;
l_bill_cont_tbl            bill_cont_tbl;
l_bill_sub_tbl             bill_cont_tbl;

l_adv_arr		   VARCHAR2(40);
l_rule_id		   NUMBER := 0;
l_start_date		   DATE;
l_end_date		   DATE;
l_duration		   NUMBER := 0;
l_time  	 	   VARCHAR2(450) ;
l_return_status 	   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_ctr			   NUMBER := 0;
l_tbl_ctr		   NUMBER := 0;
l_invoice_rule_id          NUMBER :=0;
l_lvl_rec_ctr		   NUMBER := 0;
l_bill_count		   NUMBER := 0;
l_bill_ctr		   NUMBER := 0;
l_lvl_ctr		   NUMBER := 0;
l_lvl_count		   NUMBER := 0;
l_lvl_sum		   NUMBER := 0;
l_bill_sum		   NUMBER := 0;
l_diff		           NUMBER :=0;
l_msg_data		   VARCHAR2(2000);
l_msg_count                NUMBER:=0;
l_flag                     VARCHAR2(1);
l_rl2_flag_null            VARCHAR2(1);
l_tbl                      NUMBER;



BEGIN
  l_return_status := OKC_API.G_RET_STS_SUCCESS;
  DBMS_TRANSACTION.SAVEPOINT('BEFORE_TRANSACTION');


   OPEN  top_line_grp_csr ;
   LOOP
   FETCH top_line_grp_csr bulk collect into l_id   ,
                                            l_lse_id  ,
                                            l_cle_id ,
                                            l_dnz_chr_id ,
                                            l_start_dt ,
                                            l_end_dt ,
                                            l_date_terminated ,
                                            l_rgp_id   ,
                                            l_inv_rul_id  LIMIT 10000;





  If l_id.count > 0 then
    FOR I IN l_id.FIRST .. l_id.LAST
    LOOP


       IF l_inv_rul_id(i) IS NULL THEN
          l_invoice_rule_id := -2;
       ELSE
          l_invoice_rule_id := to_number(l_inv_rul_id(i));
       END IF;              -- IRE RULE

       l_bill_count := 0;

       IF l_date_terminated(i) IS NOT NULL AND
          l_date_terminated(i) < sysdate  THEN

          l_bill_count := 0;

          SELECT   COUNT(cle_id)
          INTO     l_bill_count
          FROM     oks_bill_cont_lines
          WHERE    cle_id = l_id(i)
          AND      bill_action = 'RI';

        END IF; --IF top_line_date_terminated IS NOT NULL and < sysdate

        IF l_bill_count = 0 THEN
           l_tbl_ctr :=0;
           l_lvl_element_tbl_in.delete;
           l_lvl_element_tbl_out.delete;
           l_SLL_tbl_type.delete;

           FOR rules_rec IN rules_csr (l_rgp_id(i))
           LOOP



             --Check for one time or reccuring billing
             -- check for one time billing

              l_rl2_flag_null := 'N';

             IF rules_rec.rule_information2 IS NULL THEN
                 --Call proc one_time_billing
                  OKS_BILL_MIGRATION.one_time_billing(
                                   p_invoice_rule_id => l_invoice_rule_id
                                  ,p_cle_id          => l_id(i)
                                  ,x_return_status   => l_return_status);

                  l_rl2_flag_null := 'Y';


             ELSE              --for recurring billing
                l_ctr := 0;

                -- check for bill upto date
                IF rules_rec.rule_information3 IS NOT NULL THEN       ---billed date not null

                  l_start_date := l_start_dt(i);
                  l_end_date   :=  TRUNC(TO_DATE(SUBSTR(rules_rec.rule_information3,1,21),'YYYY/MM/DD HH24:MI:SS'));

                  okc_time_util_pub.get_duration(
                                               p_start_date    => l_start_date,
                                               p_end_date      => l_end_date,
                                               x_duration      => l_duration,
                                               x_timeunit      => l_time,
                                               x_return_status => l_return_status );

                 IF l_return_status = 'S' THEN

                    --##create rule1 for bill_upto date in days

                    l_tbl_ctr := l_tbl_ctr + 1;
                     --SLL rule


                      l_SLL_tbl_type(l_tbl_ctr).cle_id                 :=  l_id(i);
                      l_SLL_tbl_type(l_tbl_ctr).sequence_no            :=  l_tbl_ctr;
                      l_SLL_tbl_type(l_tbl_ctr).level_periods          :=  1;
                      l_SLL_tbl_type(l_tbl_ctr).uom_per_period         :=  l_duration;
                      l_SLL_tbl_type(l_tbl_ctr).level_amount           :=  NULL;
                      l_SLL_tbl_type(l_tbl_ctr).invoice_offset_days    :=  NVL(rules_rec.rule_information7,0);
                      l_SLL_tbl_type(l_tbl_ctr).uom_code               :=  l_time;

                       l_start_date := l_end_date +1;
                       l_flag := 'F';

                END IF;--             IF l_return_status = 'S'

              ELSE            --if bill upto date is null

                l_start_date := l_start_dt(i);
                l_end_date := l_start_dt(i);
                l_flag := 'T';

             END IF; -- IF rules_rec.rule_information3 IS NOT NULL (billed chk)

             LOOP

       		IF l_end_dt(i) <= l_end_date THEN
                    EXIT;
                END IF;   -- IF end_dt(i) <= l_end_date

       		IF l_end_dt(i) > l_end_date THEN

                   IF l_flag = 'T' THEN

                     l_end_date := okc_time_util_pub.get_enddate
                                     (l_end_date
                                     ,rules_rec.rule_information2
                                     ,1);
                     l_end_date := TRUNC(l_end_date);
                     l_flag := 'F';

                   ELSE
                     l_end_date := okc_time_util_pub.get_enddate
                                     (l_end_date + 1
                                     ,rules_rec.rule_information2
                                     ,1);
                     l_end_date := TRUNC(l_end_date);
                   END IF; --IF l_flag = 'T'


                   --(1) check line end date is less than calculate rule end date
                   IF  l_end_dt(i) < l_end_date THEN

                      l_end_date := l_end_dt(i);
                      okc_time_util_pub.get_duration(
                                              p_start_date    => l_start_date,
                                              p_end_date      => l_end_date,
                                              x_duration      => l_duration,
                                              x_timeunit      => l_time,
                                              x_return_status => l_return_status);

                      IF l_return_status = 'S' THEN

                         --## create a rule for a days
                         l_tbl_ctr := l_tbl_ctr + 1;
                         --SLL rule

                        l_SLL_tbl_type(l_tbl_ctr).cle_id                 :=  l_id(i);
                        l_SLL_tbl_type(l_tbl_ctr).sequence_no            :=  l_tbl_ctr;
                        l_SLL_tbl_type(l_tbl_ctr).level_periods          :=  1;
                        l_SLL_tbl_type(l_tbl_ctr).uom_per_period         :=  l_duration;
                        l_SLL_tbl_type(l_tbl_ctr).level_amount           :=  NULL;
                        l_SLL_tbl_type(l_tbl_ctr).invoice_offset_days    :=  NVL(rules_rec.rule_information7,0);
                        l_SLL_tbl_type(l_tbl_ctr).uom_code               :=  l_time;


                        EXIT;

                     END IF;-- IF l_return_status = 'S'

               END IF;                 -- IF top_line end_date < l_end_date


               --(2) check line end date is equal to calculate rule end date
               IF l_end_dt(i) = l_end_date THEN

                 IF l_ctr = 0 THEN

                   okc_time_util_pub.get_duration(
                                              p_start_date    => l_start_date,
                                              p_end_date      => l_end_date,
                                              x_duration      => l_duration,
                                              x_timeunit      => l_time,
                                              x_return_status => l_return_status);

                   IF l_return_status = 'S' THEN

                        --## create a rule for l_ctr period of a UOM : l_start_date to l_end_date
                      l_tbl_ctr := l_tbl_ctr + 1;
                      --SLL rule


                      l_SLL_tbl_type(l_tbl_ctr).cle_id                 :=  l_id(i);
                      l_SLL_tbl_type(l_tbl_ctr).sequence_no            :=  l_tbl_ctr;
                      l_SLL_tbl_type(l_tbl_ctr).level_periods          :=  1;
                      l_SLL_tbl_type(l_tbl_ctr).uom_per_period         :=  l_duration;
                      l_SLL_tbl_type(l_tbl_ctr).level_amount           :=  NULL;
                      l_SLL_tbl_type(l_tbl_ctr).invoice_offset_days    :=  NVL(rules_rec.rule_information7,0);
                      l_SLL_tbl_type(l_tbl_ctr).uom_code               :=  l_time;


                   END IF;-- IF l_return_status = 'S'
                ELSE                    ---l_ctr <>0

                   l_ctr := l_ctr +1;
                   l_SLL_tbl_type(l_tbl_ctr).level_periods := l_ctr;
                END IF; --IF l_ctr =0

                EXIT;

             END IF;-- IF  top_line end_date = l_end_date


             -- check line end date is greater than rule end date
             IF l_end_dt(i) > l_end_date THEN
                IF l_ctr = 0 THEN
                   okc_time_util_pub.get_duration(
                                              p_start_date    => l_start_date,
                                              p_end_date      => l_end_date,
                                              x_duration      => l_duration,
                                              x_timeunit      => l_time,
                                              x_return_status => l_return_status);

                 --##create rule for period of l_ctr time
                 IF l_return_status = 'S' THEN

                   IF (l_time = 'QTR' and rules_rec.rule_information2 = 'MTH') THEN

                      l_duration := l_duration * 3;
                      l_time := 'MTH';
                   END IF; -- IF (l_time = 'QTR' and rules_rec.rule_information2 = 'MTH')

                   l_tbl_ctr := l_tbl_ctr + 1;

                   l_SLL_tbl_type(l_tbl_ctr).cle_id                 :=  l_id(i);
                   l_SLL_tbl_type(l_tbl_ctr).sequence_no            :=  l_tbl_ctr;
                   l_SLL_tbl_type(l_tbl_ctr).level_periods          :=  l_duration;
                   l_SLL_tbl_type(l_tbl_ctr).uom_per_period         :=  1;
                   l_SLL_tbl_type(l_tbl_ctr).level_amount           :=  NULL;
                   l_SLL_tbl_type(l_tbl_ctr).invoice_offset_days    :=  NVL(rules_rec.rule_information7,0);
                   l_SLL_tbl_type(l_tbl_ctr).uom_code               :=  l_time;


                   l_ctr := l_ctr + 1;
                   l_start_date := l_end_date +1;

                 END IF;-- IF l_return_status = 'S'

               ELSE

                 l_start_date := l_end_date +1;
                 l_ctr := l_ctr + 1;
                 l_SLL_tbl_type(l_tbl_ctr).level_periods := l_ctr;

               END IF;-- IF l_ctr <=2

            END IF;         -- IF  top_line end_date > l_end_date


         END IF;       -- IF  top_line end_date > l_end_date

       END LOOP;      --end of loop

     END IF; --end if of rules_rec.rule_information2 IS NULL (recurring billing)


   --Variable for sub line


   END LOOP; --end of loop rules_rec

   IF l_rl2_flag_null = 'N' THEN
     --check status for create rules then call create_bill_sch_rules

     IF l_SLL_tbl_type.COUNT > 0 THEN
        -- Call bill API

        oks_bill_sch.create_bill_sch_rules(p_billing_type    => 'T',
                                       p_sll_tbl         =>  l_SLL_tbl_type,
                                       p_invoice_rule_id =>  l_invoice_rule_id,
                                       x_bil_sch_out_tbl =>  l_bil_sch_out_tbl,
                                       x_return_status   =>  l_return_status);


     ------check status of create_bill_sch_rules and call update_lvl_element
     IF l_return_status = 'S' THEN            --status of create_bill_sch_rules

      ------ Top line amount will be updated only for usage (lse_id = 12)
      IF l_lse_id(i) = 12  THEN

        l_bill_count := 0;

        SELECT   COUNT(cle_id)
        INTO     l_bill_count
        FROM     oks_bill_cont_lines
        WHERE    cle_id = l_id(i)
        AND      bill_action = 'RI';

        IF l_bill_count > 0 THEN
          l_lvl_rec_ctr := 0;
          l_lvl_element_tbl.delete;

          FOR level_elements_rec  IN level_elements_csr (l_id(i))
          LOOP

             l_lvl_rec_ctr := l_lvl_rec_ctr + 1;

             l_lvl_element_tbl(l_lvl_rec_ctr).id := level_elements_rec.id;
             l_lvl_element_tbl(l_lvl_rec_ctr).sequence_number := level_elements_rec.sequence_number;
             l_lvl_element_tbl(l_lvl_rec_ctr).amount := level_elements_rec.amount;
             l_lvl_element_tbl(l_lvl_rec_ctr).date_completed := level_elements_rec.date_completed;

          END LOOP; -- FOR bill_element_rec IN bill_element_csr


          l_tbl_ctr := 0;
          l_bill_cont_tbl.delete;

           FOR bill_cont_rec IN bill_cont_csr (l_id(i))
           LOOP
             l_tbl_ctr := l_tbl_ctr + 1;

             l_bill_cont_tbl(l_tbl_ctr).cle_id := bill_cont_rec.cle_id;
             l_bill_cont_tbl(l_tbl_ctr).amount := bill_cont_rec.amount;

           END LOOP; -- FOR bill_cont_rec IN bill_cont_csr


           l_tbl_ctr :=0;
           l_diff :=0;

           IF l_bill_cont_tbl.COUNT <= l_lvl_element_tbl.COUNT  THEN

             FOR  l_bill_ctr IN 1..l_bill_cont_tbl.COUNT
             LOOP

                l_diff := l_diff + (l_lvl_element_tbl(l_bill_ctr).amount - l_bill_cont_tbl(l_bill_ctr).amount);
                l_lvl_element_tbl(l_bill_ctr).amount := l_bill_cont_tbl(l_bill_ctr).amount;
                l_lvl_element_tbl(l_bill_ctr).date_completed := sysdate;

             END LOOP;-- FOR  l_bill_ctr IN 1..l_bill_cont_tbl.COUNT

             l_lvl_element_tbl(l_lvl_element_tbl.count).amount := l_lvl_element_tbl(l_lvl_element_tbl.count).amount + l_diff;

           END IF;             -- IF l_bill_cont_tbl.COUNT < l_lvl_element_tbl.COUNT


           IF l_lvl_element_tbl.COUNT > 0 THEN

             -----updating records directly

             FOR l_tbl in l_lvl_element_tbl.FIRST .. l_lvl_element_tbl.LAST
             LOOP
               UPDATE OKS_LEVEL_ELEMENTS
               SET amount = l_lvl_element_tbl(l_tbl).amount,
                   date_completed = l_lvl_element_tbl(l_tbl).date_completed
               WHERE id = l_lvl_element_tbl(l_tbl).id;
             END LOOP;


           END IF; --l_lvl_element_tbl.COUNT >0

          END IF;-- IF l_bill_count > 0

         END IF; --top_line lse_id = 12

      ELSE               ---create_bill_sch _rules fail

         -- x_return_status := l_return_status;
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');

     END IF; -- IF l_return_status = 'S' --status of create_bill_sch_rules
   END IF;--l_SLL_tbl_type.COUNT > 0

   -- check status of top line
   IF l_return_status = 'S'  THEN
   --**********subline loop

      FOR line_grp_rec IN line_grp_csr (l_id(i))
      LOOP

        l_bill_count := 0;

        SELECT   COUNT(ID)
        INTO     l_bill_count
        FROM     oks_bill_sub_lines
        WHERE    cle_id = line_grp_rec.id;


        IF l_bill_count > 0 THEN

          l_lvl_rec_ctr := 0;
          l_lvl_element_tbl.delete;

          FOR level_elements_rec  IN level_elements_csr (line_grp_rec.id)
          LOOP

                  l_lvl_rec_ctr := l_lvl_rec_ctr + 1;

                  l_lvl_element_tbl(l_lvl_rec_ctr).id := level_elements_rec.id;
                  l_lvl_element_tbl(l_lvl_rec_ctr).sequence_number := level_elements_rec.sequence_number;
                  l_lvl_element_tbl(l_lvl_rec_ctr).amount := level_elements_rec.amount;
                  l_lvl_element_tbl(l_lvl_rec_ctr).date_completed := level_elements_rec.date_completed;

          END LOOP; -- FOR bill_element_rec IN bill_element_csr


          l_tbl_ctr := 0;
          l_bill_sub_tbl.delete;
          FOR bill_sub_rec IN bill_sub_csr (line_grp_rec.id)
          LOOP
            l_tbl_ctr := l_tbl_ctr + 1;

            l_bill_sub_tbl(l_tbl_ctr).cle_id := bill_sub_rec.cle_id;
            l_bill_sub_tbl(l_tbl_ctr).amount := bill_sub_rec.amount;


          END LOOP; -- FOR bill_sub_rec IN bill_sub_csr


          l_bill_ctr :=0;
          l_diff :=0;

          IF l_bill_sub_tbl.COUNT <= l_lvl_element_tbl.COUNT THEN

             FOR  l_bill_ctr IN 1..l_bill_sub_tbl.COUNT
             LOOP

               l_diff := l_diff + (l_lvl_element_tbl(l_bill_ctr).amount - l_bill_sub_tbl(l_bill_ctr).amount);
               l_lvl_element_tbl(l_bill_ctr).amount := l_bill_sub_tbl(l_bill_ctr).amount;
               l_lvl_element_tbl(l_bill_ctr).date_completed := sysdate;

             END LOOP;-- FOR  l_bill_ctr IN 1..l_bill_sub_tbl.COUNT

             l_lvl_element_tbl(l_lvl_element_tbl.count).amount := l_lvl_element_tbl(l_lvl_element_tbl.count).amount + l_diff;

           END IF; -- IF l_bill_sub_tbl.COUNT < l_lvl_element_tbl.COUNT


           IF l_lvl_element_tbl.COUNT > 0  THEN
              -----updating records directly

             FOR l_tbl in l_lvl_element_tbl.FIRST .. l_lvl_element_tbl.LAST
             LOOP
               UPDATE OKS_LEVEL_ELEMENTS
               SET amount = l_lvl_element_tbl(l_tbl).amount,
                   date_completed = l_lvl_element_tbl(l_tbl).date_completed
               WHERE id = l_lvl_element_tbl(l_tbl).id;
             END LOOP;
          END IF;         -----l_lvl_element_tbl.COUNT > 0

         END IF; -- IF l_bill_count > 0

       END LOOP; --line_grp_rec
      --end subline loop
     END IF; --lF l_return_status = 'S'

    END IF; -- IF l_bill_count = 0

   END IF; --IF l_rl2_flag_null = 'N'

  END LOOP; -----main loop end

 END IF;          ------tbl count chk

EXIT WHEN top_line_grp_csr%NOTFOUND ;
END LOOP;   --MAIN LOOP END



COMMIT;



EXCEPTION WHEN OTHERS THEN
    DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
    l_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.SET_MESSAGE
   	  (
          p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
          );


END BILL_UPGRADATION;




PROCEDURE CREATE_BILL_DTLS
    ( p_dnz_chr_id IN number ,
      p_top_line_id in number ,
      p_top_line_start_date in date,
      p_top_line_end_date in date ,
      p_top_line_upg_orig_system_ref in varchar2 ,
      p_top_line_upg_orig_system_id in number ,
      p_top_line_date_terminated in date ,
      x_return_status OUT NOCOPY varchar2 )
    IS


    CURSOR L_LINES_CSR (P_DNZ_CHR_ID NUMBER )IS
    SELECT LINE.ID , LINE.START_DATE , LINE.END_DATE ,UPG_ORIG_SYSTEM_REF , LINE.DATE_TERMINATED
      FROM OKC_K_LINES_B LINE
     WHERE LINE.DNZ_CHR_ID = P_DNZ_CHR_ID
       AND LINE.LSE_ID = 19 ;


    CURSOR L_SUB_LINES_CSR (P_CLE_ID NUMBER )IS
    SELECT LINE.ID , LINE.START_DATE , LINE.END_DATE , PRICE_NEGOTIATED, UPG_ORIG_SYSTEM_REF , LINE.DATE_TERMINATED
      FROM OKC_K_LINES_B LINE
     WHERE LINE.CLE_ID = P_CLE_ID
       AND LINE.LSE_ID = 25 ;

    CURSOR L_GET_BCL_ID_CSR ( P_CLE_ID NUMBER ) IS
    SELECT CONT.ID
      FROM OKS_BILL_CONT_LINES CONT
     WHERE CLE_ID = P_CLE_ID ;

    CURSOR L_LINE_AMT_CSR ( P_CLE_ID NUMBER ) IS
    SELECT SUM(PRICE_NEGOTIATED)
      FROM OKC_K_LINES_B LINE
     WHERE LINE.CLE_ID = P_CLE_ID
       AND LINE.LSE_ID = 25 ;

    CURSOR L_BCL_CONT_LINE_EXISTS_CSR ( P_CLE_ID NUMBER )  IS
    SELECT ID
      FROM OKS_BILL_CONT_LINES
     WHERE CLE_ID = P_CLE_ID ;

    CURSOR L_GET_ORDER_NUMBER_CSR ( P_SUB_LINE_ID NUMBER ) IS
    SELECT OBJECT1_ID1
      FROM OKC_K_REL_OBJS
     WHERE CLE_ID = P_SUB_LINE_ID ;


     L_LINES_REC        L_LINES_CSR%ROWTYPE ;
     L_LINE_AMT_REC     L_LINE_AMT_CSR%ROWTYPE ;
     L_BCL_CONT_LINE_EXISTS_REC L_BCL_CONT_LINE_EXISTS_CSR%ROWTYPE ;
     L_GET_ORDER_NUMBER_REC  L_GET_ORDER_NUMBER_CSR%ROWTYPE ;

     TYPE LEVEL_ID_REC    IS RECORD (
     L_LEVEL_ID  NUMBER );
     SUBTYPE LEVEL_ID_TBL IS OKS_BILL_LEVEL_ELEMENTS_PVT.letv_tbl_type ;
     L_LEVEL_ID_TBL   LEVEL_ID_TBL ;
     L_letv_tbl       LEVEL_ID_TBL ;



	lin_id  number;
     l_return_status    Varchar2(1):= OKC_API.G_RET_STS_SUCCESS;
     l_msg_cnt          Number;
     l_msg_data         Varchar2(2000);
     l_ar_inv_date      Date;
     l_line_id          number ;
     l_calc_sdate       Date ;
     l_calc_edate       Date ;
     L_BCL_ID           NUMBER ;
     bcl_id_sub           NUMBER ;
     L_LINE_AMOUNT      NUMBER := 0 ;
     COUNTER            NUMBER ;
     l_msg_count         number;
     L_CONTINUE_PROCESSING BOOLEAN :=FALSE ;

     INSERT_BCL__EXCEPTION EXCEPTION ;
     G_EXCEPTION_HALT_VALIDATION exception ;

     SUBTYPE l_bslv_tbl_type_in  is OKS_bsl_PVT.bslv_tbl_type;
     l_bslv_tbl_in  l_bslv_tbl_type_in ;
     l_bslv_tbl_out l_bslv_tbl_type_in ;

     SUBTYPE l_bclv_tbl_type_in  is OKS_bcl_PVT.bclv_tbl_type;
     l_bclv_tbl_in   l_bclv_tbl_type_in;
     l_bclv_tbl_out  l_bclv_tbl_type_in;

     SUBTYPE l_bcl_tbl_type_in  is OKS_bcl_PVT.bclv_tbl_type;
     l_bcl_tbl_in   l_bcl_tbl_type_in;
     l_bcl_tbl_out  l_bcl_tbl_type_in;

     LEVEL_REC    OKS_BILL_LEVEL_ELEMENTS_PVT.LETV_REC_TYPE;
     GET_REC      OKS_BILL_LEVEL_ELEMENTS_PVT.LETV_REC_TYPE;

     TYPE L_TOP_LINE_REC IS RECORD (
      TOP_LINE_ID  NUMBER
     ,UPG_ORIG_SYSTEM_REF VARCHAR2(60)
     );

    TYPE L_TOP_LINE_TBL IS TABLE OF L_TOP_LINE_REC INDEX BY BINARY_INTEGER ;

    TYPE L_SUB_LINE_REC IS RECORD (
     SUB_LINE_ID NUMBER
    ,UPG_ORIG_SYSTEM_REF VARCHAR2(6)
    ,UPG_ORIG_SYSTEM_REF_ID NUMBER
    );

    TYPE L_SUB_LINE_TBL  IS TABLE OF L_SUB_LINE_REC INDEX BY BINARY_INTEGER ;


    L_CLEV_TBL_IN                         OKC_CONTRACT_PUB.CLEV_TBL_TYPE;
    L_CLEV_TBL_OUT                        OKC_CONTRACT_PUB.CLEV_TBL_TYPE;

    l_top_line_counter number := 0 ;
    l_sub_line_counter number := 0 ;
    L_LINE_COUNTER NUMBER := 0 ;

   FUNCTION get_seq_id RETURN NUMBER IS
    BEGIN
       RETURN(okc_p_util.raw_to_number(sys_guid()));
    END get_seq_id;


   BEGIN
       L_BCL_CONT_LINE_EXISTS_REC.ID := NULL ;

       OPEN  L_BCL_CONT_LINE_EXISTS_CSR ( p_top_line_id  ) ;
       FETCH L_BCL_CONT_LINE_EXISTS_CSR INTO L_BCL_CONT_LINE_EXISTS_REC ;
       CLOSE L_BCL_CONT_LINE_EXISTS_CSR ;

      IF L_BCL_CONT_LINE_EXISTS_REC.ID IS NULL  THEN

         l_bcl_tbl_in(1).CLE_ID            := p_top_line_id  ;
         l_bcl_tbl_in(1).DATE_BILLED_FROM  := p_top_line_start_date  ;
         l_bcl_tbl_in(1).DATE_BILLED_TO    := NVL(p_top_line_date_terminated  ,p_top_line_end_date ) ;
         l_bcl_tbl_in(1).Date_Next_Invoice := NULL;
         l_bcl_tbl_in(1).BILL_ACTION       := 'RI';
         l_bcl_tbl_in(1).sent_yn           := 'N';

	    lin_id := get_seq_id;
         bcl_id_sub  := lin_id;

	    insert into oks_bill_cont_lines
	              (id, cle_id, date_billed_from, date_billed_to, sent_yn, object_version_number,
		          created_by, creation_date, last_updated_by, last_update_date, bill_action, btn_id)
		values
		         (lin_id, p_top_line_id , p_top_line_start_date, p_top_line_end_date, 'N',
				1, 1, sysdate, 1, sysdate, 'RI', -44);

         update okc_k_lines_b
            set UPG_ORIG_SYSTEM_REF =  NVL(p_top_line_UPG_ORIG_SYSTEM_REF, 'ORDER')
          where id = p_top_line_id;

         FOR L_SUB_LINES_REC IN L_SUB_LINES_CSR ( p_top_line_id )
         LOOP

              L_LINE_AMOUNT        :=L_LINE_AMOUNT + NVL( L_SUB_LINES_REC.PRICE_NEGOTIATED , 0 ) ;
		    lin_id := get_seq_id;

     	    insert into oks_bill_sub_lines
	          (id, cle_id, bcl_id, date_billed_from, date_billed_to, amount, object_version_number,
		    created_by, creation_date, last_updated_by, last_update_date)
              values
		     (lin_id, L_SUB_LINES_REC.ID, bcl_id_sub, L_sub_LINES_REC.START_DATE, L_sub_LINES_REC.END_DATE,
		      NVL(L_SUB_LINES_REC.PRICE_NEGOTIATED , 0 ),1,1, sysdate,1, sysdate
	           );

              OPEN  L_GET_ORDER_NUMBER_CSR ( L_SUB_LINES_REC.ID );
              FETCH L_GET_ORDER_NUMBER_CSR INTO L_GET_ORDER_NUMBER_REC ;
              CLOSE L_GET_ORDER_NUMBER_CSR ;

		    update okc_k_lines_b
		    set UPG_ORIG_SYSTEM_REF =  NVL(L_SUB_LINES_REC.UPG_ORIG_SYSTEM_REF, 'ORDER_LINE'),
		    UPG_ORIG_SYSTEM_REF_ID = L_GET_ORDER_NUMBER_REC.OBJECT1_ID1
		    where id = L_SUB_LINES_REC.ID;

         end loop;

         update oks_bill_cont_lines
	    set amount = l_line_amount
         where id = bcl_id_sub;

         L_LINE_AMOUNT := 0 ;

         L_CONTINUE_PROCESSING := TRUE ;
     END IF ;

     IF L_CONTINUE_PROCESSING AND L_RETURN_STATUS =  OKC_API.G_RET_STS_SUCCESS THEN
         UPDATE_OKS_LEVEL_ELEMENTS( P_DNZ_CHR_ID ,
                                    X_RETURN_STATUS );
            IF (L_RETURN_STATUS <> 'S') THEN
                X_RETURN_STATUS := L_RETURN_STATUS;
                Raise G_EXCEPTION_HALT_VALIDATION;
            END IF;
     END IF ;


   X_RETURN_STATUS := L_RETURN_STATUS;

   EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        X_RETURN_STATUS  := l_return_status ;
      WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);



END CREATE_BILL_DTLS ;




PROCEDURE UPDATE_OKS_LEVEL_ELEMENTS
    ( p_dnz_chr_id IN number ,
      x_return_status OUT NOCOPY varchar2 ) IS

 G_EXCEPTION_HALT_VALIDATION exception ;


BEGIN

update oks_level_elements
set date_completed = sysdate
where dnz_chr_id = p_dnz_chr_id;

X_RETURN_STATUS := 'S' ;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);


END  UPDATE_OKS_LEVEL_ELEMENTS ;


END OKS_BILL_MIGRATION;

/
