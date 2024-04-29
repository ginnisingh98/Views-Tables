--------------------------------------------------------
--  DDL for Package Body OKL_AM_CONSOLIDATED_QTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CONSOLIDATED_QTE_PUB" AS
/* $Header: OKLPCNQB.pls 115.3 2004/04/13 10:39:04 rnaik noship $ */


  -- Start of comments
  --
  -- Procedure Name	: create_consolidate_quote
  -- Description	  : Procedure to create a consolidated quote
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE create_consolidate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_qtev_tbl                    IN  qtev_tbl_type,
           x_cons_rec                    OUT NOCOPY qtev_rec_type) IS

     l_api_version NUMBER ;
     l_init_msg_list VARCHAR2(1) ;
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER ;
     l_msg_data VARCHAR2(2000);
     lp_qtev_tbl  qtev_tbl_type;
     lx_cons_rec  qtev_rec_type;

   BEGIN

     SAVEPOINT trx_create_consolidate_quote;

     l_api_version := p_api_version ;
     l_init_msg_list := p_init_msg_list ;
     l_return_status := x_return_status ;
     l_msg_count := x_msg_count ;
     l_msg_data := x_msg_data ;
     lp_qtev_tbl :=  p_qtev_tbl;
     lx_cons_rec :=  x_cons_rec;



     -- Call the PVT procedure
     OKL_AM_CONSOLIDATED_QTE_PVT.create_consolidate_quote(
                                           p_api_version   => l_api_version,
                                           p_init_msg_list => l_init_msg_list,
                                           x_msg_data      => l_msg_data,
	                                         x_msg_count     => l_msg_count,
	                                         x_return_status => l_return_status,
	                                         p_qtev_tbl      => lp_qtev_tbl,
	                                         x_cons_rec      => lx_cons_rec);

     IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
    	 RAISE FND_API.G_EXC_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



     --Assign value to OUT variables
     x_return_status := l_return_status ;
     x_msg_count := l_msg_count ;
     x_msg_data := l_msg_data ;
     x_cons_rec := lx_cons_rec;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_create_consolidate_quote;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_create_consolidate_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO trx_create_consolidate_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_CONSOLIDATED_QTE_PUB','create_consolidate_quote');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

  END create_consolidate_quote;


  -- Start of comments
  --
  -- Procedure Name	: update_consolidate_quote
  -- Description	  : Procedure to update a consolidated quote
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE update_consolidate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_cons_rec                    IN  qtev_rec_type,
           x_cons_rec                    OUT NOCOPY qtev_rec_type,
           x_qtev_tbl                    OUT NOCOPY qtev_tbl_type) IS

     l_api_version NUMBER ;
     l_init_msg_list VARCHAR2(1) ;
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER ;
     l_msg_data VARCHAR2(2000);
     lp_cons_rec  qtev_rec_type;
     lx_cons_rec  qtev_rec_type;
     lx_qtev_tbl  qtev_tbl_type;

   BEGIN

     SAVEPOINT trx_update_consolidate_quote;

     l_api_version := p_api_version ;
     l_init_msg_list := p_init_msg_list ;
     l_return_status := x_return_status ;
     l_msg_count := x_msg_count ;
     l_msg_data := x_msg_data ;
     lp_cons_rec :=  p_cons_rec;
     lx_cons_rec :=  x_cons_rec;
     lx_qtev_tbl :=  x_qtev_tbl;




     -- Call the PVT procedure
     OKL_AM_CONSOLIDATED_QTE_PVT.update_consolidate_quote(
                                           p_api_version   => l_api_version,
                                           p_init_msg_list => l_init_msg_list,
                                           x_msg_data      => l_msg_data,
	                                         x_msg_count     => l_msg_count,
	                                         x_return_status => l_return_status,
	                                         p_cons_rec      => lp_cons_rec,
	                                         x_cons_rec      => lx_cons_rec,
                                           x_qtev_tbl      => lx_qtev_tbl);

     IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
    	 RAISE FND_API.G_EXC_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Copy out parameter
     lp_cons_rec := lx_cons_rec;



     --Assign value to OUT variables
     x_return_status := l_return_status ;
     x_msg_count := l_msg_count ;
     x_msg_data := l_msg_data ;
     x_cons_rec := lx_cons_rec;
     x_qtev_tbl := lx_qtev_tbl;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_update_consolidate_quote;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_update_consolidate_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO trx_update_consolidate_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_CONSOLIDATED_QTE_PUB','update_consolidate_quote');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);

  END update_consolidate_quote;

END OKL_AM_CONSOLIDATED_QTE_PUB;

/
