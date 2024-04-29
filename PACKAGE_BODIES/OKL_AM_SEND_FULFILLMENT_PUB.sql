--------------------------------------------------------
--  DDL for Package Body OKL_AM_SEND_FULFILLMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_SEND_FULFILLMENT_PUB" AS
/* $Header: OKLPSFWB.pls 115.6 2004/04/13 11:06:38 rnaik noship $ */


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

    l_api_version         NUMBER;
    l_init_msg_list       VARCHAR2(1) ;
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(2000);
    lp_send_rec           full_rec_type;
    lx_send_rec           full_rec_type;

  BEGIN

    SAVEPOINT trx_send_fulfillment;

    l_api_version        := p_api_version ;
    l_init_msg_list      := p_init_msg_list ;
    l_return_status      := x_return_status ;
    l_msg_count          := x_msg_count ;
    l_msg_data           := x_msg_data ;
    lp_send_rec          := p_send_rec;
    lx_send_rec          := p_send_rec;



    -- call procedure of PVT
    OKL_AM_SEND_FULFILLMENT_PVT.send_fulfillment(
            p_api_version                  => l_api_version,
            p_init_msg_list                => l_init_msg_list,
            x_return_status                => l_return_status,
            x_msg_count                    => l_msg_count,
            x_msg_data                     => l_msg_data,
            p_send_rec                     => lp_send_rec,
            x_send_rec                     => lx_send_rec);

  	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
      RAISE FND_API.G_EXC_ERROR;
  	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  	END IF;

    -- Set IN as OUT
    lp_send_rec := lx_send_rec;



    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;
    x_send_rec      := lx_send_rec;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_send_fulfillment;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_send_fulfillment;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO trx_send_fulfillment;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_SEND_FULFILLMENT_PUB','send_fulfillment');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

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

    l_api_version         NUMBER;
    l_init_msg_list       VARCHAR2(1) ;
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(2000);
    lp_send_tbl           full_tbl_type;
    lx_send_tbl           full_tbl_type;

  BEGIN

    SAVEPOINT trx_send_fulfillment;

    l_api_version        := p_api_version ;
    l_init_msg_list      := p_init_msg_list ;
    l_return_status      := x_return_status ;
    l_msg_count          := x_msg_count ;
    l_msg_data           := x_msg_data ;
    lp_send_tbl          := p_send_tbl;
    lx_send_tbl          := p_send_tbl;



    -- call procedure of PVT
    OKL_AM_SEND_FULFILLMENT_PVT.send_fulfillment(
            p_api_version                  => l_api_version,
            p_init_msg_list                => l_init_msg_list,
            x_return_status                => l_return_status,
            x_msg_count                    => l_msg_count,
            x_msg_data                     => l_msg_data,
            p_send_tbl                     => lp_send_tbl,
            x_send_tbl                     => lx_send_tbl);

  	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
      RAISE FND_API.G_EXC_ERROR;
  	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  	END IF;

    -- Set IN as OUT
    lp_send_tbl := lx_send_tbl;



    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;
    x_send_tbl      := lx_send_tbl;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_send_fulfillment;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_send_fulfillment;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO trx_send_fulfillment;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_SEND_FULFILLMENT_PUB','send_fulfillment');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

  END send_fulfillment;


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


    l_api_version         NUMBER;
    l_init_msg_list       VARCHAR2(1) ;
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(2000);
    lp_send_tbl           full_tbl_type;
    lx_send_tbl           full_tbl_type;
    lp_qtev_rec           qtev_rec_type;
    lx_qtev_rec           qtev_rec_type;

  BEGIN

    SAVEPOINT trx_send_repurchase_quote;

    l_api_version        := p_api_version ;
    l_init_msg_list      := p_init_msg_list ;
    l_return_status      := x_return_status ;
    l_msg_count          := x_msg_count ;
    l_msg_data           := x_msg_data ;
    lp_send_tbl          := p_send_tbl;
    lx_send_tbl          := p_send_tbl;
    lp_qtev_rec          := p_qtev_rec;
    lx_qtev_rec          := p_qtev_rec;



    -- call procedure of PVT
    OKL_AM_SEND_FULFILLMENT_PVT.send_repurchase_quote(
            p_api_version                  => l_api_version,
            p_init_msg_list                => l_init_msg_list,
            x_return_status                => l_return_status,
            x_msg_count                    => l_msg_count,
            x_msg_data                     => l_msg_data,
            p_send_tbl                     => lp_send_tbl,
            x_send_tbl                     => lx_send_tbl,
            p_qtev_rec                     => lp_qtev_rec,
            x_qtev_rec                     => lx_qtev_rec);

  	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
      RAISE FND_API.G_EXC_ERROR;
  	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  	END IF;

    -- Set IN from OUT
    lp_qtev_rec := lx_qtev_rec;
    lp_send_tbl := lx_send_tbl;



    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;
    x_qtev_rec      := lx_qtev_rec;
    x_send_tbl      := lx_send_tbl;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_send_repurchase_quote;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_send_repurchase_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO trx_send_repurchase_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_SEND_FULFILLMENT_PUB','send_repurchase_quote');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
  END send_repurchase_quote;


  -- Start of comments
  --
  -- Procedure Name	: send_terminate_quote
  -- Description	  : Procedure to launch fulfillment from terminate quote update
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


    l_api_version         NUMBER;
    l_init_msg_list       VARCHAR2(1) ;
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(2000);
    lp_party_tbl          q_party_uv_tbl_type;
    lx_party_tbl          q_party_uv_tbl_type;
    lp_qtev_rec           qtev_rec_type;
    lx_qtev_rec           qtev_rec_type;

  BEGIN

    SAVEPOINT trx_send_terminate_quote;

    l_api_version        := p_api_version ;
    l_init_msg_list      := p_init_msg_list ;
    l_return_status      := x_return_status ;
    l_msg_count          := x_msg_count ;
    l_msg_data           := x_msg_data ;
    lp_party_tbl         := p_party_tbl;
    lx_party_tbl         := p_party_tbl;
    lp_qtev_rec          := p_qtev_rec;
    lx_qtev_rec          := p_qtev_rec;



    -- call procedure of PVT
    OKL_AM_SEND_FULFILLMENT_PVT.send_terminate_quote(
            p_api_version                  => l_api_version,
            p_init_msg_list                => l_init_msg_list,
            x_return_status                => l_return_status,
            x_msg_count                    => l_msg_count,
            x_msg_data                     => l_msg_data,
            p_party_tbl                    => lp_party_tbl,
            x_party_tbl                    => lx_party_tbl,
            p_qtev_rec                     => lp_qtev_rec,
            x_qtev_rec                     => lx_qtev_rec);

  	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
      RAISE FND_API.G_EXC_ERROR;
  	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  	END IF;

    -- Set IN from OUT
    lp_qtev_rec := lx_qtev_rec;
    lp_party_tbl := lx_party_tbl;



    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;
    x_qtev_rec      := lx_qtev_rec;
    x_party_tbl     := lx_party_tbl;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_send_terminate_quote;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_send_terminate_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO trx_send_terminate_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_SEND_FULFILLMENT_PUB','send_terminate_quote');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
  END send_terminate_quote;


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


    l_api_version         NUMBER;
    l_init_msg_list       VARCHAR2(1) ;
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(2000);
    lp_send_tbl           full_tbl_type;
    lx_send_tbl           full_tbl_type;
    lp_qtev_rec           qtev_rec_type;
    lx_qtev_rec           qtev_rec_type;

  BEGIN

    SAVEPOINT trx_send_restructure_quote;

    l_api_version        := p_api_version ;
    l_init_msg_list      := p_init_msg_list ;
    l_return_status      := x_return_status ;
    l_msg_count          := x_msg_count ;
    l_msg_data           := x_msg_data ;
    lp_send_tbl          := p_send_tbl;
    lx_send_tbl          := p_send_tbl;
    lp_qtev_rec          := p_qtev_rec;
    lx_qtev_rec          := p_qtev_rec;



    -- call procedure of PVT
    OKL_AM_SEND_FULFILLMENT_PVT.send_restructure_quote(
            p_api_version                  => l_api_version,
            p_init_msg_list                => l_init_msg_list,
            x_return_status                => l_return_status,
            x_msg_count                    => l_msg_count,
            x_msg_data                     => l_msg_data,
            p_send_tbl                     => lp_send_tbl,
            x_send_tbl                     => lx_send_tbl,
            p_qtev_rec                     => lp_qtev_rec,
            x_qtev_rec                     => lx_qtev_rec);

  	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
      RAISE FND_API.G_EXC_ERROR;
  	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  	END IF;

    -- Set IN from OUT
    lp_qtev_rec := lx_qtev_rec;
    lp_send_tbl := lx_send_tbl;



    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;
    x_qtev_rec      := lx_qtev_rec;
    x_send_tbl      := lx_send_tbl;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_send_restructure_quote;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_send_restructure_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO trx_send_restructure_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_SEND_FULFILLMENT_PUB','send_restructure_quote');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
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


    l_api_version         NUMBER;
    l_init_msg_list       VARCHAR2(1) ;
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(2000);
    lp_send_tbl           full_tbl_type;
    lx_send_tbl           full_tbl_type;
    lp_qtev_rec           qtev_rec_type;
    lx_qtev_rec           qtev_rec_type;

  BEGIN

    SAVEPOINT trx_send_consolidate_quote;

    l_api_version        := p_api_version ;
    l_init_msg_list      := p_init_msg_list ;
    l_return_status      := x_return_status ;
    l_msg_count          := x_msg_count ;
    l_msg_data           := x_msg_data ;
    lp_send_tbl          := p_send_tbl;
    lx_send_tbl          := p_send_tbl;
    lp_qtev_rec          := p_qtev_rec;
    lx_qtev_rec          := p_qtev_rec;



    -- call procedure of PVT
    OKL_AM_SEND_FULFILLMENT_PVT.send_consolidate_quote(
            p_api_version                  => l_api_version,
            p_init_msg_list                => l_init_msg_list,
            x_return_status                => l_return_status,
            x_msg_count                    => l_msg_count,
            x_msg_data                     => l_msg_data,
            p_send_tbl                     => lp_send_tbl,
            x_send_tbl                     => lx_send_tbl,
            p_qtev_rec                     => lp_qtev_rec,
            x_qtev_rec                     => lx_qtev_rec);

  	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
      RAISE FND_API.G_EXC_ERROR;
  	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  	END IF;

    -- Set IN from OUT
    lp_qtev_rec := lx_qtev_rec;
    lp_send_tbl := lx_send_tbl;



    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;
    x_qtev_rec      := lx_qtev_rec;
    x_send_tbl      := lx_send_tbl;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_send_consolidate_quote;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_send_consolidate_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO trx_send_consolidate_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_SEND_FULFILLMENT_PUB','send_consolidate_quote');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
  END send_consolidate_quote;

END OKL_AM_SEND_FULFILLMENT_PUB;

/
