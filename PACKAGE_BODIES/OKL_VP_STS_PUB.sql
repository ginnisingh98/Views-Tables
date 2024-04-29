--------------------------------------------------------
--  DDL for Package Body OKL_VP_STS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_STS_PUB" AS
/*$Header: OKLPSSCB.pls 115.7 2004/04/13 11:21:13 rnaik noship $*/

  ---------------------------------------------------------------------------
  -- PROCEDURE get_listof_new_statuses
  -- Public wrapper for STATUS PROCESS API
  ---------------------------------------------------------------------------
  PROCEDURE get_listof_new_statuses(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ste_code                     IN  VARCHAR2,
    p_sts_code                     IN  VARCHAR2,
    p_start_date                   IN  DATE,
    p_end_date                     IN  DATE,
    x_sts_tbl                      OUT NOCOPY sts_tbl_type)
    IS

    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'get_listof_new_statuses';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_contract_id                     NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;




  -- call process api to get list of new statuses

  OKL_VP_STS_PVT.get_listof_new_statuses(
                      p_api_version,
                      p_init_msg_list,
                      x_return_status,
                      x_msg_count,
                      x_msg_data,
                      p_ste_code,
                      p_sts_code,
                      p_start_date,
                      p_end_date,
                      x_sts_tbl);


  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;




EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  -- notify caller of an UNEXPECTED error
  x_return_status := FND_API.G_RET_STS_ERROR;

  -- store SQL error message on message stack for caller
  FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  -- notify caller of an UNEXPECTED error
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  -- store SQL error message on message stack for caller
  FND_MSG_PUB.count_and_get(p_encoded => OKC_API.G_FALSE,
	                    p_count   => x_msg_count,
                            p_data    => x_msg_data);

WHEN OTHERS THEN
  -- notify caller of an UNEXPECTED error
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.ADD_EXC_MSG('OKL_VP_STS_PUB','get_listof_new_statuses');

  -- store SQL error message on message stack for caller
  FND_MSG_PUB.count_and_get(p_encoded => OKC_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
  END get_listof_new_statuses;



PROCEDURE change_agreement_status(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       in number,
    p_current_sts_code             in VARCHAR2,
    p_new_sts_code                 in varchar2)

IS

  l_data                            VARCHAR2(100);
  l_api_name                        CONSTANT VARCHAR2(30)  := 'change_agreement_status';
  l_count                           NUMBER ;
  l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  l_contract_id                     NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;



  -- call process api to CHANGE Status

  OKL_VP_STS_PVT.change_agreement_status(
                        p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        p_chr_id,
                        p_current_sts_code,
                        p_new_sts_code);


  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;





EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  -- notify caller of an UNEXPECTED error
  x_return_status := FND_API.G_RET_STS_ERROR;

  -- store SQL error message on message stack for caller
  FND_MSG_PUB.count_and_get(p_encoded => OKC_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  -- notify caller of an UNEXPECTED error
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  -- store SQL error message on message stack for caller
  FND_MSG_PUB.count_and_get(p_encoded => OKC_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);

WHEN OTHERS THEN
  -- notify caller of an UNEXPECTED error
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.ADD_EXC_MSG('OKL_VP_STS_PUB','get_listof_new_statuses');

  -- store SQL error message on message stack for caller
  FND_MSG_PUB.count_and_get(p_encoded => OKC_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);

END change_agreement_status;


END OKL_VP_STS_PUB;

/
