--------------------------------------------------------
--  DDL for Package Body OKS_FULFILL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_FULFILL" AS
/* $Header: OKSFULFB.pls 120.4 2007/12/24 07:30:00 rriyer ship $*/

--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below
   -- OKS_FULFILL_MAIN

--  Global constant holding the package name
         G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OKS_BILLING_PVT' ;

-- Global var holding the Current Error code for the error encountered
         Current_Error_Code  Varchar2(20) := NULL;

-- Global var holding the User Id
         user_id          NUMBER;

-- Global var to hold the ERROR value.
         ERROR            NUMBER := 0;

-- Global var to hold the SUCCESS value.
         SUCCESS          NUMBER := 1;

-- Global var to hold the commit size.
         COMMIT_SIZE	  NUMBER := 10;

-- Global var to hold the Concurrent Process return value
         conc_ret_code   NUMBER := SUCCESS;

-- Global constant for the threshold count before splitting into sub-requests
         MAX_SINGLE_REQUEST	NUMBER := 500;

-- Global constant for the maximum allowed sub-requests (parallel workers)
         MAX_JOBS		NUMBER := 20;

-- Global vars to hold the min and max hdr_id for each sub-request range
-- Global vars to hold the min and max line_id for each sub-request range
-- Bug 4915691 --
	 type range_rec is record (
              lo number,
              hi number,
	      line_id_lo NUMBER,
	      line_id_hi NUMBER);

-- Bug 4915691 --
         type rangeArray is VARRAY(50) of range_rec;
         range_arr rangeArray;


procedure split_range (
  p_lo number,
  p_hi number,
   P_default_date    IN DATE,
  p_org_id          IN NUMBER,
  P_Customer_id     IN NUMBER,
  P_Grp_Id          IN NUMBER,
  p_buckets number) is
  l_lo number := p_lo;
  l_idx1 number := range_arr.count + 1;
  l_idx2 number := range_arr.count + p_buckets;
  l_bucket_width integer;

  -- Bug 4915691 --
  -- Added logic to filter data based on Subscr elements
  -- processed for a Subscription line
  -- Added condition to fetch line id from OKC_K_LINES_B

  CURSOR chr_csr IS
       SELECT hdr.id id
           ,  line.id line_id
       FROM
                OKC_K_GRPINGS        okg
               ,OKC_K_PARTY_ROLES_B  okp
               ,OKC_K_HEADERS_B      Hdr
               ,OKC_STATUSES_B      st
	       ,OKC_K_LINES_B       line
        Where  Hdr.scs_code = 'SUBSCRIPTION'
        And    Hdr.Template_yn = 'N'
        And    Hdr.sts_code = st.CODE
        AND    st.ste_code in ('ACTIVE','SIGNED','EXPIRED','TERMINATED')
        AND    hdr.sts_code <> 'QA_HOLD'
        And    Hdr.authoring_org_id = NVL(p_org_id, Hdr.authoring_org_id)
        And    okp.chr_id   =  hdr.id
        And    line.dnz_chr_id = Hdr.id
        And    line.lse_id = 46
        And    okp.rle_code = 'SUBSCRIBER'
        And    okp.object1_id1 = nvl(p_customer_id,okp.object1_id1)
        And    okg.included_chr_id = hdr.id
        And    okg.cgp_parent_id = nvl(p_grp_id,okg.cgp_parent_id)
        And    EXISTS  (Select 1 from  OKS_SUBSCR_ELEMENTS  sub
 	                          Where     sub.dnz_chr_id = hdr.id
 	                          And    sub.dnz_cle_id = line.id
 	                          And    sub.order_header_id  is null)
      /* Commented by sjanakir for Bug# 5568285 (FP Bug for 5442268) */
      /* Order By  hdr.id ; */
      /* Added by sjanakir for Bug# 5568285 (FP Bug for 5442268) */
       	Order By  line.id ;
      /* Addition Ends */
  CURSOR chr_csr_no_para IS
       SELECT hdr.id id
            , line.id line_id
       FROM
               OKC_K_HEADERS_B      Hdr
               ,OKC_STATUSES_B      st
               ,OKC_K_LINES_B       line
        Where  Hdr.scs_code = 'SUBSCRIPTION'
        And    Hdr.Template_yn = 'N'
        And    Hdr.sts_code = st.CODE
        AND    st.ste_code in ('ACTIVE','SIGNED','EXPIRED','TERMINATED')
        AND    Hdr.sts_code <> 'QA_HOLD'
	And    line.dnz_chr_id = Hdr.id
        And    line.lse_id = 46
	And    EXISTS  (Select 1 from  OKS_SUBSCR_ELEMENTS  sub
 	                          Where     sub.dnz_chr_id = hdr.id
 	                          And    sub.dnz_cle_id = line.id
 	                          And    sub.order_header_id  is null)
        Order By  hdr.id ;
 -- Bug 4915691 --

TYPE t_k_number is  TABLE of number index by binary_integer;
c_k_number t_k_number;
c_k_line   t_k_number; -- Bug 4915691 --

c_k_index BINARY_INTEGER ;
v_total number;
x number;
begin
 fnd_file.put_line(FND_FILE.LOG, 'INSIDE SPLIT RANGE');
 fnd_file.put_line(FND_FILE.LOG, 'p_lo = '|| p_lo);
 fnd_file.put_line(FND_FILE.LOG, 'p_hi = '|| p_hi);
 fnd_file.put_line(FND_FILE.LOG, 'p_buckets = '|| p_buckets);
   if p_buckets = 0 then
	return;
  end if;
 c_k_number(1) := 0;
 c_k_index:=   1;

  IF p_org_id is null and p_customer_id  is null and p_grp_id is null then
  for c_chr_csr_no_para in chr_csr_no_para loop
    c_k_number(c_k_index) := c_chr_csr_no_para.id;
    c_k_line(c_k_index)   := c_chr_csr_no_para.line_id; -- Bug 4915691 --
    fnd_file.put_line(FND_FILE.LOG, 'c_k_number('||c_k_index||') = '|| c_k_number(c_k_index));
    c_k_index := c_k_index + 1;
  end loop;
  ELSE
  for c_chr_csr in chr_csr loop
    c_k_number(c_k_index) := c_chr_csr.id;
    c_k_line(c_k_index)   := c_chr_csr.line_id; -- Bug 4915691 --
    fnd_file.put_line(FND_FILE.LOG, 'c_k_number('||c_k_index||') = '|| c_k_number(c_k_index));
    c_k_index := c_k_index + 1;
  end loop;
  END IF;

  v_total := c_k_number.count;
 fnd_file.put_line(FND_FILE.LOG, 'v_total = '|| v_total);
 fnd_file.put_line(FND_FILE.LOG, 'range_arr.count = '|| range_arr.count);
  if range_arr.count > 0 then
	-- so we don't overlap high value of previous range
	l_lo := p_lo + 1;
  end if;
 -- c_k_index:=   c_k_number.first;
    c_k_index:=   1;
  if v_total < p_buckets then
    l_bucket_width := 1;
 l_idx2 := range_arr.count + v_total;
    range_arr.extend(v_total);
    Else
  l_bucket_width := trunc(v_total / p_buckets);
  fnd_file.put_line(FND_FILE.LOG, 'l_bucket_width = '|| l_bucket_width);
  range_arr.extend(p_buckets);
    End if;

  fnd_file.put_line(FND_FILE.LOG, 'l_idx1 = '|| l_idx1);
  fnd_file.put_line(FND_FILE.LOG, 'l_idx2 = '|| l_idx2);
    for idx in l_idx1..l_idx2 loop

    range_arr(idx).lo := c_k_number(c_k_index + ((idx - l_idx1) * l_bucket_width));
    range_arr(idx).line_id_lo := c_k_line(c_k_index + ((idx - l_idx1) * l_bucket_width)); -- Bug 4915691 --

    x := c_k_index + ((idx - l_idx1) * l_bucket_width);
    fnd_file.put_line(FND_FILE.LOG, '1...X = ' ||x);
	if idx < l_idx2 then
		range_arr(idx).hi := c_k_number(c_k_index+((idx - l_idx1+1) * l_bucket_width)-1);
		range_arr(idx).line_id_hi := c_k_line(c_k_index+((idx - l_idx1+1) * l_bucket_width)-1); -- Bug 4915691 --
        x := c_k_index+((idx - l_idx1+1) * l_bucket_width)-1;
            fnd_file.put_line(FND_FILE.LOG, '2...X = ' ||x);
	else
		range_arr(idx).hi := p_hi;
		range_arr(idx).line_id_hi := c_k_line(v_total);
	end if;
    fnd_file.put_line(FND_FILE.LOG, 'range_arr('||idx||').lo = '|| range_arr(idx).lo);
    fnd_file.put_line(FND_FILE.LOG, 'range_arr('||idx||').hi = '|| range_arr(idx).hi);

    end loop;
 fnd_file.put_line(FND_FILE.LOG, 'DONE SPLIT RANGE');
end split_range;




function generate_ranges (
	p_lo number,
	p_hi number,
        P_default_date    IN DATE,
        p_org_id          IN NUMBER,
        P_Customer_id     IN NUMBER,
        P_Grp_Id          IN NUMBER,
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
 fnd_file.put_line(FND_FILE.LOG, 'BEGIN GENERATE RANGE');
 	range_arr := rangeArray();
	-- number of buckets is set to 20

 fnd_file.put_line(FND_FILE.LOG, 'p_total = ' || p_total);
 fnd_file.put_line(FND_FILE.LOG, 'p_lo = ' || p_lo);
fnd_file.put_line(FND_FILE.LOG, 'p_hi = ' || p_hi);
fnd_file.put_line(FND_FILE.LOG, 'l_stdlo = ' || l_stdlo);
fnd_file.put_line(FND_FILE.LOG, 'l_stdhi = ' || l_stdhi);

    IF p_total <= 20 THEN
     l_total_buckets := p_total;
    ELSE
    	l_total_buckets := MAX_JOBS;
        END IF;

  fnd_file.put_line(FND_FILE.LOG, 'l_total_buckets = ' || l_total_buckets);

    IF p_total <= 20 THEN
    --	split_range(p_lo, p_hi, l_total_buckets);
split_range(p_lo, p_hi, P_default_date,
    p_org_id ,
    P_Customer_id,
    P_Grp_Id,l_total_buckets);
    ELSE
 	/*-- ranges for negative outliers
	split_range(p_lo, l_stdlo, 2);
	-- ranges for +/-1 stddev from mean
	split_range(l_stdlo, l_stdhi, 16);
	-- ranges for positive outliers
	split_range(l_stdhi, p_hi, 2);
*/
--split_range(p_lo, p_hi, l_total_buckets);
split_range(p_lo,
    p_hi,
    p_default_date,
    p_org_id ,
    p_Customer_id,
    p_Grp_Id,
    l_total_buckets);
     END IF;
fnd_file.put_line(FND_FILE.LOG, 'END GENERATE RANGE');
 return l_total_buckets;

/*
	l_outlier_buckets := l_total_buckets * (1 - l_stddev_percent);
 fnd_file.put_line(FND_FILE.LOG, 'l_outlier_buckets = ' || l_outlier_buckets);
 	if l_outlier_buckets > 0 then
	   l_outlier_entries_per_bucket := p_total * (1 - l_stddev_percent)
					/ l_outlier_buckets ;
 fnd_file.put_line(FND_FILE.LOG, 'l_outlier_entries_per_bucket = ' || l_outlier_entries_per_bucket);
 	end if;
	for idx in 1..l_outlier_buckets loop
		modidx := mod(idx,2);
		-- alternate assignment between hi and lo buckets
 fnd_file.put_line(FND_FILE.LOG, 'modidx = ' || modidx);
 		if modidx = 1
		   AND (p_hi - (l_hi_buckets+1) * l_outlier_entries_per_bucket)
		   > l_stdhi then
			-- allocate buckets for positive outliers
			l_hi_buckets := l_hi_buckets + 1;
 fnd_file.put_line(FND_FILE.LOG, '---- l_hi_buckets = ' || l_hi_buckets);
 		elsif modidx = 0
		   AND (p_lo + (l_lo_buckets+1) * l_outlier_entries_per_bucket)
		   < l_stdlo then
			-- allocate buckets for negative outliers
			l_lo_buckets := l_lo_buckets + 1;
 fnd_file.put_line(FND_FILE.LOG, '---- l_lo_buckets = ' || l_lo_buckets);
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
*/
/*
fnd_file.put_line(FND_FILE.LOG, 'p_lo = ' || p_lo);
fnd_file.put_line(FND_FILE.LOG, 'p_hi = ' || p_hi);
fnd_file.put_line(FND_FILE.LOG, 'l_stdlo = ' || l_stdlo);
fnd_file.put_line(FND_FILE.LOG, 'l_stdhi = ' || l_stdhi);
--fnd_file.put_line(FND_FILE.LOG, 'l_lo_buckets = ' || l_lo_buckets);
--fnd_file.put_line(FND_FILE.LOG, 'l_hi_buckets = ' || l_hi_buckets);
--fnd_file.put_line(FND_FILE.LOG, 'l_std_buckets = ' || l_std_buckets);
 	-- ranges for negative outliers
	split_range(p_lo, l_stdlo, 2);
	-- ranges for +/-1 stddev from mean
	split_range(l_stdlo, l_stdhi, 16);
	-- ranges for positive outliers
	split_range(l_stdhi, p_hi, 2);
      fnd_file.put_line(FND_FILE.LOG, 'l_total_buckets = ' || l_total_buckets);
	return l_total_buckets;
*/

end generate_ranges;


PROCEDURE  Submit
(
ERRBUF OUT NOCOPY VARCHAR2,
RETCODE OUT NOCOPY NUMBER,
p_contract_hdr_id	IN NUMBER,
P_default_date    IN VARCHAR2,
p_org_id          IN NUMBER,
P_Customer_id     IN NUMBER,
P_Grp_Id          IN NUMBER
) is
  -- Bug 4915691 --
  -- Added logic to filter data based on Subscr elements
  -- processed for a Subscription line
  -- Subscription lines which have already been processed should not be
  -- selected
 Cursor l_fulfill_agg_csr IS
        Select min(hdr.id) minid,
			   max(hdr.id) maxid,
			   avg(hdr.id) avgid,
			   stddev(hdr.id) stdid,
			   count(*) total
        From
                OKC_K_GRPINGS        okg
               ,OKC_K_PARTY_ROLES_B  okp
	       ,OKC_K_HEADERS_B Hdr
               ,OKC_STATUSES_B ST
        Where  Hdr.scs_code = 'SUBSCRIPTION'
        And    Hdr.Template_yn = 'N'
        And    Hdr.sts_code = st.CODE
        AND    st.ste_code in ('ACTIVE','SIGNED','EXPIRED','TERMINATED')
        AND    hdr.sts_code <> 'QA_HOLD'
	And    Hdr.authoring_org_id = NVL(p_org_id, Hdr.authoring_org_id)
        And    okp.chr_id   =  hdr.id
        And    okp.rle_code = 'SUBSCRIBER'
        And    okp.object1_id1 = nvl(p_customer_id,okp.object1_id1)
        And    okg.included_chr_id = hdr.id
        And    okg.cgp_parent_id = nvl(p_grp_id,okg.cgp_parent_id)
	And     EXISTS  (Select 1 from  OKS_SUBSCR_ELEMENTS  sub
         	 	 Where  sub.dnz_chr_id = hdr.id
                          And    sub.order_header_id  is null);

 Cursor l_fulfill_agg_csr_no_para IS
        Select min(hdr.id) minid,
			   max(hdr.id) maxid,
			   avg(hdr.id) avgid,
			   stddev(hdr.id) stdid,
			   count(*) total
        From
               OKC_K_HEADERS_B Hdr
               ,OKC_STATUSES_B ST
        Where  Hdr.scs_code = 'SUBSCRIPTION'
        And    Hdr.Template_yn = 'N'
        And    Hdr.sts_code = st.CODE
	AND    st.ste_code in ('ACTIVE','SIGNED','EXPIRED','TERMINATED')
        AND    hdr.sts_code <> 'QA_HOLD'
	And     EXISTS  (Select 1 from  OKS_SUBSCR_ELEMENTS  sub
         	 	 Where     sub.dnz_chr_id = hdr.id
                         And    sub.order_header_id  is null);
     -- Bug 4915691 --


        l_agg_rec		l_fulfill_agg_csr%ROWTYPE;
        CONC_STATUS		BOOLEAN;
        l_retcode		NUMBER;
        l_msg_count 	        NUMBER;
        l_msg_data 		VARCHAR2(2000);
        l_ret			INTEGER;
        l_subrequests    	INTEGER;
        l_errbuf		VARCHAR2(240);
        l_return_status         VARCHAR2(1);
        use_parallel_worker VARCHAR2(1);
        v_index BINARY_INTEGER;
	l_default_date          DATE;

BEGIN
l_default_date := to_date(P_default_date,'YYYY/MM/DD HH24:MI:SS');

null;
IF p_contract_hdr_id is not null then
 use_parallel_worker := 'N';
ELSE
  IF p_org_id is null and p_customer_id is null and p_grp_id is null then
   OPEN l_fulfill_agg_csr_no_para;
   FETCH l_fulfill_agg_csr_no_para INTO l_agg_rec;
   CLOSE l_fulfill_agg_csr_no_para;
  ELSE
   OPEN l_fulfill_agg_csr;
   FETCH l_fulfill_agg_csr INTO l_agg_rec;
   CLOSE l_fulfill_agg_csr;
  END IF;
   use_parallel_worker := 'Y';
   fnd_file.put_line(FND_FILE.LOG, 'P_parallel = ' || use_parallel_worker);

END IF;

 fnd_file.put_line(FND_FILE.LOG, 'P_parallel = ' || use_parallel_worker);
 fnd_file.put_line(FND_FILE.LOG, 'l_agg_rec.minid = ' || l_agg_rec.minid);
 fnd_file.put_line(FND_FILE.LOG, 'l_agg_rec.maxid = ' || l_agg_rec.maxid);
 fnd_file.put_line(FND_FILE.LOG, 'l_agg_rec.avgid = ' || l_agg_rec.avgid);
 fnd_file.put_line(FND_FILE.LOG, 'l_agg_rec.stdid = ' || l_agg_rec.stdid);
 fnd_file.put_line(FND_FILE.LOG, 'l_agg_rec.total = ' || l_agg_rec.total);

IF use_parallel_worker = 'Y' THEN
/* Added by sjanakir for Bug# 5568285 (FP Bug for 5442268) */
  IF l_agg_rec.total = 0 THEN
    FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '***************Subscription Contract to Order Creation****************** ');
    FND_FILE.PUT_LINE( FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE( FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '***************No subscription elements to be interfaced**************** ');
  END IF;
/* Addition Ends */

l_subrequests := generate_ranges(l_agg_rec.minid, l_agg_rec.maxid,
l_default_date    ,
    p_org_id          ,
    P_Customer_id     ,
    P_Grp_Id , l_agg_rec.avgid,
    l_agg_rec.stdid, l_agg_rec.total);

fnd_file.put_line(FND_FILE.LOG, 'l_subrequests = ' || l_subrequests);
FOR idx in 1..l_subrequests LOOP

l_ret := FND_REQUEST.submit_request('OKS','OKSKTOCR',
				null, null, -- TRUE means isSubRequest
				null, null,
				/* Commented by sjanakir for Bug# 5568285 (FP Bug for 5442268) */
				/* l_default_date, null,
				null, null, */
				/* Added by sjanakir for Bug# 5568285 (FP Bug for 5442268) */
				l_default_date, P_Customer_id,
				P_Grp_Id , p_org_id,
				/* Addition Ends */
				range_arr(idx).lo, range_arr(idx).hi,
			        range_arr(idx).line_id_lo, range_arr(idx).line_id_hi); -- Bug 4915691 --

 fnd_file.put_line(FND_FILE.LOG, 'idx = ' || idx);
 fnd_file.put_line(FND_FILE.LOG, 'l_ret.lo = ' || range_arr(idx).lo);
 fnd_file.put_line(FND_FILE.LOG, 'l_ret.hi = ' || range_arr(idx).hi);
-- fnd_file.put_line(FND_FILE.LOG, 'l_ret = ' || l_ret);

		IF (l_ret = 0) then
			errbuf := fnd_message.get;
			retcode := 2;
			FND_FILE.PUT_LINE (FND_FILE.LOG,
				'Sub-request failed to submit: ' || errbuf);
			return;
		ELSE
			FND_FILE.PUT_LINE (FND_FILE.LOG,
			'Sub-request '||to_char(l_ret)||' submitted');
		END IF;
END LOOP;
ELSE
oks_kto_int_pub.create_order_from_k(ERRBUF     => l_errbuf
			        ,RETCODE    => l_retcode
                    ,p_contract_id     => p_contract_hdr_id
                    ,p_default_date    => l_default_date
                    ,P_Customer_id   => p_customer_id
                    ,P_Grp_id          => p_grp_id
                    ,P_org_id          => p_org_id
	            ,P_contract_hdr_id_lo => null
                     ,P_contract_hdr_id_hi => null
		    -- Bug 4915691 --
		    ,p_contract_line_id_lo => null
                    ,p_contract_line_id_hi => null
		    -- Bug 4915691 --
                             );

END IF;
END SUBMIT;

   -- Enter further code below as specified in the Package spec.
END OKS_FULFILL;


/
