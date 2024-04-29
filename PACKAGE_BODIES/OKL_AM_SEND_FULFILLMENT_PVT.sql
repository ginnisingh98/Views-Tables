--------------------------------------------------------
--  DDL for Package Body OKL_AM_SEND_FULFILLMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_SEND_FULFILLMENT_PVT" AS
/* $Header: OKLRSFWB.pls 115.13 2002/08/23 17:26:41 rmunjulu noship $ */


  -- Start of comments
  --
  -- Procedure Name	: send_fulfillment
  -- Description	  : Generic procedure which can be called from any AM screen
  --                  to launch fulfillment
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE send_fulfillment (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_send_rec                    IN  full_rec_type,
           x_send_rec                    OUT NOCOPY full_rec_type) IS


    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name               CONSTANT VARCHAR2(30):= 'send_fulfillment';
    l_api_version            CONSTANT NUMBER      := 1;
    l_recipient_type         VARCHAR2(3);
    l_pt_bind_names          JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_pt_bind_values         JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_pt_bind_types          JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    lp_send_rec              full_rec_type := p_send_rec;
    lx_send_rec              full_rec_type := p_send_rec;

  BEGIN


    -- ***************************************************************
    -- Check API version, initialize message list and create savepoint
    -- ***************************************************************

    --Check API version, initialize message list and create savepoint.
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- ****************************************************
    -- Set In Parameters for Send Fulfillment
    -- ****************************************************

    -- Set the recipient type
    IF    UPPER(lp_send_rec.p_recipient_type) = 'OKX_PARTY'      THEN
       l_recipient_type := 'P';
    ELSIF UPPER(lp_send_rec.p_recipient_type) = 'OKX_PARTYSITE'  THEN
       l_recipient_type := 'PS';
    ELSIF UPPER(lp_send_rec.p_recipient_type) = 'OKX_PCONTACT'   THEN
       l_recipient_type := 'PC';
    ELSIF UPPER(lp_send_rec.p_recipient_type) = 'OKX_VENDOR'     THEN
       l_recipient_type := 'V';
    ELSIF UPPER(lp_send_rec.p_recipient_type) = 'OKX_VENDORSITE' THEN
       l_recipient_type := 'VS';
    ELSIF UPPER(lp_send_rec.p_recipient_type) = 'OKX_VCONTACT'   THEN
       l_recipient_type := 'VC';
    ELSIF UPPER(lp_send_rec.p_recipient_type) = 'OKX_OPERUNIT'   THEN
       l_recipient_type := 'O';
    ELSE -- default is PARTY
       l_recipient_type := 'P';
    END IF;

    -- Initialize tbl types
    l_pt_bind_types(1)  := OKL_API.G_MISS_CHAR;
    l_pt_bind_values(1) := OKL_API.G_MISS_CHAR;
    l_pt_bind_types(1)  := OKL_API.G_MISS_CHAR;


    -- *****************
    -- Call Fulfillment
    -- *****************

    -- Call the fulfillment link from AM
    OKL_AM_UTIL_PVT.execute_fulfillment_request(
            p_api_version                  => p_api_version,
            x_return_status                => l_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_ptm_code                     => lp_send_rec.p_ptm_code,
            p_agent_id                     => lp_send_rec.p_agent_id,
            p_transaction_id               => lp_send_rec.p_transaction_id,
            p_recipient_type               => l_recipient_type,
            p_recipient_id                 => lp_send_rec.p_recipient_id,
            p_recipient_email              => lp_send_rec.p_recipient_email,
            p_pt_bind_names                => l_pt_bind_names,
            p_pt_bind_values               => l_pt_bind_values,
            p_pt_bind_types                => l_pt_bind_types);

    -- Raise exception when error
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- *******************
    -- Set Out Parameters
    -- *******************

    x_return_status :=  l_return_status;
    x_send_rec      :=  lx_send_rec;


    -- *****************
    -- End Transaction
    -- *****************

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END send_fulfillment;



  -- Start of comments
  --
  -- Procedure Name	: send_fulfillment
  -- Description	  : Generic procedure which can be called from any AM screen
  --                  to launch fulfillment. Can be used to send fulfullment to
  --                  multiple parties/contacts/vendors simultaneously
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE send_fulfillment (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_send_tbl                    IN  full_tbl_type,
           x_send_tbl                    OUT NOCOPY full_tbl_type) IS


    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name               CONSTANT VARCHAR2(30):= 'send_fulfillment';
    l_api_version            CONSTANT NUMBER      := 1;
    l_overall_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                        NUMBER;
    lp_send_tbl              full_tbl_type := p_send_tbl;
    lx_send_tbl              full_tbl_type := p_send_tbl;

  BEGIN


    -- ***************************************************************
    -- Check API version, initialize message list and create savepoint
    -- ***************************************************************

    --Check API version, initialize message list and create savepoint.
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- *****************
    -- Call Fulfillment
    -- *****************

    -- Call the rec type procedure
    IF (p_send_tbl.COUNT > 0) THEN
      i := p_send_tbl.FIRST;
      LOOP
        send_fulfillment (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_send_rec                     => lp_send_tbl(i),
          x_send_rec                     => lx_send_tbl(i));

        -- Set the overall status
        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           l_overall_status := l_return_status;
        END IF;

        EXIT WHEN (i = lp_send_tbl.LAST);

        i := lp_send_tbl.NEXT(i);
      END LOOP;
    END IF;


    -- *******************
    -- Set Out Parameters
    -- *******************

    -- Set the return status
    x_return_status :=  l_overall_status;
    x_send_tbl      :=  lx_send_tbl;


    -- *****************
    -- End Transaction
    -- *****************

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END send_fulfillment;


  -- Start of comments
  --
  -- Procedure Name	: send_terminate_quote
  -- Description	  : Procedure to send the party or contact info or contact point info
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE send_terminate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_party_tbl                   IN  q_party_uv_tbl_type,
           x_party_tbl                   OUT NOCOPY q_party_uv_tbl_type,
           p_qtev_rec                    IN  qtev_rec_type,
           x_qtev_rec                    OUT NOCOPY qtev_rec_type) IS


    lp_party_tbl             q_party_uv_tbl_type := p_party_tbl;
    lx_party_tbl             q_party_uv_tbl_type := p_party_tbl;
    lp_send_tbl              full_tbl_type;
    lx_send_tbl              full_tbl_type;

    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name               CONSTANT VARCHAR2(30):= 'send_terminate_quote';
    l_api_version            CONSTANT NUMBER      := 1;
    l_recipient_type         VARCHAR2(3);
    i                        NUMBER;
    l_ptm_code               CONSTANT VARCHAR2(200) := 'AMTER';
    l_agent_id               CONSTANT NUMBER := FND_GLOBAL.user_id;

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

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- ****************************************************
    -- Validate and Set In Parameters for Send Fulfillment
    -- ****************************************************

    i := lp_party_tbl.FIRST;
    LOOP

      -- If no party details then error
      IF  lp_party_tbl(i).po_party_id1 IS NULL
      OR  lp_party_tbl(i).po_party_id1 = OKL_API.G_MISS_CHAR THEN

        -- Invalid value for po_party_id1.
        OKL_API.SET_MESSAGE(p_app_name     => OKC_API.G_APP_NAME,
                       	    p_msg_name     => OKC_API.G_INVALID_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'po_party_id1');

        RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

      -- If no party details then error
      IF  lp_party_tbl(i).po_party_object IS NULL
      OR  lp_party_tbl(i).po_party_object = OKL_API.G_MISS_CHAR THEN

        -- Invalid value for po_party_object.
        OKL_API.SET_MESSAGE(p_app_name     => OKC_API.G_APP_NAME,
                       	    p_msg_name     => OKC_API.G_INVALID_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'po_party_object');

        RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

      -- If party object passed then make sure party name is also passed
      IF  NVL(lp_party_tbl(i).po_party_object, OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR
      AND NVL(lp_party_tbl(i).po_party_name, OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR THEN

        -- Required value for po_party_name.
        OKL_API.SET_MESSAGE(p_app_name     => OKC_API.G_APP_NAME,
                       	    p_msg_name     => OKC_API.G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'po_party_name');

        RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

      -- If contact object passed then make sure contact name is also passed
      IF  NVL(lp_party_tbl(i).co_contact_object, OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR
      AND NVL(lp_party_tbl(i).co_contact_name, OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR THEN

        -- Required value for po_party_name.
        OKL_API.SET_MESSAGE(p_app_name     => OKC_API.G_APP_NAME,
                       	    p_msg_name     => OKC_API.G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'co_contact_name');

        RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

      -- If po_party_id1 not null and po_party_object not null and
      -- co_contact_id null then party/vendor details so recipient is po_party
      IF  NVL(lp_party_tbl(i).po_party_id1, OKL_API.G_MISS_CHAR) <>  OKL_API.G_MISS_CHAR
      AND NVL(lp_party_tbl(i).po_party_object, OKL_API.G_MISS_CHAR) <>  OKL_API.G_MISS_CHAR
      AND NVL(lp_party_tbl(i).co_contact_id1, OKL_API.G_MISS_CHAR) =  OKL_API.G_MISS_CHAR
      AND NVL(lp_party_tbl(i).co_contact_object, OKL_API.G_MISS_CHAR) =  OKL_API.G_MISS_CHAR
      AND NVL(lp_party_tbl(i).cp_point_id, OKL_API.G_MISS_NUM) =  OKL_API.G_MISS_NUM THEN

        IF NVL(lp_party_tbl(i).cp_email, OKL_API.G_MISS_CHAR) <>  OKL_API.G_MISS_CHAR THEN

          -- PARTY WITH EMAIL--
          lp_send_tbl(i).p_recipient_type := lp_party_tbl(i).po_party_object;
          lp_send_tbl(i).p_recipient_id   := lp_party_tbl(i).po_party_id1;
          lp_send_tbl(i).p_recipient_email:= lp_party_tbl(i).cp_email;

        ELSE

          IF NVL(lp_party_tbl(i).co_contact_name, OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR THEN

            -- Email Id does not exist for the contact CONTACT_NAME for party PARTY_NAME,
            -- unable to process fulfillment request.
            OKL_API.SET_MESSAGE(p_app_name     => OKL_API.G_APP_NAME,
                           	    p_msg_name     => 'OKL_AM_FUL_EMAIL_ERR',
                                p_token1       => 'CONTACT_NAME',
                                p_token1_value => lp_party_tbl(i).co_contact_name,
                                p_token2       => 'PARTY_NAME',
                                p_token2_value => lp_party_tbl(i).po_party_name);

            RAISE OKL_API.G_EXCEPTION_ERROR;

          ELSE

            -- Email Id does not exist for the party PARTY_NAME,
            -- unable to process fulfillment request.
            OKL_API.SET_MESSAGE(p_app_name     => OKL_API.G_APP_NAME,
                           	    p_msg_name     => 'OKL_AM_FUL_EMAIL_MSG',
                                p_token1       => 'PARTY_NAME',
                                p_token1_value => lp_party_tbl(i).po_party_name);

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

        END IF;

      -- If co_contact_id1 not null and co_contact_object not null and
      -- cp_point_id null then contact details so recipient is co_contact
      ELSIF NVL(lp_party_tbl(i).co_contact_id1, OKL_API.G_MISS_CHAR) <>  OKL_API.G_MISS_CHAR
      AND NVL(lp_party_tbl(i).co_contact_object, OKL_API.G_MISS_CHAR) <>  OKL_API.G_MISS_CHAR
      AND NVL(lp_party_tbl(i).cp_point_id, OKL_API.G_MISS_NUM) =  OKL_API.G_MISS_NUM
      AND NVL(lp_party_tbl(i).cp_email, OKL_API.G_MISS_CHAR) =  OKL_API.G_MISS_CHAR THEN

        IF NVL(lp_party_tbl(i).co_email, OKL_API.G_MISS_CHAR) <>  OKL_API.G_MISS_CHAR THEN

          -- CONTACT WITH EMAIL--
          lp_send_tbl(i).p_recipient_type := lp_party_tbl(i).co_contact_object;
          lp_send_tbl(i).p_recipient_id   := lp_party_tbl(i).co_contact_id1;
          lp_send_tbl(i).p_recipient_email:= lp_party_tbl(i).co_email;

        ELSE

          IF NVL(lp_party_tbl(i).co_contact_name, OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR THEN

            -- Email Id does not exist for the contact CONTACT_NAME for party PARTY_NAME,
            -- unable to process fulfillment request.
            OKL_API.SET_MESSAGE(p_app_name     => OKL_API.G_APP_NAME,
                           	    p_msg_name     => 'OKL_AM_FUL_EMAIL_ERR',
                                p_token1       => 'CONTACT_NAME',
                                p_token1_value => lp_party_tbl(i).co_contact_name,
                                p_token2       => 'PARTY_NAME',
                                p_token2_value => lp_party_tbl(i).po_party_name);

            RAISE OKL_API.G_EXCEPTION_ERROR;

          ELSE

            -- Email Id does not exist for the party PARTY_NAME,
            -- unable to process fulfillment request.
            OKL_API.SET_MESSAGE(p_app_name     => OKL_API.G_APP_NAME,
                           	    p_msg_name     => 'OKL_AM_FUL_EMAIL_MSG',
                                p_token1       => 'PARTY_NAME',
                                p_token1_value => lp_party_tbl(i).po_party_name);

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

        END IF;

      -- If cp_point_id not null and cp_email not null
      -- then contact point details so recipient is co_contact
      ELSIF NVL(lp_party_tbl(i).cp_point_id, OKL_API.G_MISS_NUM) <>  OKL_API.G_MISS_NUM THEN
        IF NVL(lp_party_tbl(i).cp_email, OKL_API.G_MISS_CHAR) <>  OKL_API.G_MISS_CHAR THEN

          -- CONTACT POINT WITH EMAIL--
          lp_send_tbl(i).p_recipient_type := lp_party_tbl(i).co_contact_object;
          lp_send_tbl(i).p_recipient_id   := lp_party_tbl(i).co_contact_id1;
          lp_send_tbl(i).p_recipient_email:= lp_party_tbl(i).cp_email;

        ELSE

          IF NVL(lp_party_tbl(i).co_contact_name, OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR THEN

            -- Email Id does not exist for the contact CONTACT_NAME for party PARTY_NAME,
            -- unable to process fulfillment request.
            OKL_API.SET_MESSAGE(p_app_name     => OKL_API.G_APP_NAME,
                           	    p_msg_name     => 'OKL_AM_FUL_EMAIL_ERR',
                                p_token1       => 'CONTACT_NAME',
                                p_token1_value => lp_party_tbl(i).co_contact_name,
                                p_token2       => 'PARTY_NAME',
                                p_token2_value => lp_party_tbl(i).po_party_name);

            RAISE OKL_API.G_EXCEPTION_ERROR;

          ELSE

            -- Email Id does not exist for the party PARTY_NAME,
            -- unable to process fulfillment request.
            OKL_API.SET_MESSAGE(p_app_name     => OKL_API.G_APP_NAME,
                           	    p_msg_name     => 'OKL_AM_FUL_EMAIL_MSG',
                                p_token1       => 'PARTY_NAME',
                                p_token1_value => lp_party_tbl(i).po_party_name);

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

        END IF;

      ELSE -- Some values missing or not a proper party/contact/contactpoint

        -- Invalid value passed to fulfillment server, unable to process fulfillment request.
        OKL_API.SET_MESSAGE(p_app_name => OKL_API.G_APP_NAME,
                       	    p_msg_name => 'OKL_AM_FUL_REQUEST_ERR');

        RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;


      lp_send_tbl(i).p_ptm_code       := l_ptm_code;
      lp_send_tbl(i).p_agent_id       := l_agent_id;
      lp_send_tbl(i).p_transaction_id := lp_party_tbl(i).quote_id;


      EXIT WHEN (i = lp_party_tbl.LAST);
      i := lp_party_tbl.NEXT(i);
    END LOOP;


    -- *****************
    -- Call Fulfillment
    -- *****************

    send_fulfillment (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_send_tbl                     => lp_send_tbl,
          x_send_tbl                     => lx_send_tbl);


    -- Raise exception when error
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- *******************
    -- Set Out Parameters
    -- *******************

    x_return_status :=  l_return_status;
    x_party_tbl     :=  lx_party_tbl;


    -- *****************
    -- End Transaction
    -- *****************

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END send_terminate_quote;


  -- Start of comments
  --
  -- Procedure Name	: send_repurchase_quote
  -- Description	  : Procedure to launch fulfillment from repurchase asset scrn
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments

  PROCEDURE send_repurchase_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_send_tbl                    IN  full_tbl_type,
           x_send_tbl                    OUT NOCOPY full_tbl_type,
           p_qtev_rec                    IN  qtev_rec_type,
           x_qtev_rec                    OUT NOCOPY qtev_rec_type) IS


    -- Get the recipient for the quote who is a vendor
    CURSOR okl_get_vendor_for_q_csr ( p_qte_id IN NUMBER) IS
      SELECT OQPV.qp_party_id1    recipient_id,
             OQPV.qp_party_object recipient_type
      FROM   OKL_AM_QUOTE_PARTIES_UV  OQPV
      WHERE  OQPV.quote_id = p_qte_id
      AND    OQPV.qp_role_code = 'RECIPIENT';

    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name               CONSTANT VARCHAR2(30):= 'send_repurchase_quote';
    l_api_version            CONSTANT NUMBER      := 1;
    l_overall_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_recipient_id           VARCHAR2(200);
    l_recipient_type         VARCHAR2(200);
    l_ptm_code               VARCHAR2(200);
    l_pt_bind_names          JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_pt_bind_values         JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_pt_bind_types          JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    i                        NUMBER;
    lp_send_tbl              full_tbl_type := p_send_tbl;
    lx_send_tbl              full_tbl_type := p_send_tbl;
    lp_qtev_rec              qtev_rec_type := p_qtev_rec;
    lx_qtev_rec              qtev_rec_type := p_qtev_rec;

  BEGIN


    -- ***************************************************************
    -- Check API version, initialize message list and create savepoint
    -- ***************************************************************

    --Check API version, initialize message list and create savepoint.
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- ****************************************************
    -- Set In Parameters for Send Fulfillment
    -- ****************************************************

    -- Set the ptm code for fulfillment api
    l_ptm_code       := 'AMREP'; -- for repurchase quote

    -- For each recipient set the fulfillment record
    IF lp_send_tbl.COUNT > 0 THEN
      i := lp_send_tbl.FIRST;
      LOOP

        -- Get the vendor id for the quote id(transaction id)
        OPEN  okl_get_vendor_for_q_csr ( lp_send_tbl(i).p_transaction_id);
        FETCH okl_get_vendor_for_q_csr INTO l_recipient_id, l_recipient_type;
        CLOSE okl_get_vendor_for_q_csr;

        lp_send_tbl(i).p_ptm_code       := l_ptm_code;
        lp_send_tbl(i).p_recipient_id   := l_recipient_id;
        lp_send_tbl(i).p_recipient_type := l_recipient_type;

        EXIT WHEN (i = lp_send_tbl.LAST);
        i := lp_send_tbl.NEXT(i);
      END LOOP;
    END IF;



    -- *****************
    -- Call Fulfillment
    -- *****************

    IF lp_send_tbl.COUNT > 0 THEN

      -- Call the send fulfillment procedure
      send_fulfillment(
          p_api_version        => p_api_version,
          p_init_msg_list      => OKL_API.G_FALSE,
          x_return_status      => l_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          p_send_tbl           => lp_send_tbl,
          x_send_tbl           => lx_send_tbl);

      -- Raise exception when error
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;


    -- *******************
    -- Set Out Parameters
    -- *******************

    x_return_status :=  l_return_status;
    x_send_tbl      :=  lx_send_tbl;
    x_qtev_rec      :=  lx_qtev_rec;


    -- *****************
    -- End Transaction
    -- *****************

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF okl_get_vendor_for_q_csr%ISOPEN THEN
        CLOSE okl_get_vendor_for_q_csr;
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
      IF okl_get_vendor_for_q_csr%ISOPEN THEN
        CLOSE okl_get_vendor_for_q_csr;
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
      IF okl_get_vendor_for_q_csr%ISOPEN THEN
        CLOSE okl_get_vendor_for_q_csr;
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
  END send_repurchase_quote;


  -- Start of comments
  --
  -- Procedure Name	: send_restructure_quote
  -- Description	  : Procedure to launch fulfillment from restructure quote screen
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE send_restructure_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_send_tbl                    IN  full_tbl_type,
           x_send_tbl                    OUT NOCOPY full_tbl_type,
           p_qtev_rec                    IN  qtev_rec_type,
           x_qtev_rec                    OUT NOCOPY qtev_rec_type) IS



    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name               CONSTANT VARCHAR2(30):= 'send_restructure_quote';
    l_api_version            CONSTANT NUMBER      := 1;
    i                        NUMBER;
    lp_send_tbl              full_tbl_type := p_send_tbl;
    lx_send_tbl              full_tbl_type := p_send_tbl;
    lp_qtev_rec              qtev_rec_type := p_qtev_rec;
    lx_qtev_rec              qtev_rec_type := p_qtev_rec;

  BEGIN


    -- ***************************************************************
    -- Check API version, initialize message list and create savepoint
    -- ***************************************************************

    --Check API version, initialize message list and create savepoint.
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- *****************
    -- Call Fulfillment
    -- *****************

    -- Call the send fulfillment procedure
    send_fulfillment(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_send_tbl                     => lp_send_tbl,
          x_send_tbl                     => lx_send_tbl);

    -- Raise exception when error
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- *******************
    -- Set Out Parameters
    -- *******************

    x_return_status :=  l_return_status;
    x_send_tbl      :=  lx_send_tbl;
    x_qtev_rec      :=  lx_qtev_rec;


    -- *****************
    -- End Transaction
    -- *****************

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END send_restructure_quote;



  -- Start of comments
  --
  -- Procedure Name	: send_consolidate_quote
  -- Description	  : Procedure to launch fulfillment from consolidate quote screen
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE send_consolidate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_send_tbl                    IN  full_tbl_type,
           x_send_tbl                    OUT NOCOPY full_tbl_type,
           p_qtev_rec                    IN  qtev_rec_type,
           x_qtev_rec                    OUT NOCOPY qtev_rec_type) IS



    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name               CONSTANT VARCHAR2(30):= 'send_consolidate_quote';
    l_api_version            CONSTANT NUMBER      := 1;
    i                        NUMBER;
    lp_send_tbl              full_tbl_type := p_send_tbl;
    lx_send_tbl              full_tbl_type := p_send_tbl;
    lp_qtev_rec              qtev_rec_type := p_qtev_rec;
    lx_qtev_rec              qtev_rec_type := p_qtev_rec;

  BEGIN


    -- ***************************************************************
    -- Check API version, initialize message list and create savepoint
    -- ***************************************************************

    --Check API version, initialize message list and create savepoint.
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- *****************
    -- Call Fulfillment
    -- *****************

    -- Call the send fulfillment procedure
    send_fulfillment(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_send_tbl                     => lp_send_tbl,
          x_send_tbl                     => lx_send_tbl);

    -- Raise exception when error
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- *******************
    -- Set Out Parameters
    -- *******************

    x_return_status :=  l_return_status;
    x_send_tbl      :=  lx_send_tbl;
    x_qtev_rec      :=  lx_qtev_rec;


    -- *****************
    -- End Transaction
    -- *****************

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END send_consolidate_quote;


END OKL_AM_SEND_FULFILLMENT_PVT;

/
