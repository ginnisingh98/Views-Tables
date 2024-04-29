--------------------------------------------------------
--  DDL for Package Body OKL_ASSET_DETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ASSET_DETAILS_PUB" AS
/* $Header: OKLPADSB.pls 115.3 2004/04/13 10:27:43 rnaik noship $ */


  PROCEDURE Update_year(
                      p_api_version            IN  NUMBER,
                      p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                      x_return_status          OUT NOCOPY VARCHAR2,
                      x_msg_count              OUT NOCOPY NUMBER,
                      x_msg_data               OUT NOCOPY VARCHAR2,
                      p_dnz_chr_id             IN  NUMBER,
                      p_parent_line_id         IN  NUMBER,
                      p_year                   IN  VARCHAR2,
                      x_year                   OUT NOCOPY VARCHAR2)
  AS
    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
  BEGIN
  g_api_name := 'Update Year';





  --End Vertical User Hook Call
  --Call to private API

    okl_asset_details_pvt.update_year(  p_api_version            => p_api_version,
                                            p_init_msg_list          => p_init_msg_list,
                                            x_return_status          => l_return_status,
                                            x_msg_count              => l_msg_count,
                                            x_msg_data               => l_msg_data,
                                            p_dnz_chr_id             => p_dnz_chr_id,
                                            p_parent_line_id         => p_parent_line_id,
                                            p_year                   => p_year,
                                            x_year                   => x_year);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

 --End Call to Private API



  --End Vertical Post Processing Hook

  --Start Horizontal Post Processing Hook



  --End Horizontal Post Processing User Hook

  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ASSET_DETAILS_PUB','Update_Year');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END update_year;

  PROCEDURE update_tax(p_api_version            IN  NUMBER,
                     p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status          OUT NOCOPY VARCHAR2,
                     x_msg_count              OUT NOCOPY NUMBER,
                     x_msg_data               OUT NOCOPY VARCHAR2,
                     p_rule_id                IN  NUMBER,
                     p_rule_grp_id            IN  NUMBER,
                     p_dnz_chr_id             IN  NUMBER,
                     p_rule_information1      IN  VARCHAR2,
                     p_rule_information2      IN  VARCHAR2,
                     p_rule_information3      IN  VARCHAR2,
                     p_rule_information4      IN  VARCHAR2,
                     x_rule_information1      OUT  NOCOPY VARCHAR2,
                     x_rule_information2      OUT  NOCOPY VARCHAR2,
                     x_rule_information3      OUT  NOCOPY VARCHAR2,
                     x_rule_information4      OUT  NOCOPY VARCHAR2)
  AS
    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
  BEGIN
  g_api_name := 'Update Tax';





  --End Vertical User Hook Call

    ---Call to private API
  okl_asset_details_pvt.update_tax(p_api_version                   =>p_api_version,
                                          p_init_msg_list          => p_init_msg_list,
                                          x_return_status          => l_return_status,
                                          x_msg_count              => l_msg_count,
                                          x_msg_data               => l_msg_data,
                                          p_rule_id                => p_rule_id,
                                          p_rule_grp_id            => p_rule_grp_id,
                                          p_dnz_chr_id             => p_dnz_chr_id,
                                          p_rule_information1      => p_rule_information1,
                                          p_rule_information2      => p_rule_information2,
                                          p_rule_information3      => p_rule_information3,
                                          p_rule_information4      => p_rule_information4,
                                          x_rule_information1      => x_rule_information1,
                                          x_rule_information2      => x_rule_information2,
                                          x_rule_information3      => x_rule_information3,
                                          x_rule_information4      => x_rule_information4);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

 --End Call to Private API



  --End Vertical Post Processing Hook

  --Start Horizontal Post Processing Hook



  --End Horizontal Post Processing User Hook

  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ASSET_DETAILS_PUB','Update_Tax');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END update_Tax;

PROCEDURE update_asset(p_api_version            IN     NUMBER,
                         p_init_msg_list        IN     VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status        OUT    NOCOPY VARCHAR2,
                         x_msg_count            OUT    NOCOPY NUMBER,
                         x_msg_data             OUT    NOCOPY VARCHAR2,
                         p_asset_id             IN     NUMBER,
                         p_asset_number         IN     VARCHAR2,
                         px_asset_desc          IN OUT NOCOPY VARCHAR2,
                         px_model_no            IN OUT NOCOPY VARCHAR2,
                         px_manufacturer        IN OUT NOCOPY VARCHAR2)
  AS
    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
  BEGIN
  g_api_name := 'Update Asset';





  --End Vertical User Hook Call

  --Call to private API
    okl_asset_details_pvt.update_asset(p_api_version          => p_api_version,
                                       p_init_msg_list        => p_init_msg_list,
                                       x_return_status        => l_return_status,
                                       x_msg_count            => l_msg_count,
                                       x_msg_data             => l_msg_data,
                                       p_asset_id             => p_asset_id,
                                       p_asset_number         => p_asset_number,
                                       px_asset_desc          => px_asset_desc,
                                       px_model_no            => px_model_no,
                                       px_manufacturer        => px_manufacturer);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

 --End Call to Private API



  --End Vertical Post Processing Hook

  --Start Horizontal Post Processing Hook



  --End Horizontal Post Processing User Hook

  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ASSET_DETAILS_PUB','Update_Asset');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END update_Asset;

 END okl_asset_details_pub;

/
