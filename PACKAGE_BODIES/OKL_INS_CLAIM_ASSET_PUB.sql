--------------------------------------------------------
--  DDL for Package Body OKL_INS_CLAIM_ASSET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INS_CLAIM_ASSET_PUB" AS
/* $Header: OKLPCLAB.pls 115.7 2004/04/13 10:37:49 rnaik noship $ */

   PROCEDURE   create_lease_claim(
            p_api_version                   IN NUMBER,
   	    p_init_msg_list                IN VARCHAR2 ,
            x_return_status                OUT NOCOPY VARCHAR2,
            x_msg_count                    OUT NOCOPY NUMBER,
            x_msg_data                     OUT NOCOPY VARCHAR2,
            px_clmv_tbl                    IN OUT NOCOPY clmv_tbl_type,
            px_acdv_tbl			IN OUT NOCOPY acdv_tbl_type,
            px_acnv_tbl			IN OUT NOCOPY acnv_tbl_type
     ) IS
     l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
     l_msg_count              NUMBER;
     l_msg_data               VARCHAR2(2000);
     l_api_version 		NUMBER ;
     l_init_msg_list 	      VARCHAR2(1) ;
     l_clmv_tbl		      CLMV_TBL_TYPE;
     l_acdv_tbl		      acdv_tbl_type;
     l_acnv_tbl		      acnv_tbl_type;
     BEGIN

     l_return_status := x_return_status;
     l_msg_count     :=          x_msg_count;
     l_msg_data      := x_msg_data;
     l_api_version   := p_api_version ;
     l_init_msg_list  :=  p_init_msg_list ;
     l_clmv_tbl	     :=  px_clmv_tbl;
     l_acdv_tbl	     := px_acdv_tbl;
     l_acnv_tbl	     := px_acnv_tbl;

         --SAVEPOINT create_fulfillment;
       ------------ Call to Private Process API--------------
          OKL_INS_CLAIM_ASSET_pvt.create_lease_claim(
           					   p_api_version	=> l_api_version,
                                                   p_init_msg_list  =>   l_init_msg_list,
                                                   x_return_status     => l_return_status,
                                                   x_msg_count  => l_msg_count,
                                                   x_msg_data  =>  l_msg_data,
                                                   px_clmv_tbl  => l_clmv_tbl,
                                                   px_acdv_tbl	=> l_acdv_tbl,
                                                   px_acnv_tbl  => l_acnv_tbl
                                                  );
         IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           x_return_status := l_return_status;
           --return(l_return_status);
           RAISE OKL_API.G_EXCEPTION_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           --return(l_return_status);
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;
       ------------ End Call to Private Process API--------------

       px_clmv_tbl	     :=  l_clmv_tbl;
       px_acdv_tbl	     := l_acdv_tbl;
       px_acnv_tbl	     := l_acnv_tbl;
       x_return_status := l_return_status;

       --return(l_return_status);
       EXCEPTION
         WHEN OKL_API.G_EXCEPTION_ERROR THEN
           --ROLLBACK TO create_fulfillment;
           l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
           FND_MSG_PUB.count_and_get(p_count   => l_msg_count,
                                      p_data    => l_msg_data);
         WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
           --ROLLBACK TO create_fulfillment;
           l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
           FND_MSG_PUB.count_and_get(p_count   => l_msg_count,
                                      p_data    => l_msg_data);
         WHEN OTHERS THEN
           --ROLLBACK TO create_fulfillment;
           l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
           FND_MSG_PUB.ADD_EXC_MSG('OKL_INS_CLAIM_ASSET_PUB','create_lease_claim');
           FND_MSG_PUB.count_and_get(p_count   => l_msg_count,
                                      p_data    => l_msg_data);
    x_return_status:=l_return_status;
     END create_lease_claim;

PROCEDURE hold_streams(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsm_id                       IN stmid_rec_type_tbl_type
)IS
l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
     l_msg_count              NUMBER;
     l_msg_data               VARCHAR2(2000);
     l_api_version 		NUMBER ;
     l_init_msg_list 	      VARCHAR2(1) ;
     l_lsm_id		      stmid_rec_type_tbl_type;
     BEGIN
     -- Fix for Bug 2511187 LockOut Fees
     l_lsm_id :=p_lsm_id ;
     l_return_status := X_return_status ;
     l_msg_count  := X_msg_count;
     l_api_version := P_api_version ;
     l_init_msg_list := p_init_msg_list ;

         --SAVEPOINT create_fulfillment;
       ------------ Call to Private Process API--------------
          OKL_INS_CLAIM_ASSET_pvt.hold_streams(
           					   p_api_version	=> l_api_version,
                                                   p_init_msg_list  =>   l_init_msg_list,
                                                   x_return_status     => l_return_status,
                                                   x_msg_count  => l_msg_count,
                                                   x_msg_data  =>  l_msg_data,
                                                   p_lsm_id  => l_lsm_id
                                                  );
         IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           x_return_status := l_return_status;
           --return(l_return_status);
           RAISE OKL_API.G_EXCEPTION_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           --return(l_return_status);
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;
       ------------ End Call to Private Process API--------------
       x_return_status := l_return_status;
       --return(l_return_status);
       EXCEPTION
         WHEN OKL_API.G_EXCEPTION_ERROR THEN
           --ROLLBACK TO create_fulfillment;
           l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
           FND_MSG_PUB.count_and_get(p_count   => l_msg_count,
                                      p_data    => l_msg_data);
         WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
           --ROLLBACK TO create_fulfillment;
           l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
           FND_MSG_PUB.count_and_get(p_count   => l_msg_count,
                                      p_data    => l_msg_data);
         WHEN OTHERS THEN
           --ROLLBACK TO create_fulfillment;
           l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
           FND_MSG_PUB.ADD_EXC_MSG('OKL_INS_CLAIM_ASSET_PUB','hold_streams');
           FND_MSG_PUB.count_and_get(p_count   => l_msg_count,
                                      p_data    => l_msg_data);
    x_return_status := l_return_status;

END hold_streams;

END OKL_INS_CLAIM_ASSET_PUB;

/
