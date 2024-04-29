--------------------------------------------------------
--  DDL for Package Body OKL_AM_REMARKET_ASSET_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_REMARKET_ASSET_WF" AS
/* $Header: OKLRNWFB.pls 120.3 2005/10/30 04:02:34 appldev noship $ */

  -- Start of comments
  --
  -- Procedure Name	: RAISE_RMK_CUSTOM_PROCESS_EVENT
  -- Description    : raise WF event
  -- Business Rules	:
  -- Parameters		: p_asset_return_id, p_item_number, p_Item_Description, p_Item_Price, p_quantity
  -- Version		: 1.0
  --
  -- End of comments
PROCEDURE RAISE_RMK_CUSTOM_PROCESS_EVENT(p_asset_return_id IN NUMBER,
                                         p_item_number  IN VARCHAR2,
										 p_Item_Description IN VARCHAR2,
										 p_Item_Price IN NUMBER,
										 p_quantity IN NUMBER) IS

    l_parameter_list        WF_PARAMETER_LIST_T;
    l_key                   WF_ITEMS.item_key%TYPE;
    l_event_name            WF_EVENTS.NAME%TYPE := 'oracle.apps.okl.am.remkcustomflow';
    l_seq                   NUMBER;


    -- Cursor to get the value of the sequence
  	CURSOR okl_key_csr IS
  	SELECT okl_wf_item_s.nextval
  	FROM   DUAL;



  BEGIN

    SAVEPOINT remk_custom_process_event;

  	OPEN  okl_key_csr;
  	FETCH okl_key_csr INTO l_seq;
  	CLOSE okl_key_csr;

    l_key := l_event_name ||l_seq ;



    -- *******
    -- Set the parameter list
    -- *******

    WF_EVENT.AddParameterToList('ASSET_RETURN_ID',
                                p_asset_return_id,
                                l_parameter_list);

    WF_EVENT.AddParameterToList('ITEM_NUMBER',
                                p_item_number,
                                l_parameter_list);

	WF_EVENT.AddParameterToList('ITEM_DESC',
                                p_Item_Description,
                                l_parameter_list);

	WF_EVENT.AddParameterToList('ITEM_PRICE',
                                p_Item_Price,
                                l_parameter_list);

	WF_EVENT.AddParameterToList('QUANTITY',
                                p_quantity,
                                l_parameter_list);


    -- Raise Business Event
    WF_EVENT.raise(
                 p_event_name  => l_event_name,
                 p_event_key   => l_key,
                 p_parameters  => l_parameter_list);

    l_parameter_list.DELETE;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      IF okl_key_csr%ISOPEN THEN
         CLOSE okl_key_csr;
      END IF;
      ROLLBACK TO remk_custom_process_event;

END RAISE_RMK_CUSTOM_PROCESS_EVENT;



  -- Start of comments
  --
  -- Procedure Name	: VALIDATE_ASSET_RETURN
  -- Description    : validate asset return id
  -- Business Rules	:
  -- Parameters		: itemtype, itemkey, actid, funcmode, resultout
  -- Version		: 1.0
  --
  -- End of comments
PROCEDURE VALIDATE_ASSET_RETURN(itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout   OUT NOCOPY VARCHAR2) IS

    l_id		    			NUMBER;
	l_LAST_UPDATED_BY			NUMBER;
	l_user              		WF_USERS.NAME%TYPE;
    l_name              		WF_USERS.DESCRIPTION%TYPE;


    -- get last_updated_by
	CURSOR l_assetreturn_csr(cp_asset_return_id IN NUMBER) IS
	SELECT last_updated_by
	FROM   okl_asset_returns_b
	WHERE  id = cp_asset_return_id;

    BEGIN

      IF (funcmode = 'RUN') THEN

     	l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	           itemkey	=> itemkey,
							               aname  	=> 'ASSET_RETURN_ID');

		OPEN  l_assetreturn_csr(to_number(l_id));
		FETCH l_assetreturn_csr INTO l_LAST_UPDATED_BY;
		CLOSE l_assetreturn_csr;

		IF l_LAST_UPDATED_BY IS NULL THEN
		   resultout := 'COMPLETE:INVALID';
		ELSE
		   okl_am_wf.get_notification_agent(
                                itemtype	  => itemtype
	                          , itemkey  	  => itemkey
	                          , actid	      => actid
	                          , funcmode	  => funcmode
                              , p_user_id     => l_last_updated_by
                              , x_name  	  => l_user
	                          , x_description => l_name);

	       wf_engine.SetItemAttrText ( itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'WF_ADMINISTRATOR',
         	                    avalue  => l_user);

		   resultout := 'COMPLETE:VALID';
		END IF;

        RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF l_assetreturn_csr%ISOPEN THEN
           CLOSE l_assetreturn_csr;
        END IF;

        wf_core.context('OKL_AM_REMARKET_ASSET_WF' , 'validate_asset_return', itemtype, itemkey, actid, funcmode);
        RAISE;

  END validate_asset_return;


  -- Start of comments
  --
  -- Procedure Name	: VALIDATE_ITEM_INFO
  -- Description    : validate item information
  -- Business Rules	:
  -- Parameters		: itemtype, itemkey, actid, funcmode, resultout
  -- Version		: 1.0
  --
  -- End of comments
PROCEDURE VALIDATE_ITEM_INFO   (itemtype	IN VARCHAR2,
				                itemkey  	IN VARCHAR2,
			                 	actid		IN NUMBER,
			                  	funcmode	IN VARCHAR2,
				                resultout   OUT NOCOPY VARCHAR2	) IS

	-- get last_updated_by
	CURSOR l_assetreturn_csr(cp_asset_return_id IN NUMBER) IS
	SELECT last_updated_by
	FROM   okl_asset_returns_b
	WHERE  id = cp_asset_return_id;


    l_api_version                   NUMBER       := 1;
    l_init_msg_list                 VARCHAR2(1)  := OKL_API.G_FALSE;
    x_return_status                 VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(2000);

    l_asset_return_id               VARCHAR2(2000);
    l_item_number					VARCHAR2(2000);
    l_item_desc						VARCHAR2(240);
   -- l_item_price					VARCHAR2(2000);
    l_item_price					NUMBER; -- sechawla 29-OCT-04 3924244 : changed to NUMBER
    l_item_qty						VARCHAR2(2000);
    l_inv_org_id                    NUMBER;
    l_inv_org_name                  VARCHAR2(240);
    l_subinv_code             		VARCHAR2(10);
    l_price_list_id					NUMBER;
    l_sysdate						DATE;
    invalid_item_info   			EXCEPTION;

    l_user              			WF_USERS.NAME%TYPE;
    l_name              			WF_USERS.DESCRIPTION%TYPE;
    l_last_updated_by   			NUMBER;
    l_item_templ_id					NUMBER;
    BEGIN

      IF (funcmode = 'RUN') THEN

        l_asset_return_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	           itemkey	=> itemkey,
							               aname  	=> 'ASSET_RETURN_ID');

     	l_item_number := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	           itemkey	=> itemkey,
							               aname  	=> 'ITEM_NUMBER');

		l_item_desc := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	           itemkey	=> itemkey,
							               aname  	=> 'ITEM_DESC');

		l_item_price := wf_engine.GetItemAttrNumber( itemtype => itemtype,  -- sechawla 29-OCT-04 3924244 changed to GetItemAttrNumber
						      	           itemkey	=> itemkey,
							               aname  	=> 'ITEM_PRICE');

		l_item_qty := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	           itemkey	=> itemkey,
							               aname  	=> 'QUANTITY');



        OKL_AM_CUSTOM_RMK_ASSET_PVT.validate_item_info(
     				p_api_version           => l_api_version,
     				p_init_msg_list         => l_init_msg_list,
     				p_asset_return_id       => to_number(l_asset_return_id),
     				p_item_number           => l_item_number,
     				p_Item_Description      => l_item_desc,
     				p_Item_Price            => l_item_price, -- sechawla 29-OCT-04 3924244 : removed the to_number conversion
     				p_quantity              => to_number(l_item_qty),
     				x_inv_org_id            => l_inv_org_id,
     				x_inv_org_name          => l_inv_org_name,
     				x_subinv_code           => l_subinv_code,
     				x_sys_date				=> l_sysdate,
     				x_price_list_id		    => l_price_list_id,
     				x_item_templ_id         => l_item_templ_id,
     				x_return_status         => x_return_status,
     				x_msg_count             => x_msg_count,
     				x_msg_data              => x_msg_data);

		IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN

		    WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'INV_ORG_ID',
                                       avalue   => to_char(l_inv_org_id));

			WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'INV_ORG_NAME',
                                       avalue   => l_inv_org_name);

			WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'SUBINV_CODE',
                                       avalue   => l_subinv_code);

			WF_ENGINE.SetItemAttrDate( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'SYS_DATE',
                                       avalue   => l_sysdate);

            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'PRICE_LIST_ID',
                                       avalue   => to_char(l_price_list_id));

            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'ITEM_TEMPLATE_ID',
                                       avalue   => to_char(l_item_templ_id));

     		resultout := 'COMPLETE:VALID';
		ELSE
			resultout := 'COMPLETE:INVALID';
			RAISE invalid_item_info;
		END IF;

		RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN invalid_item_info THEN
        wf_core.context('OKL_AM_REMARKET_ASSET_WF' , 'VALIDATE_ITEM_INFO', itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN

        wf_core.context('OKL_AM_REMARKET_ASSET_WF' , 'VALIDATE_ITEM_INFO', itemtype, itemkey, actid, funcmode);
        RAISE;

  END VALIDATE_ITEM_INFO;


  -- Start of comments
  --
  -- Procedure Name	: CREATE_INV_ITEM
  -- Description    : Create Inventory Item
  -- Business Rules	:
  -- Parameters		: itemtype, itemkey, actid, funcmode, resultout
  -- Version		: 1.0
  --
  -- End of comments
  PROCEDURE CREATE_INV_ITEM  (itemtype	IN VARCHAR2,
				              itemkey  	IN VARCHAR2,
			                  actid		IN NUMBER,
			                  funcmode	IN VARCHAR2,
				              resultout OUT NOCOPY VARCHAR2	) IS

    l_api_version                   NUMBER       := 1;
    l_init_msg_list                 VARCHAR2(1)  := OKL_API.G_FALSE;
    x_return_status                 VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(2000);

    l_asset_return_id				VARCHAR2(2000);
    l_inv_org_id                    VARCHAR2(2000);
    l_item_templ_id					VARCHAR2(2000);
    l_inv_org_name                  VARCHAR2(240);
    l_item_desc						VARCHAR2(240);
    l_subinv_code					VARCHAR2(10);
    l_sysdate						DATE;
    l_item_number					VARCHAR2(2000);
    l_New_Item_Number     			VARCHAR2(2000);
    l_New_Item_Id         			NUMBER;
    create_inv_item_error			EXCEPTION;

    BEGIN

      IF (funcmode = 'RUN') THEN

        l_asset_return_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'ASSET_RETURN_ID');

     	l_inv_org_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'INV_ORG_ID');

        l_inv_org_name := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'INV_ORG_NAME');

		l_item_desc := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
						      	       itemkey	=> itemkey,
							           aname  	=> 'ITEM_DESC');

		l_subinv_code := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'SUBINV_CODE');

		l_sysdate := WF_ENGINE.GetItemAttrDate( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'SYS_DATE');

		l_item_number := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
						      	           itemkey	=> itemkey,
							               aname  	=> 'ITEM_NUMBER');

		l_item_templ_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'ITEM_TEMPLATE_ID');

	    OKL_AM_CUSTOM_RMK_ASSET_PVT.create_inv_item
			(  	p_api_version          => l_api_version,
   				p_init_msg_list        => l_init_msg_list,
   				p_asset_return_id      => to_number(l_asset_return_id),
   				p_Organization_Id      => to_number(l_inv_org_id),
   				p_organization_name    => l_inv_org_name,
 				p_Item_Description     => l_item_desc,
 				p_subinventory         => l_subinv_code,
 				p_sysdate              => l_sysdate,
				p_item_number          => l_item_number,
				p_item_templ_id        => to_number(l_item_templ_id),
 			    x_New_Item_Number      => l_New_Item_Number,
 			    x_New_Item_Id          => l_New_Item_Id,
 				x_Return_Status        => x_Return_Status,
 				x_msg_count            => x_msg_count,
 				x_msg_data             => x_msg_data);


		IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN

		    WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'NEW_ITEM_NUMBER',
                                       avalue   => l_New_Item_Number);

            WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'NEW_ITEM_ID',
                                       avalue   => to_char(l_New_Item_Id));

     		resultout := 'COMPLETE:VALID';
		ELSE
			resultout := 'COMPLETE:INVALID';
			RAISE create_inv_item_error;
		END IF;

		RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN create_inv_item_error THEN
        wf_core.context('OKL_AM_REMARKET_ASSET_WF' , 'VALIDATE_ITEM_INFO', itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN

        wf_core.context('OKL_AM_REMARKET_ASSET_WF' , 'VALIDATE_ITEM_INFO', itemtype, itemkey, actid, funcmode);
        RAISE;



  END CREATE_INV_ITEM;


  -- Start of comments
  --
  -- Procedure Name	: CREATE_INV_MISC_RECEIPT
  -- Description    : Create Inventory Misc Receipt
  -- Business Rules	:
  -- Parameters		: itemtype, itemkey, actid, funcmode, resultout
  -- Version		: 1.0
  --
  -- End of comments
  PROCEDURE CREATE_INV_MISC_RECEIPT  (itemtype	IN VARCHAR2,
				              itemkey  	IN VARCHAR2,
			                  actid		IN NUMBER,
			                  funcmode	IN VARCHAR2,
				              resultout OUT NOCOPY VARCHAR2	) IS

    l_api_version                   NUMBER       := 1;
    l_init_msg_list                 VARCHAR2(1)  := OKL_API.G_FALSE;
    x_return_status                 VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(2000);
    l_New_Item_Id                   VARCHAR2(2000);
    l_subinv_code                   VARCHAR2(10);
    l_inv_org_id					VARCHAR2(2000);
    l_item_qty  					VARCHAR2(2000);
    l_sysdate						DATE;
    create_misc_rec_error			EXCEPTION;
    BEGIN

      IF (funcmode = 'RUN') THEN

     	l_New_Item_Id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'NEW_ITEM_ID');

        l_subinv_code := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'SUBINV_CODE');

	    l_inv_org_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'INV_ORG_ID');

		l_item_qty := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
						      	           itemkey	=> itemkey,
							               aname  	=> 'QUANTITY');

		l_sysdate := WF_ENGINE.GetItemAttrDate( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'SYS_DATE');

	    OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Inv_Misc_Receipt
			(    	p_api_version          => l_api_version,
     				p_init_msg_list        => l_init_msg_list,
     				p_Inventory_Item_id    => to_number(l_New_Item_Id),
  					p_Subinv_Code          => l_subinv_code,
  					p_Organization_Id      => to_number(l_inv_org_id),
  					p_quantity             => to_number(l_item_qty),
  					p_trans_type_id        => 42,
  					p_sysdate              => l_sysdate,
  					x_Return_Status        => x_Return_Status,
  					x_msg_count            => x_msg_count,
  					x_msg_data             => x_msg_data);


		IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
     		resultout := 'COMPLETE:VALID';
		ELSE
			resultout := 'COMPLETE:INVALID';
			RAISE create_misc_rec_error;
		END IF;

		RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN create_misc_rec_error THEN
        wf_core.context('OKL_AM_REMARKET_ASSET_WF' , 'VALIDATE_ITEM_INFO', itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN

        wf_core.context('OKL_AM_REMARKET_ASSET_WF' , 'VALIDATE_ITEM_INFO', itemtype, itemkey, actid, funcmode);
        RAISE;



  END CREATE_INV_MISC_RECEIPT;


  -- Start of comments
  --
  -- Procedure Name	: CREATE_ITEM_PRICE_LIST
  -- Description    : Create Inventory Item in Price List
  -- Business Rules	:
  -- Parameters		: itemtype, itemkey, actid, funcmode, resultout
  -- Version		: 1.0
  --
  -- End of comments
  PROCEDURE CREATE_ITEM_PRICE_LIST  (itemtype	IN VARCHAR2,
				              itemkey  	IN VARCHAR2,
			                  actid		IN NUMBER,
			                  funcmode	IN VARCHAR2,
				              resultout OUT NOCOPY VARCHAR2	) IS

    l_api_version                   NUMBER       := 1;
    l_init_msg_list                 VARCHAR2(1)  := OKL_API.G_FALSE;
    x_return_status                 VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(2000);
    l_price_list_id					VARCHAR2(2000);
    l_New_Item_Id					VARCHAR2(2000);
    -- l_item_price					VARCHAR2(2000);
    l_item_price					NUMBER;  -- sechawla 29-OCT-04 3924244 : changed datatype to NUMBER
    create_price_list_error			EXCEPTION;
    BEGIN

      IF (funcmode = 'RUN') THEN

     	l_price_list_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'PRICE_LIST_ID');

		l_New_Item_Id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'NEW_ITEM_ID');

		l_item_price := wf_engine.GetItemAttrNumber( itemtype => itemtype, -- sechawla 29-OCT-04 3924244 : changed to GetItemAttrNumber
						      	           itemkey	=> itemkey,
							               aname  	=> 'ITEM_PRICE');

	    OKL_AM_CUSTOM_RMK_ASSET_PVT.Create_Item_Price_List
			(   p_api_version       =>   l_api_version,
  				p_init_msg_list     =>   l_init_msg_list,
  				p_Price_List_id     =>   to_number(l_price_list_id),
  				p_Item_Id           =>   to_number(l_New_Item_Id),
  				p_Item_Price        =>   l_item_price, -- sechawla 29-OCT-04 3924244 : removed the to_number conversion
  				x_return_status     =>   x_return_status,
  				x_msg_count         =>   x_msg_count,
  				x_msg_data          =>   x_msg_data);


		IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
     		resultout := 'COMPLETE:VALID';
		ELSE
			resultout := 'COMPLETE:INVALID';
			RAISE create_price_list_error;
		END IF;

		RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN create_price_list_error THEN
        wf_core.context('OKL_AM_REMARKET_ASSET_WF' , 'VALIDATE_ITEM_INFO', itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN
        wf_core.context('OKL_AM_REMARKET_ASSET_WF' , 'VALIDATE_ITEM_INFO', itemtype, itemkey, actid, funcmode);
        RAISE;



  END CREATE_ITEM_PRICE_LIST;

END OKL_AM_REMARKET_ASSET_WF;

/
