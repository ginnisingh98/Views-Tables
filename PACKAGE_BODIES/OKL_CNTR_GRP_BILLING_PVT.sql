--------------------------------------------------------
--  DDL for Package Body OKL_CNTR_GRP_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CNTR_GRP_BILLING_PVT" AS
/* $Header: OKLRCLBB.pls 120.8 2008/02/25 12:11:14 udhenuko noship $ */

  PROCEDURE counter_grp_billing_calc(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
	,p_cntr_bill_rec                IN cntr_bill_rec_type
    ,x_cntr_bill_rec                OUT NOCOPY cntr_bill_rec_type
    ) IS
---------------------------
-- DECLARE Local Variables
---------------------------

    l_api_version        NUMBER          := 1.0;
    l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    i                    NUMBER;


  BEGIN
    NULL ;
  END;


  PROCEDURE counter_grp_billing_calc(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
	,p_cntr_bill_tbl                IN cntr_bill_tbl_type
    ,x_cntr_bill_tbl                OUT NOCOPY cntr_bill_tbl_type
	) IS

---------------------------
-- DECLARE Local Variables
---------------------------

    l_api_name	        CONSTANT VARCHAR2(30) := 'OKL_CNTR_GRP_BILLING_PVT';
    l_api_version        NUMBER          := 1.0;
    l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    i                    NUMBER;
    j                    NUMBER;

    l_clc_ext            EXCEPTION;

------------------------------
-- DECLARE Record/Table Types
------------------------------

    l_bill_rec                  bill_rec_type;
    x_bill_rec                  bill_rec_type;
    l_bill_tbl                  bill_tbl_type;
    x_bill_tbl                  bill_tbl_type;
    l_cntr_bill_rec             cntr_bill_rec_type;
    x_cntr_bill_rec             cntr_bill_rec_type;
    l_cntr_bill_tbl             cntr_bill_tbl_type := p_cntr_bill_tbl;

 -------------------
-- DECLARE Cursors
-------------------


  BEGIN

    	x_return_status := OKL_API.G_RET_STS_SUCCESS;

   	l_return_status := OKL_API.START_ACTIVITY(
    		p_api_name	    => l_api_name,
        	p_pkg_name	    => g_pkg_name,
    		p_init_msg_list	=> p_init_msg_list,
    		l_api_version	=> l_api_version,
    		p_api_version	=> p_api_version,
    		p_api_type	    => '_PVT',
    		x_return_status	=> l_return_status);

  	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
   		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    	RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


--    dbms_output.put_line('Count of Rec: '||l_cntr_bill_tbl.COUNT);

   IF (l_cntr_bill_tbl.COUNT > 0) THEN
     i := l_cntr_bill_tbl.FIRST;
    --dbms_output.put_line('Count of Rec: I '||i);
     LOOP

        l_cntr_bill_rec := l_cntr_bill_tbl(i);

    --  Assign the values for columns of bill_rec from cntr_bill_rec record
        l_bill_rec.Counter_id    :=  l_cntr_bill_rec.counter_number;
        l_bill_rec.Reading_date  :=  l_cntr_bill_rec.counter_reading_date;
        l_bill_rec.Meter_reading :=  l_cntr_bill_rec.counter_reading;
        l_bill_rec.Last_Meter_reading :=  null;
        l_bill_rec.Net_reading   :=  null;
        l_bill_rec.Level_reading :=  null;
        l_bill_rec.Bill_amount   :=  null;

        l_bill_tbl(i) := l_bill_rec;

    --dbms_output.put_line('Value of Counter Id '||l_bill_rec.Counter_id);
        EXIT WHEN (i = l_cntr_bill_tbl.LAST);
        i := l_cntr_bill_tbl.NEXT(i);

  END LOOP;

  --Calling the Calculate procedure in OKS

    --dbms_output.put_line('Before Oks Call Status '||x_return_status);
    x_msg_data      := l_msg_data;

    oks_bill_util_pub.Calculate_Bill_Amount (
    p_api_version        =>  l_api_version,
    p_init_msg_list      =>  l_init_msg_list,
    p_bill_tbl           =>  l_bill_tbl,
    x_return_status      =>  l_return_status,
    x_msg_count          =>  l_msg_count,
    x_msg_data           =>  l_msg_data);

    x_return_status := l_return_status;
    x_msg_data      := l_msg_data;
    x_msg_count     := l_msg_count;
    x_bill_tbl      := l_bill_tbl;
    x_cntr_bill_tbl := p_cntr_bill_tbl;
    --dbms_output.put_line('After Oks Call Status '||x_return_status);

    --Assign the bill_amount from out record to the counter_bill_amount

   IF (x_bill_tbl.COUNT > 0) THEN
     i := x_bill_tbl.FIRST;
     j := x_cntr_bill_tbl.FIRST;

      LOOP

        x_cntr_bill_rec := x_cntr_bill_tbl(j);
        x_bill_rec := x_bill_tbl(i);

        --dbms_output.put_line('Amount in Bill Rec is ' || x_bill_rec.Bill_amount);
    --  Assign the values for columns of bill_rec from cntr_bill_rec record
        x_cntr_bill_rec.counter_bill_amount    :=  x_bill_rec.Bill_amount;

        x_cntr_bill_tbl(j) := x_cntr_bill_rec;

        EXIT WHEN (i = x_cntr_bill_tbl.LAST);
        i := x_bill_tbl.NEXT(i);
        j := x_cntr_bill_tbl.NEXT(j);

      END LOOP;

     END IF;

   END IF;

  IF (x_return_status = Fnd_Api.G_RET_STS_ERROR)  THEN
    RAISE l_clc_ext;
  ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE l_clc_ext;
  END IF;
	OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);

  EXCEPTION
    WHEN l_clc_ext THEN
        x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        l_msg_data := 'Problems with Calculate';
        x_msg_data := l_msg_data ;

    WHEN others THEN
    --dbms_output.put_line('In Exception '||l_msg_count||'data: '||l_msg_data);
        x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        l_msg_data := '';
        x_msg_data := l_msg_data ;

  END counter_grp_billing_calc;

  PROCEDURE counter_grp_billing_insert(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
	,p_cntr_bill_rec                IN cntr_bill_rec_type
    ,x_cntr_bill_rec                OUT NOCOPY cntr_bill_rec_type
    ) IS
---------------------------
-- DECLARE Local Variables
---------------------------

  BEGIN
    NULL ;
  END;

  PROCEDURE counter_grp_billing_insert(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
	,p_cntr_bill_tbl                IN cntr_bill_tbl_type
    ,x_cntr_bill_tbl                OUT NOCOPY cntr_bill_tbl_type
    ) IS

---------------------------
-- DECLARE Local Variables
---------------------------
    l_api_name	        CONSTANT VARCHAR2(30) := 'OKL_CNTR_GRP_BILLING_PVT';

    l_api_version        NUMBER          := 1.0;
    l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_contract_num      OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    l_cntr_num          NUMBER;
    l_amount            NUMBER;
    l_khr_id            OKC_K_HEADERS_B.ID%TYPE;
    l_kle_id            OKC_K_LINES_B.ID%TYPE;
    l_try_id            okl_trx_types_tl.ID%TYPE;
    l_clg_id            NUMBER;
    l_asset_name        okc_k_lines_v.name%type;                --added by dkagrawa for bug#6015684

    --for install base api
    l_cntr_grp_id       NUMBER;
    l_cntr_prop_id      NUMBER;
    l_cntr_prop_val     cs_counter_properties.default_value%TYPE;
    l_counter_reading   NUMBER;

    i                   NUMBER      := 1;

    l_ins_ext           EXCEPTION;
    l_sty_id                        okl_strm_type_v.id%TYPE;

----------------------------
-- DECLARE Records/Tables
----------------------------

    l_cntr_bill_tbl     cntr_bill_tbl_type := p_cntr_bill_tbl;
    l_cntr_bill_rec     cntr_bill_rec_type;

    l_taiv_rec          taiv_rec_type;
    lx_taiv_rec         taiv_rec_type;

    l_tilv_rec          tilv_rec_type;
    lx_tilv_rec         tilv_rec_type;

    l_tldv_rec          tldv_rec_type;
    lx_tldv_rec         tldv_rec_type;

    l_ctr_grp_log_rec   crdg_rec_type;
    l_ctr_rdg_tbl       crdg_tbl_type;
    l_prop_rdg_tbl      prdg_tbl_type;

	------------------------------------------------------------
	-- Declare variables to call Accounting Engine.
	------------------------------------------------------------
	p_bpd_acc_rec					Okl_Acc_Call_Pub.bpd_acc_rec_type;


---------------------------
-- DECLARE Cursors
---------------------------


    CURSOR l_khr_cur(l_contract_num IN VARCHAR2) IS
            SELECT  HDR.ID KHR_ID
            FROM    OKC_K_HEADERS_B HDR
            WHERE   CONTRACT_NUMBER = l_contract_num;

  	    --dkagrawa modified the following cursor for bug#6015684
	    CURSOR l_lines_cur(l_asset_name IN VARCHAR2,l_chr_id in number) IS
	    SELECT  cle.id KLE_ID
	    FROM  okc_k_lines_v cle,
	    okc_line_styles_b lse
	    WHERE lse.id        =cle.lse_id
	    AND lse.lty_code  ='FREE_FORM1'
	    AND cle.name      =l_asset_name
	    AND cle.dnz_chr_id=l_chr_id;

    CURSOR l_try_id_cur IS
            SELECT ID
            FROM okl_trx_types_tl
            WHERE NAME = 'Billing' and LANGUAGE = 'US';

    CURSOR l_cgrp_id_cur(l_cntr_num IN NUMBER) IS

    -- Query updated for performance issue #5484903
	select DEFAULTED_GROUP_ID counter_group_id
	from CSI_COUNTER_TEMPLATE_B
	where counter_id=l_cntr_num
	union all
	select defaulted_group_id counter_group_id
	from  CSI_COUNTERS_B
	where counter_id=l_cntr_num;

    /*  -- commented for performance issue #5484903
            SELECT counter_group_id
            FROM CS_COUNTERS
            WHERE counter_id = l_cntr_num;  */

    CURSOR l_cntr_prop_cur(l_cntr_num IN NUMBER) IS

    -- Query updated for performance issue #5484903
	SELECT COUNTER_PROPERTY_ID,
		DEFAULT_VALUE
	from CSI_CTR_PROPERTY_TEMPLATE_B
	where counter_id=l_cntr_num
	UNION ALL
	SELECT COUNTER_PROPERTY_ID,
		DEFAULT_VALUE
	FROM CSI_COUNTER_PROPERTIES_B
	where counter_id=l_cntr_num;

    /*  -- commented for performance issue #5484903
            SELECT counter_property_id, default_value
            FROM cs_counter_properties
            WHERE counter_id = l_cntr_num; */

  BEGIN

    	x_return_status := OKL_API.G_RET_STS_SUCCESS;

   	l_return_status := OKL_API.START_ACTIVITY(
    		p_api_name	    => l_api_name,
        	p_pkg_name	    => g_pkg_name,
    		p_init_msg_list	=> p_init_msg_list,
    		l_api_version	=> l_api_version,
    		p_api_version	=> p_api_version,
    		p_api_type	    => '_PVT',
    		x_return_status	=> l_return_status);


   IF (l_cntr_bill_tbl.COUNT > 0) THEN
     i := l_cntr_bill_tbl.FIRST;

     LOOP

     l_cntr_bill_rec   := l_cntr_bill_tbl(i);
     l_contract_num    := l_cntr_bill_rec.contract_number;
     l_cntr_num        := l_cntr_bill_rec.counter_number;
     l_amount          := l_cntr_bill_rec.counter_bill_amount;
     l_clg_id          := l_cntr_bill_rec.clg_id;
     l_asset_name      := l_cntr_bill_rec.asset_number;          --added by dkagrawa for bug#6015684

     l_counter_reading := l_cntr_bill_rec.counter_reading;

     IF NVL(l_amount,0) > 0 THEN  -- Bug 4902775

    -- Two level insertion

      -- Header level

        OPEN l_khr_cur(l_contract_num);
        FETCH l_khr_cur INTO l_khr_id;
        CLOSE l_khr_cur;


        OPEN l_try_id_cur;
        FETCH l_try_id_cur INTO l_try_id;
        CLOSE l_try_id_cur;

        l_taiv_rec.trx_status_code              := 'SUBMITTED';
        l_taiv_rec.sfwt_flag                    := 'Y';
        l_taiv_rec.khr_id                       := l_khr_id;
        l_taiv_rec.try_id                       := l_try_id;
        l_taiv_rec.amount                       := l_amount;
        l_taiv_rec.date_invoiced                := sysdate;
        l_taiv_rec.date_entered                 := sysdate;

        l_taiv_rec.legal_entity_id := l_cntr_bill_rec.legal_entity_id;
        l_taiv_rec.clg_id                       := l_clg_id;
        -- udhenuko Bug 6655198 Start
        -- We need to assign the Billing Source as Counter.
        l_taiv_rec.OKL_SOURCE_BILLING_TRX       := 'COUNTER';
        -- udhenuko Bug 6655198 End

       --dbms_output.put_line('Inserting into internal tables in Pvt');
       --dbms_output.put_line('khr_id is in Pvt ' || l_khr_id);
       --dbms_output.put_line('try_id is in Pvt ' || l_try_id);
       --dbms_output.put_line('Inserting into internal tables in Pvt');

        --Header insertion
        Okl_Trx_Ar_Invoices_Pub.insert_trx_ar_invoices(
                                                        l_api_version
                                                        ,l_init_msg_list
                                                        ,l_return_status
                                                        ,l_msg_count
                                                        ,l_msg_data
                                                        ,l_taiv_rec
                                                        ,lx_taiv_rec);

       --dbms_output.put_line('return status from tai is ' || l_return_status);
       --dbms_output.put_line('l_msg_data from tai is ' || l_msg_data);

        IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	        RAISE Fnd_Api.G_EXC_ERROR;
        ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

      --Line Level
      OPEN  l_lines_cur(l_asset_name, l_khr_id );-- for performance issue #5484903
      FETCH l_lines_cur INTO l_kle_id;
      CLOSE l_lines_cur;


        l_tilv_rec.sfwt_flag                    := 'Y';
        l_tilv_rec.amount                       := l_amount;
        l_tilv_rec.tai_id                       := lx_taiv_rec.id;
        l_tilv_rec.INV_RECEIV_LINE_CODE         := 'LINE';
        l_tilv_rec.LINE_NUMBER                  := i;
        l_tilv_rec.KLE_ID                       := l_kle_id;

        --line level insertion
        okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns(
                                                        l_api_version
                                                        ,l_init_msg_list
                                                        ,l_return_status
                                                        ,l_msg_count
                                                        ,l_msg_data
                                                        ,l_tilv_rec
                                                        ,lx_tilv_rec);

        --dbms_output.put_line('Successfully inserted into Lines :'||l_return_status);

        IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	        RAISE Fnd_Api.G_EXC_ERROR;
        ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

		-- Get sty_id for the contract
      Okl_Streams_Util.get_primary_stream_type(
								p_khr_id => l_khr_id,
								p_primary_sty_purpose => 'USAGE_PAYMENT',
								x_return_status => l_return_status,
								x_primary_sty_id => l_sty_id );

        IF 	(l_return_status = 'S' ) THEN
         	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream Id for purpose USAGE_PAYMENT retrieved.');
       	ELSE
         	FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Could not retrieve Stream Id for purpose USAGE_PAYMENT.');
      	END IF;

      	IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        	RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        	RAISE Okl_Api.G_EXCEPTION_ERROR;
      	END IF;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Stream Type => '||l_sty_id);

        	l_tldv_rec.sty_id                       := l_sty_id;
        	l_tldv_rec.sfwt_flag                    := 'Y';
        	l_tldv_rec.amount                       := l_amount;
        	l_tldv_rec.til_id_details               := lx_tilv_rec.id;
        	l_tldv_rec.line_detail_number           := 1;
        	-- udhenuko Bug 6655198 Start
        	-- The accounting packages retreive the contract and asset id from
        	-- the distribution table. So populating these values in the record.
        	l_tldv_rec.khr_id                       := l_khr_id;
        	l_tldv_rec.KLE_ID                       := l_kle_id;
        	-- udhenuko Bug 6655198 End

        	Okl_Txd_Ar_Ln_Dtls_Pub.insert_txd_ar_ln_dtls(
                                                        l_api_version
                                                        ,l_init_msg_list
                                                        ,l_return_status
                                                        ,l_msg_count
                                                        ,l_msg_data
                                                        ,l_tldv_rec
                                                        ,lx_tldv_rec);


        IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	        RAISE Fnd_Api.G_EXC_ERROR;
        ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

		p_bpd_acc_rec.id 		   := lx_tldv_rec.id;
		p_bpd_acc_rec.source_table := 'OKL_TXD_AR_LN_DTLS_B';
		----------------------------------------------------
		-- Create Accounting Distributions
		----------------------------------------------------
		Okl_Acc_Call_Pub.CREATE_ACC_TRANS(
     			p_api_version
    		   ,p_init_msg_list
    		   ,x_return_status
    		   ,x_msg_count
    		   ,x_msg_data
  			   ,p_bpd_acc_rec
		);

        --dbms_output.put_line('success?'||x_return_status);

      	IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
			RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
			RAISE Okl_Api.G_EXCEPTION_ERROR;
		END IF;

   END IF;    -- Bug 4902775

--
   --Insert into Install Base

   OPEN  l_cgrp_id_cur(l_cntr_num);
   FETCH l_cgrp_id_cur INTO l_cntr_grp_id;
   CLOSE l_cgrp_id_cur;

   OPEN  l_cntr_prop_cur(l_cntr_num);
   FETCH l_cntr_prop_cur INTO l_cntr_prop_id, l_cntr_prop_val;

   --dbms_output.put_line('Calling IB Api in Pvt');
  l_ctr_grp_log_rec.COUNTER_GROUP_ID := l_cntr_grp_id;
--  dbms_output.put_line('Counter Group'||l_cntr_grp_id);
  l_ctr_grp_log_rec.VALUE_TIMESTAMP := l_cntr_bill_rec.counter_reading_date;
  l_ctr_grp_log_rec.SOURCE_TRANSACTION_ID := l_clg_id;
--  dbms_output.put_line('transaction id'||l_clg_id);
  l_ctr_grp_log_rec.SOURCE_TRANSACTION_CODE := 'OKL_CNTR_GRP';
  l_ctr_rdg_tbl(1).COUNTER_ID := l_cntr_num;
--    dbms_output.put_line('counter_id'||l_cntr_num);
  l_ctr_rdg_tbl(1).VALUE_TIMESTAMP := l_cntr_bill_rec.counter_reading_date;
  l_ctr_rdg_tbl(1).COUNTER_READING := l_counter_reading;
--  dbms_output.put_line('counter_reading'||l_counter_reading);
  l_ctr_rdg_tbl(1).VALID_FLAG := 'Y';
  -- udhenuko Bug 6655198 Start
  -- For some reason the CS_CTR_CAPTURE_READING_PUB package has this override flag value assigned to
  -- disabled flag. So when we set this as 'Y' CSI_COUNTER_READINGS_PUB treats the record as disabled and
  -- the error message 'CSI_API_CTR_NO_RDG_DISABLE' is thrown. So setting this value
  -- to 'N'
  l_ctr_rdg_tbl(1).OVERRIDE_VALID_FLAG := 'N';
  -- udhenuko Bug 6655198 End

  l_ctr_rdg_tbl(1).COMMENTS := NULL;  -- addressing bug 3468630

  IF l_cntr_prop_cur%found THEN
  l_prop_rdg_tbl(1).COUNTER_PROPERTY_ID := l_cntr_prop_id;
  l_prop_rdg_tbl(1).VALUE_TIMESTAMP := SYSDATE;
  l_prop_rdg_tbl(1).PROPERTY_VALUE := l_cntr_prop_val;
  END IF;
   CLOSE l_cntr_prop_cur;



-- Now call the stored program
  cs_ctr_capture_reading_pub.capture_counter_reading(
                                                      1.0
                                                      ,''
                                                      ,''
                                                   -- ,NULL
                                                      ,FND_API.G_VALID_LEVEL_FULL -- addressing bug 3468630
                                                      ,l_ctr_grp_log_rec
                                                      ,l_ctr_rdg_tbl
                                                      ,l_prop_rdg_tbl
                                                      ,l_return_status
                                                      ,l_msg_count
                                                      ,l_msg_data);


--   dbms_output.put_line('msg_date from install base :'||l_msg_data);
        IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	        RAISE Fnd_Api.G_EXC_ERROR;
        ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;


    x_return_status := l_return_status;
    x_msg_data      := l_msg_data;
    x_msg_count     := l_msg_count;

      EXIT WHEN (i = l_cntr_bill_tbl.LAST);
      i := l_cntr_bill_tbl.NEXT(i);
    END LOOP;

  END IF;
  IF (x_return_status = Fnd_Api.G_RET_STS_ERROR)  THEN
    RAISE l_ins_ext;
  ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE l_ins_ext;
  END IF;
	OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);

  EXCEPTION
    WHEN l_ins_ext THEN
        x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        l_msg_data := 'Problems with Insert into internal tables';
        x_msg_data := l_msg_data ;

    WHEN others THEN
        x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        l_msg_data := '';
        x_msg_data := l_msg_data ;

  END counter_grp_billing_insert;

END OKL_CNTR_GRP_BILLING_PVT;

/
