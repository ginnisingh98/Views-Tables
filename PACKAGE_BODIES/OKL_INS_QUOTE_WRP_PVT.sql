--------------------------------------------------------
--  DDL for Package Body OKL_INS_QUOTE_WRP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INS_QUOTE_WRP_PVT" AS
/* $Header: OKLRQMNB.pls 115.4 2003/02/20 04:10:47 smoduga noship $ */
--------------------------------------------------------
--NOTE: This procedure is a wrapper over OKL_INS_QUOTE_PVT
--This procedure accepts the parameter as table type and in turn
--calls the procedure that accepts the record type API in loop.
--For all practical purposes, only one record will be passed in
-- the pl/sql table and so the record api is called only once.
--------------------------------------------------------
 PROCEDURE   calc_lease_premium(
          	p_api_version                  IN NUMBER,
 	  	p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
          	x_return_status                OUT NOCOPY VARCHAR2,
          	x_msg_count                    OUT NOCOPY NUMBER,
          	x_msg_data                     OUT NOCOPY VARCHAR2,
          	px_ipyv_tbl                    IN OUT NOCOPY ipyv_tbl_type,
 	  	x_message                      OUT NOCOPY VARCHAR2,
          	x_iasset_tbl                   OUT NOCOPY  iasset_tbl_type
     		) AS
     l_api_version 		NUMBER ;
     l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     i                          NUMBER := 0;
     l_overall_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_api_version := p_api_version ;
    OKC_API.init_msg_list(p_init_msg_list);
    --IF (px_ipyv_tbl.COUNT > 0) THEN
      i := px_ipyv_tbl.FIRST;
     --LOOP
      okl_ins_quote_pub.calc_lease_premium(
         p_api_version                  => l_api_version,
	 p_init_msg_list                => Okc_Api.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         px_ipyv_rec                    => px_ipyv_tbl(i),
         x_message                      => x_message,
         x_iasset_tbl                   => x_iasset_tbl
         );
        IF l_return_status = Okc_Api.G_RET_STS_ERROR THEN
              x_return_status := l_return_status;
          END IF;
        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
             x_return_status := l_return_status;
        END IF;
        --EXIT WHEN (i = px_ipyv_tbl.LAST);
        --i := px_ipyv_tbl.NEXT(i);
      --END LOOP;
      --x_return_status := l_overall_status;
   -- END IF;
  END calc_lease_premium;
  PROCEDURE   calc_optional_premium(
         p_api_version                   IN NUMBER,
	 p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ipyv_tbl                     IN  ipyv_tbl_type,
	 x_message                      OUT NOCOPY VARCHAR2,
         x_ipyv_tbl                     OUT NOCOPY ipyv_tbl_type
     )AS
      l_api_version 		NUMBER ;
      l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      i                          NUMBER := 0;
      l_overall_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      l_api_version := p_api_version ;
      OKC_API.init_msg_list(p_init_msg_list);
      --IF (p_ipyv_tbl.COUNT > 0) THEN
        i := p_ipyv_tbl.FIRST;
       --LOOP
        okl_ins_quote_pub.calc_optional_premium(
           p_api_version                  => l_api_version,
  	       p_init_msg_list                => Okc_Api.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_ipyv_rec                     => p_ipyv_tbl(i),
           x_message                      => x_message,
           x_ipyv_rec                     => x_ipyv_tbl(i)
           );
          IF l_return_status = Okc_Api.G_RET_STS_ERROR THEN
              x_return_status := l_return_status;
          END IF;
          IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
             x_return_status := l_return_status;
          END IF;

          --EXIT WHEN (i = p_ipyv_tbl.LAST);
          --i := p_ipyv_tbl.NEXT(i);
        --END LOOP;
        --x_return_status := l_overall_status;
      --END IF;
  END calc_optional_premium;

  PROCEDURE   save_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     px_ipyv_tbl                    IN OUT NOCOPY ipyv_tbl_type,
	 x_message                      OUT NOCOPY  VARCHAR2  )AS
      l_api_version 		NUMBER ;
      l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      i                          NUMBER := 0;
      l_overall_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      l_api_version := p_api_version ;
      OKC_API.init_msg_list(p_init_msg_list);
      --IF (px_ipyv_tbl.COUNT > 0) THEN
        i := px_ipyv_tbl.FIRST;
       --LOOP
        okl_ins_quote_pub.save_quote(
           p_api_version                  => l_api_version,
  	       p_init_msg_list                => Okc_Api.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           px_ipyv_rec                    => px_ipyv_tbl(i),
           x_message                      => x_message
           );
          IF l_return_status = Okc_Api.G_RET_STS_ERROR THEN
              x_return_status := l_return_status;
          END IF;
          IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
             x_return_status := l_return_status;
          END IF;
          --EXIT WHEN (i = px_ipyv_tbl.LAST);
         -- i := px_ipyv_tbl.NEXT(i);
        --END LOOP;
       -- x_return_status := l_overall_status;
      --END IF;
  END save_quote;

  PROCEDURE   save_accept_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_tbl                    IN ipyv_tbl_type,
	 x_message                      OUT NOCOPY  VARCHAR2  )AS
      l_api_version 		NUMBER ;
      l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      i                          NUMBER := 0;
      l_overall_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      l_api_version := p_api_version ;
      OKC_API.init_msg_list(p_init_msg_list);
      --IF (px_ipyv_tbl.COUNT > 0) THEN
        i := p_ipyv_tbl.FIRST;
       --LOOP
        okl_ins_quote_pub.save_accept_quote(
           p_api_version                  => l_api_version,
  	       p_init_msg_list                => Okc_Api.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_ipyv_rec                    => p_ipyv_tbl(i),
           x_message                      => x_message
           );
          IF l_return_status = Okc_Api.G_RET_STS_ERROR THEN
              x_return_status := l_return_status;
          END IF;
          IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
             x_return_status := l_return_status;
          END IF;
          --EXIT WHEN (i = px_ipyv_tbl.LAST);
         -- i := px_ipyv_tbl.NEXT(i);
        --END LOOP;
       -- x_return_status := l_overall_status;
      --END IF;
  END save_accept_quote;

  PROCEDURE   create_third_prt_ins(
         p_api_version                   IN NUMBER,
	 p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ipyv_tbl                     IN  ipyv_tbl_type,
	     x_ipyv_tbl                     OUT NOCOPY ipyv_tbl_type
     )AS
      l_api_version 		NUMBER ;
      l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      i                          NUMBER := 0;
      l_overall_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      l_api_version := p_api_version ;
      OKC_API.init_msg_list(p_init_msg_list);
      --IF (p_ipyv_tbl.COUNT > 0) THEN
        i := p_ipyv_tbl.FIRST;
       --LOOP
        okl_ins_quote_pub.create_third_prt_ins(
           p_api_version                  => l_api_version,
  	       p_init_msg_list                => Okc_Api.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_ipyv_rec                     => p_ipyv_tbl(i),
           x_ipyv_rec                     => x_ipyv_tbl(i)
           );
          IF l_return_status = Okc_Api.G_RET_STS_ERROR THEN
              x_return_status := l_return_status;
          END IF;
          IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
             x_return_status := l_return_status;
          END IF;

          --EXIT WHEN (i = p_ipyv_tbl.LAST);
          --i := p_ipyv_tbl.NEXT(i);
        --END LOOP;
        --x_return_status := l_overall_status;
      --END IF;
  END create_third_prt_ins;


END OKL_INS_QUOTE_WRP_PVT;

/
