--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_PROVISIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_PROVISIONS_PUB" AS
/* $Header: OKLPPRVB.pls 115.4 2002/12/18 12:29:25 kjinger noship $ */

  PROCEDURE create_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type,
    x_pvnv_rec                     OUT NOCOPY pvnv_rec_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'CREATE_PROVISIONS';
      l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_pvnv_rec          pvnv_rec_type := p_pvnv_rec;

	BEGIN
      SAVEPOINT insert_provisions;

      x_return_status    := FND_API.G_RET_STS_SUCCESS;

       -- customer pre-processing



          -- CALL THE MAIN PROCEDURE
	      OKL_PROCESS_PROVISIONS_PVT.CREATE_PROVISIONS(p_api_version     => l_api_version,
                                                       p_init_msg_list   => p_init_msg_list,
    									               x_return_status   => x_return_Status,
    										           x_msg_count       => x_msg_count,
    										           x_msg_data        => x_msg_data,
    										   		   p_pvnv_rec        => p_pvnv_rec,
													   x_pvnv_rec        => x_pvnv_rec);

          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

       -- customer post-processing


  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_provisions;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_provisions;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_PROVISIONS_PUB','CREATE_PROVISIONS');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_provisions;


  PROCEDURE create_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'CREATE_PROVISIONS';
      l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_pvnv_tbl          pvnv_tbl_type := p_pvnv_tbl;

	BEGIN
      SAVEPOINT insert_provisions;

      x_return_status    := FND_API.G_RET_STS_SUCCESS;

       -- customer pre-processing


          -- Call the main procedure
          OKL_PROCESS_PROVISIONS_PVT.CREATE_PROVISIONS(p_api_version     => l_api_version,
                                                       p_init_msg_list   => p_init_msg_list,
    				          					       x_return_status   => x_return_Status,
    							        			   x_msg_count       => x_msg_count,
    									         	   x_msg_data        => x_msg_data,
             										   p_pvnv_tbl        => p_pvnv_tbl,
    		        								   x_pvnv_tbl        => x_pvnv_tbl);


          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

       -- customer post-processing


  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_provisions;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_provisions;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_PROVISIONS_PUB','CREATE_PROVISIONS');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_provisions;


  PROCEDURE update_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type,
    x_pvnv_rec                     OUT NOCOPY pvnv_rec_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'UPDATE_PROVISIONS';
      l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_pvnv_rec          pvnv_rec_type := p_pvnv_rec;

	BEGIN
      SAVEPOINT update_provisions;
      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      -- customer pre-processing

              -- CALL THE MAIN PROCEDURE
    	      OKL_PROCESS_PROVISIONS_PVT.UPDATE_PROVISIONS(p_api_version     => l_api_version,
                                                           p_init_msg_list   => p_init_msg_list,
    		            							       x_return_status   => x_return_Status,
    					            					   x_msg_count       => x_msg_count,
    								            		   x_msg_data        => x_msg_data,
                  										   p_pvnv_rec        => p_pvnv_rec,
    			            							   x_pvnv_rec        => x_pvnv_rec);
          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

       -- customer post-processing

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_provisions;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_provisions;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_PROVISIONS_PUB','CREATE_PROVISIONS');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_provisions;


  PROCEDURE update_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'UPDATE_PROVISIONS';
      l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_pvnv_tbl          pvnv_tbl_type := p_pvnv_tbl;

	BEGIN
      SAVEPOINT update_provisions;
      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      -- customer pre-processing

          -- CALL THE MAIN PROCEDURE
   	      OKL_PROCESS_PROVISIONS_PVT.UPDATE_PROVISIONS(p_api_version     => l_api_version,
                                                       p_init_msg_list   => p_init_msg_list,
    	 	          							       x_return_status   => x_return_Status,
    					        					   x_msg_count       => x_msg_count,
    							        			   x_msg_data        => x_msg_data,
               										   p_pvnv_tbl        => p_pvnv_tbl,
    		        								   x_pvnv_tbl        => x_pvnv_tbl);
          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

       -- customer post-processing

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_provisions;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_provisions;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_PROVISIONS_PUB','CREATE_PROVISIONS');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_provisions;


  PROCEDURE delete_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type)

	IS
      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'DELETE_PROVISIONS';
      l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_pvnv_rec          pvnv_rec_type := p_pvnv_rec;

	BEGIN
      SAVEPOINT delete_provisions;
      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      -- customer pre-processing

          -- CALL THE MAIN PROCEDURE
  	      OKL_PROCESS_PROVISIONS_PVT.DELETE_PROVISIONS(p_api_version     => l_api_version,
                                                       p_init_msg_list   => p_init_msg_list,
    	          								       x_return_status   => x_return_Status,
    				         						   x_msg_count       => x_msg_count,
    							        			   x_msg_data        => x_msg_data,
    									        	   p_pvnv_rec        => p_pvnv_rec);
          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

       -- customer post-processing

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_provisions;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_provisions;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_PROVISIONS_PUB','CREATE_PROVISIONS');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_provisions;

  PROCEDURE delete_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type)

  IS

      l_api_version       CONSTANT NUMBER        := 1.0;
      l_api_name          CONSTANT VARCHAR2(30)  := 'DELETE_PROVISIONS';
      l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_pvnv_tbl          pvnv_tbl_type := p_pvnv_tbl;

  BEGIN
      SAVEPOINT delete_provisions;
      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      -- customer pre-processing

          -- CALL THE MAIN PROCEDURE
  	      OKL_PROCESS_PROVISIONS_PVT.DELETE_PROVISIONS(p_api_version     => l_api_version,
                                                       p_init_msg_list   => p_init_msg_list,
    		         							       x_return_status   => x_return_Status,
    					          					   x_msg_count       => x_msg_count,
    								          		   x_msg_data        => x_msg_data,
            										   p_pvnv_tbl        => p_pvnv_tbl);
          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

       -- customer post-processing

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_provisions;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_provisions;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_PROVISIONS_PUB','CREATE_PROVISIONS');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_provisions;

END OKL_PROCESS_PROVISIONS_PUB;

/
