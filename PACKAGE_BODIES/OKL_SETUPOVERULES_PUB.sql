--------------------------------------------------------
--  DDL for Package Body OKL_SETUPOVERULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPOVERULES_PUB" AS
/* $Header: OKLPSODB.pls 115.4 2004/04/13 11:18:26 rnaik noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_OPV_RULES_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec(p_ovdv_rec			  IN ovdv_rec_type,
			        x_return_status		  OUT NOCOPY VARCHAR2,
					x_msg_data			  OUT NOCOPY VARCHAR2,
    				x_no_data_found       OUT NOCOPY BOOLEAN,
					x_ovdv_rec			  OUT NOCOPY ovdv_rec_type) IS
    l_ovdv_rec                        ovdv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
	l_no_data_found					  BOOLEAN;
  BEGIN

  	l_ovdv_rec := p_ovdv_rec;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_no_data_found := TRUE;

    okl_setupoverules_pvt.get_rec(p_ovdv_rec      => l_ovdv_rec,
								  x_return_status => l_return_status,
								  x_no_data_found => l_no_data_found,
								  x_ovdv_rec	  => x_ovdv_rec);

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  x_no_data_found := FALSE;
	  FND_MESSAGE.set_name(application	=> G_APP_NAME,
	  					   name			=> G_UNEXPECTED_ERROR);
	  x_msg_data := FND_MESSAGE.get;
  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_overules
  -- Public wrapper for insert_overules process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_overules(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
							p_optv_rec		   IN  optv_rec_type,
                            p_ovev_rec         IN  ovev_rec_type,
                        	p_ovdv_rec         IN  ovdv_rec_type,
                        	x_ovdv_rec         OUT NOCOPY ovdv_rec_type) IS
	l_optv_rec						  optv_rec_type;
	l_ovev_rec						  ovev_rec_type;
    l_ovdv_rec                        ovdv_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_overules';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_overules;

    l_optv_rec := p_optv_rec;
    l_ovev_rec := p_ovev_rec;
    l_ovdv_rec := p_ovdv_rec;



	-- call process api to insert formula operands
    okl_setupoverules_pvt.insert_overules(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_optv_rec      => l_optv_rec,
                                          p_ovev_rec      => l_ovev_rec,
                              			  p_ovdv_rec      => l_ovdv_rec,
                              			  x_ovdv_rec      => x_ovdv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_ovdv_rec := x_ovdv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_overules;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_overules;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPOVERULES_PUB','insert_overules');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_overules;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_overules
  -- Public wrapper for delete_overules process api
  ---------------------------------------------------------------------------
  PROCEDURE delete_overules(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
  							p_optv_rec		   IN  optv_rec_type,
                            p_ovev_rec         IN  ovev_rec_type,
                      		p_ovdv_tbl         IN  ovdv_tbl_type) IS
	l_optv_rec						  optv_rec_type;
    l_ovev_rec                        ovev_rec_type;
    l_ovdv_tbl                        ovdv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_overules';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_delete_overules;

    l_optv_rec := p_optv_rec;
    l_ovev_rec := p_ovev_rec;
    l_ovdv_tbl := p_ovdv_tbl;



	-- call process api to delete formula operands
    okl_setupoverules_pvt.delete_overules(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                              			  	x_return_status => l_return_status,
                              			  	x_msg_count     => x_msg_count,
                              			  	x_msg_data      => x_msg_data,
                              			  	p_optv_rec      => l_optv_rec,
                                            p_ovev_rec      => l_ovev_rec,
                              			  	p_ovdv_tbl      => l_ovdv_tbl);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_delete_overules;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_delete_overules;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPOVERULES_PUB','delete_overules');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END delete_overules;

END OKL_SETUPOVERULES_PUB;

/
