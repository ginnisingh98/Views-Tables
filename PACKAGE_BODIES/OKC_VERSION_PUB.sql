--------------------------------------------------------
--  DDL for Package Body OKC_VERSION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_VERSION_PUB" as
/* $Header: OKCPVERB.pls 120.0 2005/05/26 09:32:37 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


PROCEDURE version_contract(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
     p_cvmv_rec          IN cvmv_rec_type,
	p_commit     	     IN VARCHAR2 ,
     x_cvmv_rec          OUT NOCOPY cvmv_rec_type) IS

 BEGIN
      OKC_VERSION_PVT.version_contract(
                     p_api_version         => p_api_version,
                     p_init_msg_list       => p_init_msg_list,
                     x_return_status       => x_return_status,
                     x_msg_count           => x_msg_count,
                     x_msg_data            => x_msg_data,
                     p_cvmv_rec            => p_cvmv_rec,
				 p_commit     	        => p_commit,
                     x_cvmv_rec            => x_cvmv_rec);

END Version_Contract;

PROCEDURE version_contract(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
     p_cvmv_tbl          IN cvmv_tbl_type,
	p_commit     	     IN VARCHAR2 ,
     x_cvmv_tbl          OUT NOCOPY cvmv_tbl_type) IS
     i			    NUMBER := 0;
     l_return_status    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_cvmv_tbl.COUNT > 0 THEN
       i := p_cvmv_tbl.FIRST;
       LOOP
       		version_contract(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_cvmv_rec            => p_cvmv_tbl(i),
				     p_commit     	       => p_commit,
                         x_cvmv_rec            => x_cvmv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_cvmv_tbl.LAST);
       		i := p_cvmv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END Version_Contract;

PROCEDURE save_version(
    p_chr_id 				IN NUMBER,
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 ,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    p_commit     	     	IN VARCHAR2 ,
    x_msg_data                OUT NOCOPY VARCHAR2) is
begin
	okc_version_pvt.save_version(
	    p_chr_id 		=> p_chr_id,
	    p_api_version 	=> p_api_version,
	    p_init_msg_list => p_init_msg_list,
	    x_return_status => x_return_status,
	    x_msg_count 	=> x_msg_count,
	    p_commit        => p_commit,
	    x_msg_data 	=> x_msg_data);
end;

PROCEDURE erase_saved_version(
    p_chr_id 				IN NUMBER,
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 ,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    p_commit     	     	IN VARCHAR2 ,
    x_msg_data                OUT NOCOPY VARCHAR2) is
begin
	okc_version_pvt.erase_saved_version(
	    p_chr_id 		=> p_chr_id,
	    p_api_version 	=> p_api_version,
	    p_init_msg_list => p_init_msg_list,
	    x_return_status => x_return_status,
	    x_msg_count 	=> x_msg_count,
	    p_commit     	=> p_commit,
	    x_msg_data 	=> x_msg_data);
end;

PROCEDURE restore_version(
    p_chr_id 				IN NUMBER,
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 ,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    p_commit     	          IN VARCHAR2 ,
    x_msg_data                OUT NOCOPY VARCHAR2) is
begin
	okc_version_pvt.restore_version(
	    p_chr_id 		=> p_chr_id,
	    p_api_version 	=> p_api_version,
	    p_init_msg_list => p_init_msg_list,
	    x_return_status => x_return_status,
	    x_msg_count 	=> x_msg_count,
	    p_commit        => p_commit,
	    x_msg_data 	=> x_msg_data);
end;


END okc_version_pub;

/
