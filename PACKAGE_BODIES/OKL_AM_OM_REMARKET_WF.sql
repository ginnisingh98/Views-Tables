--------------------------------------------------------
--  DDL for Package Body OKL_AM_OM_REMARKET_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_OM_REMARKET_WF" AS
/* $Header: OKLROWFB.pls 120.4 2007/06/20 13:53:45 akrangan noship $ */

  -- Start of comments
  --
  -- Procedure Name	: set_context
  -- Description    : This resets the org context if the context is lost
  -- Business Rules	:
  -- Parameters		: itemtype, itemkey, actid, resultout
  -- Version		: 1.0
  -- History        : 21-JUN-07 AKRANGAN CREATED
  -- End of comments
  PROCEDURE set_context( itemtype	IN VARCHAR2,
			 itemkey  	IN VARCHAR2,
			 actid		IN NUMBER,
			 resultout      OUT NOCOPY VARCHAR2 )
  IS
  l_resultout      VARCHAR2(20);
  BEGIN
    --this call is to test the context is alive or not
    OE_STANDARD_WF.OEOL_SELECTOR
           (p_itemtype => itemtype
           ,p_itemkey => itemkey
           ,p_actid => actid
           ,p_funcmode => 'TEST_CTX'
           ,p_result => l_resultout
           );
    --if the context is not alive then we can re set
    --the context by calling this api
    IF l_resultout = 'FALSE' THEN
      OE_STANDARD_WF.OEOL_SELECTOR
           (p_itemtype => itemtype
           ,p_itemkey => itemkey
           ,p_actid => actid
           ,p_funcmode => 'SET_CTX'
           ,p_result => l_resultout
           );
    END IF;
    --set the out variable
    resultout := l_resultout;

  END set_context;

  -- Start of comments
  --
  -- Procedure Name	: reduce_item_quantity
  -- Description    : This procedure is used to reduce the item quantity
  -- Business Rules	:
  -- Parameters		: itemtype, itemkey, actid, funcmode, resultout
  -- Version		: 1.0
  -- History        : 21-OCT-04 SECHAWLA 3924244 : Modified procedures to work on order line instead of header
  -- End of comments
  PROCEDURE reduce_item_quantity(
                                 itemtype	IN VARCHAR2,
				                 itemkey  	IN VARCHAR2,
			                 	 actid		IN NUMBER,
			                     funcmode	IN VARCHAR2,
				                 resultout OUT NOCOPY VARCHAR2 )IS

	x_return_status                 VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(2000);
    p_api_version                   NUMBER       := 1;
    p_init_msg_list                 VARCHAR2(1) := 'T';
    l_id		                    NUMBER;
    error_reducing_quantity         EXCEPTION ;
    --ADDED BY AKRANGAN FOR SETTING THE CONTEXT FOR THE WF CALL
    l_ctxt_result                   VARCHAR2(20);
    BEGIN
      --ADDED BY AKRANGAN FOR SETTING THE CONTEXT FOR THE WF CALL BEGIN
      set_context(itemtype => itemtype,
                  itemkey => itemkey,
		  actid => actid,
		  resultout => l_ctxt_result
		  );
      --ADDED BY AKRANGAN FOR SETTING THE CONTEXT FOR THE WF CALL END


        IF (funcmode = 'RUN') THEN

        -- SECHAWLA 21-OCT-04 3924244 : l_id will now be the order line id as this step is moved to the line WF
          l_id := to_number(itemkey);

		OKL_AM_REMARKET_ASSET_PUB.remove_rmk_item(    p_api_version          => p_api_version,
                                                      p_init_msg_list        => p_init_msg_list,
                                                      p_order_line_Id        => l_id,
                                                      x_return_status        => x_return_status,
                                                      x_msg_count            => x_msg_count,
                                                      x_msg_data             => x_msg_data);

          IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
			resultout := 'COMPLETE:PASS';
		ELSE
			resultout := 'COMPLETE:';
            RAISE error_reducing_quantity;
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
     WHEN error_reducing_quantity THEN
        wf_core.context('OKL_AM_OM_REMARKET_WF' , 'reduce_item_quantity', itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN
        wf_core.context('OKL_AM_OM_REMARKET_WF' , 'reduce_item_quantity', itemtype, itemkey, actid, funcmode);
        RAISE;

  END reduce_item_quantity;



    -- Start of comments
  --
  -- Procedure Name	: dispose_asset
  -- Description    : Dispose Asset request from WF
  -- Business Rules	:
  -- Parameters		: itemtype, itemkey, actid, funcmode, resultout
  -- Version		: 1.0
  -- History        : 21-OCT-04 SECHAWLA 3924244 : Modified procedures to work on order line instead of header
  -- End of comments
  PROCEDURE dispose_asset(  itemtype	IN VARCHAR2,
				            itemkey  	IN VARCHAR2,
			                actid		IN NUMBER,
			                funcmode	IN VARCHAR2,
				            resultout OUT NOCOPY VARCHAR2 )IS

	x_return_status                 VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(2000);
    p_api_version                   NUMBER       := 1;
    p_init_msg_list                 VARCHAR2(1) := 'T';
    l_id		                    NUMBER;
    error_disposing_asset           EXCEPTION;
    --ADDED BY AKRANGAN FOR SETTING THE CONTEXT FOR THE WF CALL
    l_ctxt_result                   VARCHAR2(20);
    BEGIN
      --ADDED BY AKRANGAN FOR SETTING THE CONTEXT FOR THE WF CALL BEGIN
      set_context(itemtype => itemtype,
                  itemkey => itemkey,
		  actid => actid,
		  resultout => l_ctxt_result
		  );
      --ADDED BY AKRANGAN FOR SETTING THE CONTEXT FOR THE WF CALL END

      IF (funcmode = 'RUN') THEN
		-- SECHAWLA 21-OCT-04 3924244 : l_id will now be the order line id as this step is moved to the line WF
     	l_id := to_number(itemkey);

		OKL_AM_ASSET_DISPOSE_PUB.dispose_asset (      p_api_version          => p_api_version,
                                                      p_init_msg_list        => p_init_msg_list,
                                                      x_return_status        => x_return_status,
                                                      x_msg_count            => x_msg_count,
                                                      x_msg_data             => x_msg_data,
                                                      p_order_line_Id        => l_id);


        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
			resultout := 'COMPLETE:PASS';
		ELSE
			resultout := 'COMPLETE:';
            RAISE error_disposing_asset;
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
     WHEN error_disposing_asset THEN
        wf_core.context('OKL_AM_OM_REMARKET_WF' , 'dispose_asset', itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN
        wf_core.context('OKL_AM_OM_REMARKET_WF' , 'dispose_asset', itemtype, itemkey, actid, funcmode);
        RAISE;

  END dispose_asset;

      -- Start of comments
  --
  -- Procedure Name	: set_asset_return_status
  -- Description    : Set The asset return status to 'Remarketed' if all units are sold
  -- Business Rules	:
  -- Parameters		: itemtype, itemkey, actid, funcmode, resultout
  -- Version		: 1.0
  -- History        : 21-OCT-04 SECHAWLA 3924244 : Modified procedures to work on order line instead of header
  -- End of comments
  PROCEDURE set_asset_return_status(
                            itemtype	IN VARCHAR2,
				            itemkey  	IN VARCHAR2,
			                actid		IN NUMBER,
			                funcmode	IN VARCHAR2,
				            resultout OUT NOCOPY VARCHAR2 )IS

	x_return_status                 VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(2000);
    p_api_version                   NUMBER       := 1;
    p_init_msg_list                 VARCHAR2(1) := 'T';
    l_id		                    NUMBER;
    l_total_quantity                NUMBER;
    l_original_quantity             NUMBER;
    l_ars_code                      VARCHAR2(30);
    lp_artv_rec                     artv_rec_type;
    lx_artv_rec                     artv_rec_type;
    l_asset_return_id               NUMBER;
    error_setting_status            EXCEPTION;

    /* -- SECHAWLA 21-OCT-04 3924244
    -- This cursor is used to get all the Order Lines for a given Order
    CURSOR l_orderlines_csr(p_id NUMBER) IS
    SELECT line_id, inventory_item_id
    FROM   oe_order_lines_all
    WHERE  header_id = p_id;
    */

    -- SECHAWLA 21-OCT-04 3924244
    -- This cursor is used to get all the Order Lines for a given Order
    CURSOR l_orderlines_csr(cp_line_id NUMBER) IS
    SELECT inventory_item_id
    FROM   oe_order_lines_all
    WHERE  line_id = cp_line_id;

    -- This cursor is used to get the ordered quantity for all the orders booked against a given inventory item
    -- For a given inventory Item, this cursor will return all rows with same asset return Id (art_id) and possibly
    -- different order header Ids
    --Changed following queries to directly use base tables instead of uv for performance --dkagrawa
    CURSOR l_assetsale_csr(p_item_id NUMBER) IS
    SELECT ar.id art_id ,l.ordered_quantity ordered_quantity
    FROM   oe_order_headers_all h,
           oe_order_lines_all l,
           mtl_system_items_b i,
           okl_asset_returns_b ar
    WHERE h.header_id = l.header_id
    and l.ship_from_org_id = i.organization_id
    AND l.inventory_item_id = i.inventory_item_id
    AND l.inventory_item_id = ar.imr_id
    AND h.flow_status_code = 'BOOKED'
    AND i.inventory_item_id = p_item_id
    AND l.inventory_item_id = p_item_id;

    -- This cursor is used to get the Original Asset Return Quantity for an inventory item.
    CURSOR l_assetreturns_csr(p_id NUMBER) IS
    SELECT cim.number_of_items quantity, oar.ars_code ars_code
    FROM   okc_k_lines_b kle,
           okl_asset_returns_all_b oar,
           okc_k_lines_b kle2,
           okc_line_styles_b lse,
           okc_k_items cim
    WHERE  oar.kle_id = kle.id
    AND kle.id = kle2.cle_id
    AND kle2.lse_id = lse.id
    AND lse.lty_code = 'ITEM'
    AND kle2.id = cim.cle_id
    AND oar.id = p_id;

    --ADDED BY AKRANGAN FOR SETTING THE CONTEXT FOR THE WF CALL
    l_ctxt_result                   VARCHAR2(20);
    BEGIN
      --ADDED BY AKRANGAN FOR SETTING THE CONTEXT FOR THE WF CALL BEGIN
      set_context(itemtype => itemtype,
                  itemkey => itemkey,
		  actid => actid,
		  resultout => l_ctxt_result
		  );
      --ADDED BY AKRANGAN FOR SETTING THE CONTEXT FOR THE WF CALL END

      IF (funcmode = 'RUN') THEN

        -- SECHAWLA 21-OCT-04 3924244 : l_id will now be the order line id as this step is moved to the line WF
     	l_id := to_number(itemkey);

		-- SECHAWLA 21-OCT-04 3924244 : the following loop on l_orderlines_csr will return only 1 row
        -- Loop thru all the order lines for a particular order
        FOR l_orderlines_rec IN l_orderlines_csr(l_id) LOOP
            l_total_quantity := 0;
            l_asset_return_id := NULL;

            -- Calculate the total Sold quantity for an inventory item of each Order Line
            FOR l_assetsale_rec IN l_assetsale_csr(l_orderlines_rec.inventory_item_id) LOOP
                l_asset_return_id := l_assetsale_rec.art_id; -- should be same for all the rows
                l_total_quantity := l_total_quantity +  l_assetsale_rec.ordered_quantity;

            END LOOP;

            IF l_asset_return_id IS NOT NULL THEN
                -- get the Original quantity corresponding to an asset return.
                OPEN  l_assetreturns_csr(l_asset_return_id);
                FETCH l_assetreturns_csr INTO l_original_quantity, l_ars_code;
                CLOSE l_assetreturns_csr;


                IF l_total_quantity >= l_original_quantity THEN
                    IF l_ars_code = 'AVAILABLE_FOR_SALE' THEN
                        -- call update of tapi
                        lp_artv_rec.id := l_asset_return_id;
                        lp_artv_rec.ars_code := 'REMARKETED';

                        OKL_ASSET_RETURNS_PUB.update_asset_returns(
                        p_api_version        => p_api_version,
                        p_init_msg_list      => OKL_API.G_FALSE,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                        p_artv_rec           => lp_artv_rec,
                        x_artv_rec           => lx_artv_rec);

                        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                           resultout := 'COMPLETE:';
                           RAISE error_setting_status;

                        END IF;


                     END IF;
                END IF;
            END IF;


        END LOOP;


        resultout := 'COMPLETE:PASS';
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
     WHEN error_setting_status THEN
        IF l_orderlines_csr%ISOPEN THEN
           CLOSE l_orderlines_csr;
        END IF;
        IF l_assetsale_csr%ISOPEN THEN
           CLOSE l_assetsale_csr;
        END IF;
        IF l_assetreturns_csr%ISOPEN THEN
           CLOSE l_assetreturns_csr;
        END IF;
        wf_core.context('OKL_AM_OM_REMARKET_WF' , 'set_asset_return_status', itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN
        IF l_orderlines_csr%ISOPEN THEN
           CLOSE l_orderlines_csr;
        END IF;
        IF l_assetsale_csr%ISOPEN THEN
           CLOSE l_assetsale_csr;
        END IF;
        IF l_assetreturns_csr%ISOPEN THEN
           CLOSE l_assetreturns_csr;
        END IF;
        wf_core.context('OKL_AM_OM_REMARKET_WF' , 'set_asset_return_status', itemtype, itemkey, actid, funcmode);
        RAISE;

  END set_asset_return_status;

  -- Start of comments
  --
  -- Procedure Name	: create_invoice
  -- Description    : Create a remarket invoice for each order line
  -- Business Rules	:
  -- Parameters		: itemtype, itemkey, actid, funcmode, resultout
  -- Version		: 1.0
  -- History        : 21-OCT-04 SECHAWLA 3924244 : Modified procedures to work on order line instead of header
  -- End of comments
  PROCEDURE create_invoice(
                            itemtype	IN VARCHAR2,
				            itemkey  	IN VARCHAR2,
			                actid		IN NUMBER,
			                funcmode	IN VARCHAR2,
				            resultout   OUT NOCOPY VARCHAR2 )IS

	x_return_status                 VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(2000);
    p_api_version                   NUMBER       := 1;
    p_init_msg_list                 VARCHAR2(1) := 'T';
    l_id		                    NUMBER;
    l_total_quantity                NUMBER;
    l_original_quantity             NUMBER;
    l_ars_code                      VARCHAR2(30);
    lp_artv_rec                     artv_rec_type;
    lx_artv_rec                     artv_rec_type;
    l_asset_return_id               NUMBER;
    lx_taiv_tbl                     taiv_tbl_type;
    error_creating_invoice          EXCEPTION;

    /* -- SECHAWLA 21-OCT-04 3924244
    -- This cursor is used to get all the Order Lines for a given Order
    CURSOR l_orderlines_csr(p_id NUMBER) IS
    SELECT line_id, inventory_item_id
    FROM   oe_order_lines_all
    WHERE  header_id = p_id;
    */

    --ADDED BY AKRANGAN FOR SETTING THE CONTEXT FOR THE WF CALL
    l_ctxt_result                   VARCHAR2(20);
    BEGIN
      --ADDED BY AKRANGAN FOR SETTING THE CONTEXT FOR THE WF CALL BEGIN
      set_context(itemtype => itemtype,
                  itemkey => itemkey,
		  actid => actid,
		  resultout => l_ctxt_result
		  );
      --ADDED BY AKRANGAN FOR SETTING THE CONTEXT FOR THE WF CALL END

      IF (funcmode = 'RUN') THEN

        -- SECHAWLA 21-OCT-04 3924244 : l_id will now be the order line id as this step is moved to the line WF
     	l_id := to_number(itemkey);

        -- SECHAWLA 21-OCT-04 3924244 : commented out the loop
	    --FOR l_orderlines_rec IN l_orderlines_csr(l_id) LOOP

            okl_am_invoices_pvt.Create_Remarket_Invoice (
	                                   p_api_version		=> p_api_version,
	                                   p_init_msg_list		=> p_init_msg_list,
	                                   x_msg_count		    => x_msg_count,
	                                   x_msg_data		    => x_msg_data,
	                                   x_return_status		=> x_return_status,
	                                   p_order_line_id		=> l_id,
                                       x_taiv_tbl		    => lx_taiv_tbl);

            IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                resultout := 'COMPLETE:';
                RAISE error_creating_invoice;
            END IF;

       -- END LOOP;


        resultout := 'COMPLETE:PASS';
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
     WHEN error_creating_invoice THEN
        /*IF l_orderlines_csr%ISOPEN THEN
           CLOSE l_orderlines_csr;
        END IF;*/
        wf_core.context('OKL_AM_OM_REMARKET_WF' , 'create_invoice', itemtype, itemkey, actid, funcmode);
        RAISE;
     WHEN OTHERS THEN
        /*IF l_orderlines_csr%ISOPEN THEN
           CLOSE l_orderlines_csr;
        END IF; */
        wf_core.context('OKL_AM_OM_REMARKET_WF' , 'create_invoice', itemtype, itemkey, actid, funcmode);
        RAISE;

  END create_invoice;



END OKL_AM_OM_REMARKET_WF;

/
