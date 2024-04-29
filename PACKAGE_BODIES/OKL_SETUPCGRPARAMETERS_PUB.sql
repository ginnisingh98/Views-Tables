--------------------------------------------------------
--  DDL for Package Body OKL_SETUPCGRPARAMETERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPCGRPARAMETERS_PUB" AS
/* $Header: OKLPSCMB.pls 120.2 2005/06/03 05:30:16 rirawat noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_CNTX_GRP_PRMTRS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec(p_cgmv_rec			  IN cgmv_rec_type,
			        x_return_status		  OUT NOCOPY VARCHAR2,
					x_msg_data			  OUT NOCOPY VARCHAR2,
    				x_no_data_found       OUT NOCOPY BOOLEAN,
					x_cgmv_rec			  OUT NOCOPY cgmv_rec_type) IS
    l_cgmv_rec                        cgmv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
	l_no_data_found					  BOOLEAN;
  BEGIN

  	l_cgmv_rec := p_cgmv_rec;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_no_data_found := TRUE;

    okl_setupcgrparameters_pvt.get_rec(p_cgmv_rec      => l_cgmv_rec,
								       x_return_status => l_return_status,
								  	   x_no_data_found => l_no_data_found,
								  	   x_cgmv_rec	   => x_cgmv_rec);

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
  -- PROCEDURE insert_cgrparameters
  -- Public wrapper for insert_cgrparameters process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_cgrparameters(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        		 x_return_status    OUT NOCOPY VARCHAR2,
                        		 x_msg_count        OUT NOCOPY NUMBER,
                        		 x_msg_data         OUT NOCOPY VARCHAR2,
                        		 p_cgmv_rec         IN  cgmv_rec_type,
                        		 x_cgmv_rec         OUT NOCOPY cgmv_rec_type) IS
    l_cgmv_rec                        cgmv_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_cgrparameters';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_cgrparameters;
    l_cgmv_rec := p_cgmv_rec;



	-- call process api to insert context group parameters
    okl_setupcgrparameters_pvt.insert_cgrparameters(p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                              			  			x_return_status => l_return_status,
                              			  			x_msg_count     => x_msg_count,
                              			  			x_msg_data      => x_msg_data,
                              			  			p_cgmv_rec      => l_cgmv_rec,
                              			  			x_cgmv_rec      => x_cgmv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_cgmv_rec := x_cgmv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_cgrparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_cgrparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPCGRPARAMETERS_PUB','insert_cgrparameters');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_cgrparameters;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_cgrparameters
  -- Public wrapper for update_cgrparameters process api
  ---------------------------------------------------------------------------
  PROCEDURE update_cgrparameters(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        		 x_return_status    OUT NOCOPY VARCHAR2,
                        		 x_msg_count        OUT NOCOPY NUMBER,
                        		 x_msg_data         OUT NOCOPY VARCHAR2,
                        		 p_cgmv_rec         IN  cgmv_rec_type,
                        		 x_cgmv_rec         OUT NOCOPY cgmv_rec_type) IS
    l_cgmv_rec                        cgmv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_cgrparameters';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_update_cgrparameters;
    l_cgmv_rec := p_cgmv_rec;



	-- call process api to update context group parameters
    okl_setupcgrparameters_pvt.update_cgrparameters(p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                              			  			x_return_status => l_return_status,
                              			  			x_msg_count     => x_msg_count,
                              			  			x_msg_data      => x_msg_data,
                              			  			p_cgmv_rec      => l_cgmv_rec,
                              			  			x_cgmv_rec      => x_cgmv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_cgmv_rec := x_cgmv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_update_cgrparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_update_cgrparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPCGRPARAMETERS_PUB','update_cgrparameters');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END update_cgrparameters;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_cgrparameters
  -- Public wrapper for delete_cgrparameters process api
  ---------------------------------------------------------------------------
  PROCEDURE delete_cgrparameters(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		 x_return_status    OUT NOCOPY VARCHAR2,
                        		 x_msg_count        OUT NOCOPY NUMBER,
                        		 x_msg_data         OUT NOCOPY VARCHAR2,
                      			 p_cgmv_tbl         IN  cgmv_tbl_type) IS
    l_cgmv_tbl                        cgmv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_cgrparameters';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_delete_cgrparameters;

    l_cgmv_tbl := p_cgmv_tbl;



	-- call process api to delete formula operands
    okl_setupcgrparameters_pvt.delete_cgrparameters(p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                              			  			x_return_status => l_return_status,
                              			  			x_msg_count     => x_msg_count,
                              			  			x_msg_data      => x_msg_data,
                              			  			p_cgmv_tbl      => l_cgmv_tbl);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_delete_cgrparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_delete_cgrparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPCGRPARAMETERS_PUB','delete_cgrparameters');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END delete_cgrparameters;

-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_CNTX_GRP_PRMTRS_V - TBL : begin
  ---------------------------------------------------------------------------
  -- PROCEDURE insert_cgrparameters
  -- Public wrapper for insert_cgrparameters process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_cgrparameters(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        		 x_return_status    OUT NOCOPY VARCHAR2,
                        		 x_msg_count        OUT NOCOPY NUMBER,
                        		 x_msg_data         OUT NOCOPY VARCHAR2,
                        		 p_cgmv_tbl         IN  cgmv_tbl_type,
                        		 x_cgmv_tbl         OUT NOCOPY cgmv_tbl_type) IS
    l_cgmv_tbl                        cgmv_tbl_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_cgrparameters';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_cgrparameters;
    l_cgmv_tbl := p_cgmv_tbl;

    -- call process api to insert context group parameters
    okl_setupcgrparameters_pvt.insert_cgrparameters(p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
    						    x_return_status => l_return_status,
						    x_msg_count     => x_msg_count,
						    x_msg_data      => x_msg_data,
						    p_cgmv_tbl      => l_cgmv_tbl,
						    x_cgmv_tbl      => x_cgmv_tbl);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_cgmv_tbl := x_cgmv_tbl;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_cgrparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  			p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_cgrparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  		        p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPCGRPARAMETERS_PUB','insert_cgrparameters');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_cgrparameters;

-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_CNTX_GRP_PRMTRS_V - TBL : end

-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_CNTX_GRP_PRMTRS_V - TBL : begin
  ---------------------------------------------------------------------------
  -- PROCEDURE update_cgrparameters
  -- Public wrapper for update_cgrparameters process api
  ---------------------------------------------------------------------------
  PROCEDURE update_cgrparameters(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        		 x_return_status    OUT NOCOPY VARCHAR2,
                        		 x_msg_count        OUT NOCOPY NUMBER,
                        		 x_msg_data         OUT NOCOPY VARCHAR2,
                        		 p_cgmv_tbl         IN  cgmv_tbl_type,
                        		 x_cgmv_tbl         OUT NOCOPY cgmv_tbl_type) IS
    l_cgmv_tbl                        cgmv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_cgrparameters';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_update_cgrparameters;
    l_cgmv_tbl := p_cgmv_tbl;

	-- call process api to update context group parameters
    okl_setupcgrparameters_pvt.update_cgrparameters(p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
 						    x_return_status => l_return_status,
						    x_msg_count     => x_msg_count,
						    x_msg_data      => x_msg_data,
						    p_cgmv_tbl      => l_cgmv_tbl,
						    x_cgmv_tbl      => x_cgmv_tbl);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_cgmv_tbl := x_cgmv_tbl;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_update_cgrparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  			p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_update_cgrparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  			p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPCGRPARAMETERS_PUB','update_cgrparameters');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  			p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END update_cgrparameters;
-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_CNTX_GRP_PRMTRS_V - TBL : end


END OKL_SETUPCGRPARAMETERS_PUB;

/
