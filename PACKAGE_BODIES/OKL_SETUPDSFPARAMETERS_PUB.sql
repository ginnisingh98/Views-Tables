--------------------------------------------------------
--  DDL for Package Body OKL_SETUPDSFPARAMETERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPDSFPARAMETERS_PUB" AS
/* $Header: OKLPSFRB.pls 120.2 2005/06/03 05:31:40 rirawat noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_FMLA_OPRNDS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec(p_fprv_rec			  IN fprv_rec_type,
			        x_return_status		  OUT NOCOPY VARCHAR2,
					x_msg_data			  OUT NOCOPY VARCHAR2,
    				x_no_data_found       OUT NOCOPY BOOLEAN,
					x_fprv_rec			  OUT NOCOPY fprv_rec_type) IS
    l_fprv_rec                        fprv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
	l_no_data_found					  BOOLEAN;
  BEGIN

  	l_fprv_rec := p_fprv_rec;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_no_data_found := TRUE;

    okl_setupdsfparameters_pvt.get_rec(p_fprv_rec      => l_fprv_rec,
								       x_return_status => l_return_status,
								  	   x_no_data_found => l_no_data_found,
								  	   x_fprv_rec	   => x_fprv_rec);

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
  -- PROCEDURE insert_dsfparameters
  -- Public wrapper for insert_dsfparameters process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_dsfparameters(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        		 x_return_status    OUT NOCOPY VARCHAR2,
                        		 x_msg_count        OUT NOCOPY NUMBER,
                        		 x_msg_data         OUT NOCOPY VARCHAR2,
								 p_dsfv_rec		 	IN  dsfv_rec_type,
                        		 p_fprv_rec         IN  fprv_rec_type,
                        		 x_fprv_rec         OUT NOCOPY fprv_rec_type) IS
	l_dsfv_rec						  dsfv_rec_type;
    l_fprv_rec                        fprv_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_dsfparameters';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_dsfparameters;

    l_dsfv_rec := p_dsfv_rec;
    l_fprv_rec := p_fprv_rec;



	-- call process api to insert function parameters
    okl_setupdsfparameters_pvt.insert_dsfparameters(p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                              			  			x_return_status => l_return_status,
                              			  			x_msg_count     => x_msg_count,
                              			  			x_msg_data      => x_msg_data,
                              			  			p_dsfv_rec      => l_dsfv_rec,
                              			  			p_fprv_rec      => l_fprv_rec,
                              			  			x_fprv_rec      => x_fprv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_fprv_rec := x_fprv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_dsfparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_dsfparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPDSFPARAMETERS_PUB','insert_dsfparameters');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_dsfparameters;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_dsfparameters
  -- Public wrapper for update_dsfparameters process api
  ---------------------------------------------------------------------------
  PROCEDURE update_dsfparameters(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        		 x_return_status    OUT NOCOPY VARCHAR2,
                        		 x_msg_count        OUT NOCOPY NUMBER,
                        		 x_msg_data         OUT NOCOPY VARCHAR2,
  								 p_dsfv_rec		 	IN  dsfv_rec_type,
                      			 p_fprv_rec         IN  fprv_rec_type,
                        		 x_fprv_rec         OUT NOCOPY fprv_rec_type) IS
	l_dsfv_rec						  dsfv_rec_type;
    l_fprv_rec                        fprv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_dsfparameters';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_update_dsfparameters;

    l_dsfv_rec := p_dsfv_rec;
    l_fprv_rec := p_fprv_rec;



	-- call process api to update function parameters
    okl_setupdsfparameters_pvt.update_dsfparameters(p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                              			  			x_return_status => l_return_status,
                              			  			x_msg_count     => x_msg_count,
                              			  			x_msg_data      => x_msg_data,
                              			  			p_dsfv_rec      => l_dsfv_rec,
                              			  			p_fprv_rec      => l_fprv_rec,
                              			  			x_fprv_rec      => x_fprv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_fprv_rec := x_fprv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_update_dsfparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_update_dsfparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPDSFPARAMETERS_PUB','update_dsfparameters');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END update_dsfparameters;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_dsfparameters
  -- Public wrapper for delete_dsfparameters process api
  ---------------------------------------------------------------------------
  PROCEDURE delete_dsfparameters(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		 x_return_status    OUT NOCOPY VARCHAR2,
                        		 x_msg_count        OUT NOCOPY NUMBER,
                        		 x_msg_data         OUT NOCOPY VARCHAR2,
                      			 p_fprv_tbl         IN  fprv_tbl_type) IS
    l_fprv_tbl                        fprv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_dsfparameters';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_delete_dsfparameters;

    l_fprv_tbl := p_fprv_tbl;



	-- call process api to delete function parameters
    okl_setupdsfparameters_pvt.delete_dsfparameters(p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                              			  			x_return_status => l_return_status,
                              			  			x_msg_count     => x_msg_count,
                              			  			x_msg_data      => x_msg_data,
                              			  			p_fprv_tbl      => l_fprv_tbl);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_delete_dsfparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_delete_dsfparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPDSFPARAMETERS_PUB','delete_dsfparameters');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END delete_dsfparameters;

-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_FNCTN_PRMTRS_V - TBL : begin
  ---------------------------------------------------------------------------
  -- PROCEDURE insert_dsfparameters
  -- Public wrapper for insert_dsfparameters process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_dsfparameters(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        		 x_return_status    OUT NOCOPY VARCHAR2,
                        		 x_msg_count        OUT NOCOPY NUMBER,
                        		 x_msg_data         OUT NOCOPY VARCHAR2,
								 p_dsfv_rec		 	IN  dsfv_rec_type,
                        		 p_fprv_tbl         IN  fprv_tbl_type,
                        		 x_fprv_tbl         OUT NOCOPY fprv_tbl_type) IS
	l_dsfv_rec						  dsfv_rec_type;
    l_fprv_tbl                        fprv_tbl_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_dsfparameters';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_dsfparameters;

    l_dsfv_rec := p_dsfv_rec;
    l_fprv_tbl := p_fprv_tbl;


	-- call process api to insert function parameters
    okl_setupdsfparameters_pvt.insert_dsfparameters(p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                              			  			x_return_status => l_return_status,
                              			  			x_msg_count     => x_msg_count,
                              			  			x_msg_data      => x_msg_data,
                              			  			p_dsfv_rec      => l_dsfv_rec,
                              			  			p_fprv_tbl      => l_fprv_tbl,
                              			  			x_fprv_tbl      => x_fprv_tbl);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_dsfparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_dsfparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPDSFPARAMETERS_PUB','insert_dsfparameters');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_dsfparameters;
-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_FNCTN_PRMTRS_V - TBL : end

-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_FNCTN_PRMTRS_V - TBL : begin
  ---------------------------------------------------------------------------
  -- PROCEDURE update_dsfparameters
  -- Public wrapper for update_dsfparameters process api
  ---------------------------------------------------------------------------
  PROCEDURE update_dsfparameters(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        		 x_return_status    OUT NOCOPY VARCHAR2,
                        		 x_msg_count        OUT NOCOPY NUMBER,
                        		 x_msg_data         OUT NOCOPY VARCHAR2,
								 p_dsfv_rec		 	IN  dsfv_rec_type,
                        		 p_fprv_tbl         IN  fprv_tbl_type,
                        		 x_fprv_tbl         OUT NOCOPY fprv_tbl_type) IS
	l_dsfv_rec						  dsfv_rec_type;
    l_fprv_tbl                        fprv_tbl_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_dsfparameters';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_update_dsfparameters;

    l_dsfv_rec := p_dsfv_rec;
    l_fprv_tbl := p_fprv_tbl;

	-- call process api to update function parameters
    okl_setupdsfparameters_pvt.update_dsfparameters(p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                              			  			x_return_status => l_return_status,
                              			  			x_msg_count     => x_msg_count,
                              			  			x_msg_data      => x_msg_data,
                              			  			p_dsfv_rec      => l_dsfv_rec,
                              			  			p_fprv_tbl      => l_fprv_tbl,
                              			  			x_fprv_tbl      => x_fprv_tbl);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_update_dsfparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_update_dsfparameters;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPDSFPARAMETERS_PUB','update_dsfparameters');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END update_dsfparameters;

-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_FNCTN_PRMTRS_V - TBL : end



END OKL_SETUPDSFPARAMETERS_PUB;

/
