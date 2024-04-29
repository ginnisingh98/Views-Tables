--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNT_DIST_MISC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNT_DIST_MISC_PUB" AS
/* $Header: OKLPTDSB.pls 115.4 2002/12/18 12:42:47 kjinger noship $ */


PROCEDURE insert_updt_dstrs(p_api_version         IN  NUMBER,
                            p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2,
                            p_tabv_tbl            IN  tabv_tbl_type,
                            x_tabv_tbl            OUT NOCOPY tabv_tbl_type)

IS
  l_api_version       CONSTANT NUMBER        := 1.0;
  l_api_name          CONSTANT VARCHAR2(30)  := 'INSERT_UPDT_DSTRS';
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_tabv_tbl          tabv_tbl_type := p_tabv_tbl;



BEGIN


  SAVEPOINT insert_updt_dstrs;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure


   OKL_ACCOUNT_DIST_MISC_PVT.insert_updt_dstrs(p_api_version         => l_api_version,
                                               p_init_msg_list       => p_init_msg_list,
                                               x_return_status       => x_return_status,
                                               x_msg_count           => x_msg_count,
                                               x_msg_data            => x_msg_data,
                                               p_tabv_tbl            => l_tabv_tbl,
                                               x_tabv_tbl            => x_tabv_tbl);


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;

  END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_updt_dstrs;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_updt_dstrs;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCOUNT_DIST_MISC_PUB','INSERT_UPDT_DSTRS');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;





END insert_updt_dstrs;


END OKL_ACCOUNT_DIST_MISC_PUB;

/
