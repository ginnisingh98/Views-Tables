--------------------------------------------------------
--  DDL for Package Body OKL_INTEREST_MAINT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INTEREST_MAINT_PUB" AS
/* $Header: OKLPINMB.pls 115.5 2002/12/18 12:22:06 kjinger noship $ */



PROCEDURE INT_HDR_INS_UPDT(p_api_version                      IN      NUMBER,
                           p_init_msg_list                    IN      VARCHAR2,
                           x_return_status                    OUT     NOCOPY VARCHAR2,
                           x_msg_count                        OUT     NOCOPY NUMBER,
                           x_msg_data                         OUT     NOCOPY VARCHAR2,
                           p_idxv_rec                         IN      idxv_rec_type)
AS

l_api_version       NUMBER := 1.0;
l_api_name          CONSTANT VARCHAR2(30)  := 'INT_HDR_INS_UPDT';
l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_idxv_rec   IDXV_REC_TYPE := p_idxv_rec;

BEGIN

  SAVEPOINT INT_HDR_INS_UPDT1;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing





-- Execute the Main Procedure

   OKL_INTEREST_MAINT_PVT.INT_HDR_INS_UPDT(p_api_version      => l_api_version,
                                           p_init_msg_list    => p_init_msg_list,
                                           x_return_status    => x_return_status,
                                           x_msg_count        => x_msg_count,
                                           x_msg_data         => x_msg_data,
                                           p_idxv_rec         => l_idxv_rec);


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

  END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO INT_HDR_INS_UPDT1;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO INT_HDR_INS_UPDT1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      ROLLBACK TO INT_HDR_INS_UPDT1;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INTEREST_MAINT_PUB','INT_HDR_INS_UPDT');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END INT_HDR_INS_UPDT;


PROCEDURE INT_HDR_INS_UPDT(p_api_version           IN      NUMBER,
                           p_init_msg_list         IN      VARCHAR2,
                           x_return_status         OUT     NOCOPY VARCHAR2,
                           x_msg_count             OUT     NOCOPY NUMBER,
                           x_msg_data              OUT     NOCOPY VARCHAR2,
                           p_idxv_tbl              IN      idxv_tbl_type)
AS


l_api_version       NUMBER := 1.0;
l_api_name          CONSTANT VARCHAR2(30)  := 'INT_HDR_INS_UPDT';
l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_idxv_tbl   IDXV_TBL_TYPE := p_idxv_tbl;


BEGIN


  SAVEPOINT INT_HDR_INS_UPDT1;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Execute the Main Procedure

  OKL_INTEREST_MAINT_PVT.INT_HDR_INS_UPDT(p_api_version      => l_api_version,
                                          p_init_msg_list    => p_init_msg_list,
                                          x_return_status    => x_return_Status,
                                          x_msg_count        => x_msg_count,
                                          x_msg_data         => x_msg_data,
                                          p_idxv_tbl         => p_idxv_tbl);


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN

      RAISE FND_API.G_EXC_ERROR;

  END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO INT_HDR_INS_UPDT1;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO INT_HDR_INS_UPDT1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      ROLLBACK TO INT_HDR_INS_UPDT1;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INTEREST_MAINT_PUB','INT_HDR_INS_UPDT');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END INT_HDR_INS_UPDT;



PROCEDURE INT_DTL_INS_UPDT(p_api_version                      IN      NUMBER,
                           p_init_msg_list                    IN      VARCHAR2,
                           x_return_status                    OUT     NOCOPY VARCHAR2,
                           x_msg_count                        OUT     NOCOPY NUMBER,
                           x_msg_data                         OUT     NOCOPY VARCHAR2,
                           p_ivev_rec                         IN      ivev_rec_type)
AS

l_api_version       NUMBER := 1.0;
l_api_name          CONSTANT VARCHAR2(30)  := 'INT_DTL_INS_UPDT';
l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_ivev_rec   IVEV_REC_TYPE := p_ivev_rec;

BEGIN

  SAVEPOINT INT_DTL_INS_UPDT1;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the Main Procedure

  OKL_INTEREST_MAINT_PVT.INT_DTL_INS_UPDT(p_api_version         => l_api_version,
                                          p_init_msg_list       => p_init_msg_list,
                                          x_return_status       => x_return_status,
                                          x_msg_count           => x_msg_count,
                                          x_msg_data            => x_msg_data,
                                          p_ivev_rec            => p_ivev_rec);


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO INT_DTL_INS_UPDT1;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO INT_DTL_INS_UPDT1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      ROLLBACK TO INT_DTL_INS_UPDT1;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INTEREST_MAINT_PUB','INT_DTL_INS_UPDT');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;




END INT_DTL_INS_UPDT;


PROCEDURE INT_DTL_INS_UPDT(p_api_version                  IN      NUMBER,
                           p_init_msg_list                IN      VARCHAR2,
                           x_return_status                OUT     NOCOPY VARCHAR2,
                           x_msg_count                    OUT     NOCOPY NUMBER,
                           x_msg_data                     OUT     NOCOPY VARCHAR2,
                           p_ivev_tbl                     IN      ivev_tbl_type)
AS

l_api_version   NUMBER := 1.0;

l_api_name          CONSTANT VARCHAR2(30)  := 'INT_DTL_INS_UPDT';
l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_ivev_tbl   IVEV_TBL_TYPE := p_ivev_tbl;


BEGIN

  SAVEPOINT INT_DTL_INS_UPDT1;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the Main Procedure


  OKL_INTEREST_MAINT_PVT.INT_DTL_INS_UPDT(p_api_version        => l_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_ivev_tbl           => p_ivev_tbl);


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO INT_DTL_INS_UPDT1;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO INT_DTL_INS_UPDT1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      ROLLBACK TO INT_DTL_INS_UPDT1;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INTEREST_MAINT_PUB','INT_DTL_INS_UPDT');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END INT_DTL_INS_UPDT;


END OKL_INTEREST_MAINT_PUB;

/
