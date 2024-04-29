--------------------------------------------------------
--  DDL for Package Body OKL_ACC_GEN_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACC_GEN_WF_PVT" AS
/* $Header: OKLRAGWB.pls 120.2 2005/10/30 04:31:13 appldev noship $ */

-- Changed the signature for bug 4157521

FUNCTION start_process
  (
    p_acc_gen_wf_sources_rec  IN  acc_gen_wf_sources_rec,
    p_ae_line_type	      IN  okl_acc_gen_rules.ae_line_type%TYPE,
    p_primary_key_tbl	      IN  acc_gen_primary_key,
    p_ae_tmpt_line_id	      IN  NUMBER DEFAULT NULL
  )
RETURN NUMBER
AS
    l_ItemType		VARCHAR2(30) :='OKLFLXWF';
    l_ItemKey		VARCHAR2(30);
    l_ccid 		NUMBER;
    l_concat_segs   	VARCHAR2(2000);
    l_concat_ids    	VARCHAR2(2000);
    l_concat_descrs 	VARCHAR2(2000);
    l_err_msg        	VARCHAR2(2000);
    l_result 		BOOLEAN;
    l_chart_of_accounts_id	NUMBER := Okl_Accounting_Util.get_chart_of_accounts_id;
    l_template_line_ccid NUMBER;
    l_new_ccid        BOOLEAN;

  BEGIN

    SELECT code_combination_id INTO l_template_line_ccid
    FROM OKL_AE_TMPT_LNES
    WHERE ID = p_ae_tmpt_line_id;

    -- Initialize the workflow, which will return the item key.

    l_itemkey := Fnd_Flex_Workflow.INITIALIZE
				   ('SQLGL',
				   'GL#',
				    l_chart_of_accounts_id,
		            	    l_ItemType
				   );

--  Populate the required attributes for bug 4157521

        wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'PRODUCT_ID',
                                  avalue  =>  p_acc_gen_wf_sources_rec.product_id);

        wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'TRANSACTION_TYPE_ID',
                                  avalue  =>  p_acc_gen_wf_sources_rec.transaction_type_id);

        wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'STREAM_TYPE_ID',
                                  avalue  =>  p_acc_gen_wf_sources_rec.stream_type_id);

        wf_engine.SetItemAttrText(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'FACTORING_SYND_FLAG',
                                  avalue  =>  p_acc_gen_wf_sources_rec.factoring_synd_flag);

        wf_engine.SetItemAttrText(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'SYNDICATION_CODE',
                                  avalue  =>  p_acc_gen_wf_sources_rec.syndication_code);

        wf_engine.SetItemAttrText(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'FACTORING_CODE',
                                  avalue  =>  p_acc_gen_wf_sources_rec.factoring_code);

        wf_engine.SetItemAttrText(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'INVESTOR_CODE',
                                  avalue  =>  p_acc_gen_wf_sources_rec.investor_code);

        wf_engine.SetItemAttrText(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'MEMO_YN',
                                  avalue  =>  p_acc_gen_wf_sources_rec.memo_yn);

        wf_engine.SetItemAttrText(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'REV_REC_FLAG',
                                  avalue  =>  p_acc_gen_wf_sources_rec.rev_rec_flag);

        wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'SOURCE_ID',
                                  avalue  =>  p_acc_gen_wf_sources_rec.source_id);

        wf_engine.SetItemAttrText(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'SOURCE_TABLE',
                                  avalue  =>  p_acc_gen_wf_sources_rec.source_table);

        wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'CONTRACT_ID',
                                  avalue  =>  p_acc_gen_wf_sources_rec.contract_id);

        wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'CONTRACT_LINE_ID',
                                  avalue  =>  p_acc_gen_wf_sources_rec.contract_line_id);

        wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'TEMPLATE_LINE_ID',
                                  avalue  =>  p_ae_tmpt_line_id);

        wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'CHART_OF_ACCOUNTS_ID',
                                  avalue  =>  l_chart_of_accounts_id);

        wf_engine.SetItemAttrText(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'ACCOUNT_GENERATOR_RULE',
                                  avalue  =>  p_ae_line_type);

	wf_engine.SetItemAttrDate(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'ACCOUNTING_DATE',
                                  avalue   => p_acc_gen_wf_sources_rec.accounting_date);


    	IF p_primary_key_tbl.COUNT > 0 THEN
    	  FOR i IN p_primary_key_tbl.FIRST .. p_primary_key_tbl.LAST LOOP

	    IF p_primary_key_tbl(i).source_table = 'AP_VENDOR_SITES_V' THEN
		wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'VENDOR_SITE_ID',
                                  avalue  =>  TRIM(p_primary_key_tbl(i).primary_key_column));

	    ELSIF p_primary_key_tbl(i).source_table = 'AR_SITE_USES_V' THEN
        	wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'SITE_USE_ID',
                                  avalue  =>  TRIM(p_primary_key_tbl(i).primary_key_column));

	    ELSIF p_primary_key_tbl(i).source_table = 'FA_CATEGORY_BOOKS' THEN
        	wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'ASSET_CATEGORY_ID',
                                  avalue  =>  TRIM(SUBSTR(p_primary_key_tbl(i).primary_key_column, 1, 50)));

        	wf_engine.SetItemAttrText(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'BOOK_TYPE_CODE',
                                  avalue  =>  TRIM(SUBSTR(p_primary_key_tbl(i).primary_key_column, 51, 100)));

	    ELSIF p_primary_key_tbl(i).source_table = 'FINANCIALS_SYSTEM_PARAMETERS' THEN
        	wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'ORG_ID',
                                  avalue  =>  TRIM(p_primary_key_tbl(i).primary_key_column));

	    ELSIF p_primary_key_tbl(i).source_table = 'JTF_RS_SALESREPS_MO_V' THEN
        	wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'SALESREP_ID',
                                  avalue  =>  TRIM(p_primary_key_tbl(i).primary_key_column));

	    ELSIF p_primary_key_tbl(i).source_table = 'MTL_SYSTEM_ITEMS_VL' THEN
        	wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'INVENTORY_ITEM_ID',
                                  avalue  =>  TRIM(SUBSTR(p_primary_key_tbl(i).primary_key_column, 1, 50)));

        	wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'INVENTORY_ORG_ID',
                                  avalue  =>  TRIM(SUBSTR(p_primary_key_tbl(i).primary_key_column, 51, 100)));


	    ELSIF p_primary_key_tbl(i).source_table = 'RA_CUST_TRX_TYPES' THEN
        	wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                  itemkey => l_ItemKey,
                                  aname   => 'CUST_TRX_TYPE_ID',
                                  avalue  =>  TRIM(p_primary_key_tbl(i).primary_key_column));


            END IF;
    	  END LOOP;
    	END IF;


     -- Call the function which would return the ccid
     -- Bug 4157521

     l_result := Fnd_Flex_Workflow.generate
    		      (itemtype   => l_itemtype    ,
                      itemkey       => l_itemkey,
                      insert_if_new => TRUE,
                      ccid          => l_ccid,
                      concat_segs   => l_concat_segs,
                      concat_ids    => l_concat_ids,
                      concat_descrs => l_concat_descrs,
                      error_message => l_err_msg,
                      new_combination => l_new_ccid);


    RETURN l_ccid;

  END start_process;


  PROCEDURE sample_function (itemtype  IN VARCHAR2,
	    	            itemkey	IN VARCHAR2,
		            actid	IN NUMBER,
		            funcmode     IN VARCHAR2,
		            result       OUT NOCOPY VARCHAR2)
  AS

  l_template_line_ccid NUMBER;
  l_atl_id  NUMBER;

  CURSOR atl_ccid_csr (l_atl_id NUMBER) IS
  SELECT code_combination_id INTO l_template_line_ccid
  FROM OKL_AE_TMPT_LNES
  WHERE ID = l_atl_id;

  BEGIN

     l_atl_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'TEMPLATE_LINE_ID');

     OPEN atl_ccid_csr (l_atl_id);
     FETCH atl_ccid_csr INTO l_template_line_ccid;
     CLOSE atl_ccid_csr;

     wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname   => 'TEMPLATE_LINE_CCID',
                                  avalue  =>  l_template_line_ccid);


    /* User puts the required logic over here
    Eg

     IF (funcmode = 'RUN') THEN
        l_account_type := wf_engine.GetItemAttrText(itemtype,itemkey,'ACCOUNT_TYPE');
        IF (h_account_type = 'LEASE_RECEIVABLES') THEN
            result := 'COMPLETE:' || 'LEASE_RECEIVABLES_ACCOUNT';
            RETURN;
        END IF;

     ELSIF (funcmode = 'CANCEL') THEN
       result :=  'COMPLETE:';
       RETURN;
     ELSE
       result := '';
       RETURN;
     END IF;
   */

     -- NULL;
  END sample_function;


END OKL_ACC_GEN_WF_PVT;

/
