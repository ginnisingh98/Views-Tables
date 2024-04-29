--------------------------------------------------------
--  DDL for Package Body OKL_ACCT_SOURCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCT_SOURCES_PUB" AS
/* $Header: OKLPASEB.pls 120.2 2005/10/30 04:01:22 appldev noship $ */


/*============================================================================
|                                                                            |
|  Procedure    : update_acct_src_custom_status                              |
|  Description  : Procedure to update only the custom status. This will be   |
|                 updated once the accounting sources are processed by the   |
|                 customer. This will be used at customization.              |
|  Parameters   : p_account_source_id - ID of the account sources record     |
|		  which requires to be updated.				     |
|		  p_custom_status - New status to which the account sources  |
|		  record to be updated					     |
|  History      : 07-05-04 santonyr    -- Created                            |
|                                                                            |
*============================================================================*/

  PROCEDURE update_acct_src_custom_status(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_account_source_id		   IN NUMBER,
    p_custom_status		   IN VARCHAR2) IS

    l_asev_rec                        asev_rec_type;
    x_asev_rec                        asev_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_acct_src_custom_status';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    SAVEPOINT update_acct_src_custom_status;

-- Populate the l_asev_rec with the passed values.

    l_asev_rec.id := p_account_source_id;
    l_asev_rec.custom_status := p_custom_status;

-- Call Okl_acct_sources_Pvt.update_acct_src_custom_status to update
-- the account sources record.

    Okl_acct_sources_Pvt.update_acct_src_custom_status(
                               p_api_version   => p_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_asev_rec      => l_asev_rec
                              ,x_asev_rec      => x_asev_rec
                              );

     IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE Fnd_Api.G_EXC_ERROR;
     ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_asev_rec := x_asev_rec;

  EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO update_acct_src_custom_status;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;

      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acct_src_custom_status;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      Fnd_Msg_Pub.ADD_EXC_MSG('Okl_acct_sources_Pub','update_acct_src_custom_status');
      -- store SQL error message on message stack for caller
      Fnd_Msg_Pub.Count_and_get(p_encoded => Okc_Api.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

  END   update_acct_src_custom_status;


END Okl_acct_sources_Pub;

/
