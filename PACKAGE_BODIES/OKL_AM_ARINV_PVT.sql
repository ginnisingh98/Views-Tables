--------------------------------------------------------
--  DDL for Package Body OKL_AM_ARINV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_ARINV_PVT" AS
/* $Header: OKLRARVB.pls 120.4 2008/04/29 22:46:46 sechawla ship $ */


  -- Start of comments
  --
  -- Procedure Name	: Create_Asset_Repair_Invoice
  -- Description	  : Create the Asset Repair Invoice.
  --                  Remains for backward compatibility.
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE Create_Asset_Repair_Invoice (
  	p_api_version	IN  NUMBER,
  	p_init_msg_list	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
  	x_return_status	OUT NOCOPY VARCHAR2,
  	x_msg_count	OUT NOCOPY NUMBER,
  	x_msg_data 	OUT NOCOPY VARCHAR2,
  	p_ariv_tbl	IN  ariv_tbl_type) IS

    	l_taiv_tbl	okl_trx_ar_invoices_pub.taiv_tbl_type;

  BEGIN

  	okl_am_invoices_pvt.create_repair_invoice (
		p_api_version	=> p_api_version,
		p_init_msg_list	=> p_init_msg_list,
		x_return_status	=> x_return_status,
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data,
		p_ariv_tbl	=> p_ariv_tbl,
		x_taiv_tbl	=> l_taiv_tbl);

  END Create_Asset_Repair_Invoice;



  -- Start of comments
  --
  -- Procedure Name	: Validate_Repair_Approval
  -- Description	  : Private API to Validate Repair Approval
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  -- History         : 29-APR-08   SECHAWLA  6797795 : Actual repair cost is required for approval
  -- End of comments
  PROCEDURE Validate_Repair_Approval (
  	x_return_status	OUT NOCOPY VARCHAR2,
  	p_ariv_tbl	    IN  ariv_tbl_type) IS


    -- Get the asset condition details
    CURSOR l_inv_csr ( p_acn_id IN NUMBER) IS
      SELECT  approved_yn,
              acs_code,
              part_name,
              actual_repair_cost -- SECHAWLA  6797795 Added
      FROM    OKL_ASSET_CNDTN_LNS_V
      WHERE   id = p_acn_id;

    l_return_status    		VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_approved_yn      		VARCHAR2(1);
    l_acs_code         		VARCHAR2(200);
    l_part_name        		VARCHAR2(200);
    i                  		NUMBER;
    l_actual_repair_cost 	NUMBER; -- SECHAWLA  6797795 Added


  BEGIN

    -- *****************
    -- Check all records
    -- *****************

    -- Initialize procedure variables
    i := p_ariv_tbl.FIRST;

    LOOP


      -- *********************
      -- Get/Set Database values
      -- *********************

      -- Get the database values for asset condition line
      OPEN  l_inv_csr (p_ariv_tbl(i).p_acn_id);
      -- SECHAWLA  6797795 Added l_actual_repair_cost
      FETCH l_inv_csr INTO l_approved_yn, l_acs_code, l_part_name, l_actual_repair_cost;
      CLOSE l_inv_csr;

      -- If value passed for approved_yn then take that else take DB value
      IF  p_ariv_tbl(i).p_approved_yn IS NOT NULL
      AND p_ariv_tbl(i).p_approved_yn <> OKL_API.G_MISS_CHAR THEN
        l_approved_yn := p_ariv_tbl(i).p_approved_yn;
      END IF;

      -- If value passed for acs_code then take that else take DB value
      IF  p_ariv_tbl(i).p_acs_code IS NOT NULL
      AND p_ariv_tbl(i).p_acs_code <> OKL_API.G_MISS_CHAR THEN
        l_acs_code := p_ariv_tbl(i).p_acs_code;
      END IF;

      -- If value passed for part_name then take that else take DB value
      IF  p_ariv_tbl(i).p_part_name IS NOT NULL
      AND p_ariv_tbl(i).p_part_name <> OKL_API.G_MISS_CHAR THEN
        l_part_name := p_ariv_tbl(i).p_part_name;
      END IF;


      -- *********************
      -- Validate Approval
      -- *********************

      --29-APR-08 SECHAWLA  6797795
	  IF l_approved_yn = 'N' THEN
  		IF l_actual_repair_cost IS NULL THEN
     		IF l_part_name IS NULL THEN
                 --Message: You must enter Actual Repair Cost for this part.
                 OKL_API.set_message(p_app_name     => G_APP_NAME,
                                     p_msg_name     => 'OKL_AM_REP_COST_REQ');
            ELSE
                 -- Message: You must enter Actual Repair Cost for part PART_NAME
                 OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_AM_PART_REP_COST_REQ',
                            p_token1       => 'PART_NAME',
                            p_token1_value => l_part_name);

            END IF;
     		l_return_status := OKL_API.G_RET_STS_ERROR;
  		END IF;
	  END IF;
	  --29-APR-08 SECHAWLA  6797795


      -- Check if already approved
      IF l_approved_yn = G_YES
      OR l_acs_code = 'APPROVED' THEN
        IF l_part_name IS NULL THEN
         --added by rkuttiya Bug: 3528618
         --Message: The invoice for this part is already approved.
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_AM_ALRDY_APPROVED');
        ELSE
        -- Message: The invoice for part PART_NAME is already approved.
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_AM_INV_ALRDY_APPROVED',
                            p_token1       => 'PART_NAME',
                            p_token1_value => l_part_name);

        END IF;
        l_return_status := OKL_API.G_RET_STS_ERROR;

      END IF;

      -- Check if waiting for approval
      IF l_acs_code = 'WAITING_FOR_APPROVAL' THEN
        IF l_part_name IS NULL THEN
        --added by rkuttiya Bug:3528618
        --Message: The invoice for this part is waiting for approval.
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_AM_WAITING_APPROVAL');
        ELSE
        -- Message: The invoice for part PART_NAME is waiting for approval.
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_AM_INV_WAITING_APPROVAL',
                              p_token1       => 'PART_NAME',
                              p_token1_value => l_part_name);

        END IF;
        l_return_status := OKL_API.G_RET_STS_ERROR;

      END IF;


      EXIT WHEN (i = p_ariv_tbl.LAST);
      i := p_ariv_tbl.NEXT(i);
    END LOOP;


    -- *********************
    -- Set return status
    -- *********************

    x_return_status   :=   l_return_status;

  EXCEPTION

    WHEN OTHERS THEN

      IF l_inv_csr%ISOPEN THEN
        CLOSE l_inv_csr;
      END IF;

      -- Store SQL error message on message stack for caller
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Repair_Approval;



  -- Start of comments
  --
  -- Procedure Name	: Approve_Asset_Repair
  -- Description	  : Approval of asset repair invoice
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE Approve_Asset_Repair (
  	p_api_version  	IN  NUMBER,
  	p_init_msg_list	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
  	x_return_status	OUT NOCOPY VARCHAR2,
  	x_msg_count   	OUT NOCOPY NUMBER,
  	x_msg_data    	OUT NOCOPY VARCHAR2,
  	p_ariv_tbl	    IN  ariv_tbl_type,
  	x_ariv_tbl	    OUT NOCOPY ariv_tbl_type) IS


    -- Get the condition header details
    CURSOR l_acd_csr ( p_acn_id IN NUMBER) IS
      SELECT id,
             acd_id
      FROM   OKL_ASSET_CNDTN_LNS_V
      WHERE  id = p_acn_id;

    l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name         CONSTANT VARCHAR2(30):= 'Approve_Asset_Repair';
    l_api_version      CONSTANT NUMBER      := 1;
    i                  NUMBER;
    l_event_name       VARCHAR2(200);
    l_acd_id           NUMBER;
    l_missing_lines    BOOLEAN := FALSE;
    l_id               NUMBER  := OKL_API.G_MISS_NUM;

    lx_ariv_tbl        ariv_tbl_type := p_ariv_tbl;
    lp_acnv_tbl        OKL_ASSET_CNDTN_LNS_PUB.acnv_tbl_type;
    lx_acnv_tbl        OKL_ASSET_CNDTN_LNS_PUB.acnv_tbl_type;

  BEGIN

    -- ***************************************************************
    -- Check API version, initialize message list and create savepoint
    -- ***************************************************************

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);


    -- Raise exception when error
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- *********************
	  -- Validate parameters
    -- *********************

    -- Check if atleast one record passed and valid value passed for p_acn_id
    IF p_ariv_tbl.COUNT > 0 THEN

      i := p_ariv_tbl.FIRST;
      LOOP

        -- Check if null or g_miss passed
        IF ((p_ariv_tbl(i).p_acn_id IS NULL) OR
            (p_ariv_tbl(i).p_acn_id = OKL_API.G_MISS_NUM)) THEN
          l_missing_lines := TRUE;
        END IF;

        -- Get the record from table for acn_id passed
        OPEN  l_acd_csr ( p_ariv_tbl(i).p_acn_id);
        FETCH l_acd_csr INTO l_id, l_acd_id;
        CLOSE l_acd_csr;

        -- Check right value for acn_id passed
        IF l_id = OKL_API.G_MISS_NUM
        OR l_id IS NULL THEN
          l_missing_lines := TRUE;
        END IF;

        EXIT WHEN (i = p_ariv_tbl.LAST);
        i := p_ariv_tbl.NEXT(i);
      END LOOP;
    ELSE
      l_missing_lines := TRUE;
    END IF;

    -- If no records passed or if null/g_miss values passed then error
    IF (l_missing_lines) THEN

      -- Invalid value for p_acn_id.
      OKL_API.SET_MESSAGE(p_app_name     => OKC_API.G_APP_NAME,
                     	    p_msg_name     => OKC_API.G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_acn_id');

      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- *********************
	  -- Validate Repair Approval
    -- *********************

    Validate_Repair_Approval(
          x_return_status  => l_return_status,
          p_ariv_tbl       => p_ariv_tbl);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- *********************
    -- Set Approval details
    -- *********************

    i := p_ariv_tbl.FIRST;
    LOOP

      -- Set the acnv_rec
      lp_acnv_tbl(i).id       :=  p_ariv_tbl(i).p_acn_id;
      lp_acnv_tbl(i).acs_code := 'WAITING_FOR_APPROVAL';

      lx_ariv_tbl(i).p_acs_code  := 'WAITING_FOR_APPROVAL';

      EXIT WHEN (i = p_ariv_tbl.LAST);
      i := p_ariv_tbl.NEXT(i);
    END LOOP;


    -- *********************
    -- Update Condition Lines
    -- *********************

    -- Update the asset condition line for the acs_code
    OKL_ASSET_CNDTN_LNS_PUB.update_asset_cndtn_lns(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => l_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_acnv_tbl       => lp_acnv_tbl,
          x_acnv_tbl       => lx_acnv_tbl);

    -- Raise exception when error
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- *********************
    -- Launch Approval WorkFlow
    -- *********************

    -- Launch the Approve Asset Repair WF
    OKL_AM_WF.raise_business_event (
                	p_transaction_id => l_acd_id,
                  p_event_name	   => 'oracle.apps.okl.am.approveassetrepair');


    -- *********************
    -- Set message
    -- *********************

    -- Get the WF event name
    l_event_name := OKL_AM_UTIL_PVT.get_wf_event_name(
                     p_wf_process_type   => 'OKLAMAAR',
                     p_wf_process_name   => 'APPROVE_ASSET_REPAIR_PROC',
                     x_return_status     => l_return_status);

    -- Raise exception when error
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- Set message on stack
    -- Message: Workflow event EVENT_NAME has been requested.
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_AM_WF_EVENT_MSG',
                        p_token1       => 'EVENT_NAME',
                        p_token1_value => l_event_name);


    -- *********************
    -- Set return values
    -- *********************

    x_ariv_tbl      := lx_ariv_tbl;
    x_return_status := l_return_status;


    -- *********************
    -- End the transaction
    -- *********************

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);


  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF l_acd_csr%ISOPEN THEN
        CLOSE l_acd_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF l_acd_csr%ISOPEN THEN
        CLOSE l_acd_csr;
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN

      IF l_acd_csr%ISOPEN THEN
        CLOSE l_acd_csr;
      END IF;

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END Approve_Asset_Repair;

END OKL_AM_ARINV_PVT;

/
