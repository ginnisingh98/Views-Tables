--------------------------------------------------------
--  DDL for Package Body OKL_TRANS_ACCT_OPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRANS_ACCT_OPT_PVT" AS
/* $Header: OKLRTACB.pls 120.2 2006/07/11 10:03:37 dkagrawa noship $ */



PROCEDURE GET_TRX_ACCT_OPT(p_api_version      IN     NUMBER,
                           p_init_msg_list    IN     VARCHAR2,
                           x_return_status    OUT    NOCOPY VARCHAR2,
                           x_msg_count        OUT    NOCOPY NUMBER,
                           x_msg_data         OUT    NOCOPY VARCHAR2,
                           p_taov_rec         IN     taov_rec_type,
                           x_taov_rec         OUT    NOCOPY taov_rec_type)
IS

  l_api_name          CONSTANT VARCHAR2(40) := 'GET_TRX_ACCT_OPT';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_row_count         NUMBER;
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_taov_rec          taov_rec_type;
  l_org_id            NUMBER;
  l_stmt              VARCHAR2(3000);
  TYPE ref_cursor     IS REF CURSOR;
  trx_acct_csr        ref_cursor;


BEGIN

  x_return_status := OKL_API.G_RET_STS_SUCCESS;


  l_return_status := OKL_API.START_ACTIVITY( l_api_name
                                            ,g_pkg_name
                                            ,p_init_msg_list
                                            ,l_api_version
                                            ,p_api_version
                                            ,'_PVT'
                                            ,l_return_status);


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    l_stmt := 'SELECT
                 ID
                ,TRY_ID
                ,REV_CCID
                ,FREIGHT_CCID
                ,REC_CCID
                ,CLEARING_CCID
                ,TAX_CCID
                ,UNBILLED_CCID
                ,UNEARNED_CCID
                ,OBJECT_VERSION_NUMBER
                ,ORG_ID
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATE_LOGIN
                ,POST_TO_GL_YN
               FROM OKL_TRX_ACCT_OPTS WHERE try_id = ' || p_taov_rec.try_id;

    OPEN trx_acct_csr FOR l_stmt;

    FETCH trx_acct_csr INTO
              l_taov_rec.ID
             ,l_taov_rec.TRY_ID
             ,l_taov_rec.REV_CCID
             ,l_taov_rec.FREIGHT_CCID
             ,l_taov_rec.REC_CCID
             ,l_taov_rec.CLEARING_CCID
             ,l_taov_rec.TAX_CCID
             ,l_taov_rec.UNBILLED_CCID
             ,l_taov_rec.UNEARNED_CCID
             ,l_taov_rec.OBJECT_VERSION_NUMBER
             ,l_taov_rec.ORG_ID
             ,l_taov_rec.ATTRIBUTE_CATEGORY
             ,l_taov_rec.ATTRIBUTE1
             ,l_taov_rec.ATTRIBUTE2
             ,l_taov_rec.ATTRIBUTE3
             ,l_taov_rec.ATTRIBUTE4
             ,l_taov_rec.ATTRIBUTE5
             ,l_taov_rec.ATTRIBUTE6
             ,l_taov_rec.ATTRIBUTE7
             ,l_taov_rec.ATTRIBUTE8
             ,l_taov_rec.ATTRIBUTE9
             ,l_taov_rec.ATTRIBUTE10
             ,l_taov_rec.ATTRIBUTE11
             ,l_taov_rec.ATTRIBUTE12
             ,l_taov_rec.ATTRIBUTE13
             ,l_taov_rec.ATTRIBUTE14
             ,l_taov_rec.ATTRIBUTE15
             ,l_taov_rec.CREATED_BY
             ,l_taov_rec.CREATION_DATE
             ,l_taov_rec.LAST_UPDATED_BY
             ,l_taov_rec.LAST_UPDATE_DATE
             ,l_taov_rec.LAST_UPDATE_LOGIN
             ,l_taov_rec.POST_TO_GL_YN;


    CLOSE trx_acct_csr;

    x_taov_rec := l_taov_rec;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);


    EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                    ,g_pkg_name
                                    ,'OKL_API.G_RET_STS_ERROR'
                                    ,x_msg_count
                                    ,x_msg_data
                                    ,'_PVT'
                                                                    );

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT'
                                 );

    WHEN OTHERS THEN

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OTHERS'
                                  ,x_msg_count
                                    ,x_msg_data
                                 ,'_PVT'
                                     );

END GET_TRX_ACCT_OPT;





PROCEDURE UPDT_TRX_ACCT_OPT(p_api_version     IN         NUMBER,
                            p_init_msg_list   IN         VARCHAR2,
                            x_return_status   OUT        NOCOPY VARCHAR2,
                            x_msg_count       OUT        NOCOPY NUMBER,
                            x_msg_data        OUT        NOCOPY VARCHAR2,
                            p_taov_rec        IN         taov_rec_type,
                            x_taov_rec        OUT        NOCOPY taov_rec_type)
IS

  l_api_name          CONSTANT VARCHAR2(40) := 'UPDT_TRX_ACCT_OPT';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_row_count         NUMBER;
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_init_msg_list     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

  l_taov_rec_in       taov_rec_type;
  l_taov_rec_out      taov_rec_type;




 BEGIN


    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_taov_rec_in   := p_taov_rec;


    GET_TRX_ACCT_OPT(p_api_version        => 1.0,
                     p_init_msg_list      => l_init_msg_list,
                     x_return_status      => l_return_status,
                     x_msg_count          => l_msg_count,
                     x_msg_data           => l_msg_data,
                     p_taov_rec           => l_taov_rec_in,
                     x_taov_rec           => l_taov_rec_out);


    IF (l_taov_rec_out.ID = OKL_API.G_MISS_NUM) OR
       (l_taov_rec_out.ID IS NULL) THEN


        OKL_TRX_ACCT_OPTS_PUB.INSERT_TRX_ACCT_OPTS(p_api_version    => 1.0,
                                                   p_init_msg_list  => l_init_msg_list,
                                                   x_return_status  => l_return_status,
                                                   x_msg_count      => l_msg_count,
                                                   x_msg_data       => l_msg_data,
                                                   p_taov_rec       => l_taov_rec_in,
                                                   x_taov_rec       => l_taov_rec_out);


    ELSE

       IF (p_taov_rec.id = OKL_API.G_MISS_NUM) OR
          (p_taov_rec.id IS NULL) THEN
           l_taov_rec_in.id := l_taov_rec_out.id;
       END IF;

       OKL_TRX_ACCT_OPTS_PUB.UPDATE_TRX_ACCT_OPTS(p_api_version    => 1.0,
                                                  p_init_msg_list  => l_init_msg_list,
                                                  x_return_status  => l_return_status,
                                                  x_msg_count      => l_msg_count,
                                                  x_msg_data       => l_msg_data,
                                                  p_taov_rec       => l_taov_rec_in,
                                                  x_taov_rec       => l_taov_rec_out);



    END IF;

    x_msg_count                := l_msg_count;
    x_msg_data                 := l_msg_data;
    x_return_status            := l_return_status;
	x_taov_rec                 := l_taov_rec_out;



END UPDT_TRX_ACCT_OPT;


END OKL_TRANS_ACCT_OPT_PVT;


/
