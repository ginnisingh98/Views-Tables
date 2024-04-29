--------------------------------------------------------
--  DDL for Package OKL_PROCESS_TMPT_SET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROCESS_TMPT_SET_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTMSS.pls 115.6 2002/05/03 14:13:55 pkm ship       $ */
  SUBTYPE aesv_rec_type IS OKL_PROCESS_TMPT_SET_PVT.aesv_rec_type;
  SUBTYPE aesv_tbl_type IS OKL_PROCESS_TMPT_SET_PVT.aesv_tbl_type;
  SUBTYPE avlv_rec_type IS OKL_PROCESS_TMPT_SET_PVT.avlv_rec_type;
  SUBTYPE avlv_tbl_type IS OKL_PROCESS_TMPT_SET_PVT.avlv_tbl_type;
  SUBTYPE atlv_rec_type IS OKL_PROCESS_TMPT_SET_PVT.atlv_rec_type;
  SUBTYPE atlv_tbl_type IS OKL_PROCESS_TMPT_SET_PVT.atlv_tbl_type;
  PROCEDURE create_tmpt_set(p_api_version                  IN  NUMBER
                           ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                           ,x_return_status                OUT NOCOPY VARCHAR2
                           ,x_msg_count                    OUT NOCOPY NUMBER
                           ,x_msg_data                     OUT NOCOPY VARCHAR2
                           ,p_aesv_rec                     IN  aesv_rec_type
                           ,p_avlv_tbl                     IN  avlv_tbl_type
                           ,p_atlv_tbl			           IN  atlv_tbl_type
                           ,x_aesv_rec                     OUT NOCOPY aesv_rec_type
                           ,x_avlv_tbl                     OUT NOCOPY avlv_tbl_type
                           ,x_atlv_tbl				  	   OUT NOCOPY atlv_tbl_type);
  --Object type procedure for update
  PROCEDURE update_tmpt_set(p_api_version                  IN  NUMBER
                           ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                           ,x_return_status                OUT NOCOPY VARCHAR2
                           ,x_msg_count                    OUT NOCOPY NUMBER
                           ,x_msg_data                     OUT NOCOPY VARCHAR2
                           ,p_aesv_rec                     IN  aesv_rec_type
                           ,p_avlv_tbl                     IN  avlv_tbl_type
                           ,p_atlv_tbl			           IN  atlv_tbl_type
                           ,x_aesv_rec                     OUT NOCOPY aesv_rec_type
                           ,x_avlv_tbl                     OUT NOCOPY avlv_tbl_type
                           ,x_atlv_tbl					   OUT NOCOPY atlv_tbl_type );
 PROCEDURE create_tmpt_set(p_api_version                  IN  NUMBER,
                           p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                           x_return_status                OUT NOCOPY VARCHAR2,
                           x_msg_count                    OUT NOCOPY NUMBER,
                           x_msg_data                     OUT NOCOPY VARCHAR2,
                           p_aesv_tbl                     IN  aesv_tbl_type,
                           x_aesv_tbl                     OUT NOCOPY aesv_tbl_type);
  PROCEDURE create_tmpt_set(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_aesv_rec                     IN  aesv_rec_type,
                            x_aesv_rec                     OUT NOCOPY aesv_rec_type,
			    p_aes_source_id		   IN OKL_AE_TMPT_SETS.id%TYPE DEFAULT NULL);
  PROCEDURE update_tmpt_set(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_aesv_tbl                     IN  aesv_tbl_type,
                            x_aesv_tbl                     OUT NOCOPY aesv_tbl_type);
  PROCEDURE update_tmpt_set(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                     OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_aesv_rec                     IN  aesv_rec_type,
                            x_aesv_rec                     OUT NOCOPY aesv_rec_type);
  PROCEDURE delete_tmpt_set(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_aesv_tbl                     IN  aesv_tbl_type);
  PROCEDURE delete_tmpt_set(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_aesv_rec                     IN aesv_rec_type);
 PROCEDURE create_template(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_avlv_tbl                     IN  avlv_tbl_type,
     x_avlv_tbl                     OUT NOCOPY avlv_tbl_type);
 PROCEDURE create_template(p_api_version                  IN  NUMBER,
                           p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                           x_return_status                OUT NOCOPY VARCHAR2,
                           x_msg_count                    OUT NOCOPY NUMBER,
                           x_msg_data                     OUT NOCOPY VARCHAR2,
                           p_avlv_rec                     IN  avlv_rec_type,
                           x_avlv_rec                     OUT NOCOPY avlv_rec_type);
PROCEDURE update_template(p_api_version                  IN  NUMBER,
                          p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status                OUT NOCOPY VARCHAR2,
                          x_msg_count                    OUT NOCOPY NUMBER,
                          x_msg_data                     OUT NOCOPY VARCHAR2,
                          p_avlv_tbl                     IN  avlv_tbl_type,
                          x_avlv_tbl                     OUT NOCOPY avlv_tbl_type);
PROCEDURE update_template(p_api_version                  IN  NUMBER,
                          p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status                OUT NOCOPY VARCHAR2,
                          x_msg_count                    OUT NOCOPY NUMBER,
                          x_msg_data                     OUT NOCOPY VARCHAR2,
                          p_avlv_rec                     IN  avlv_rec_type,
                          x_avlv_rec                     OUT NOCOPY avlv_rec_type);
  PROCEDURE delete_template(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_avlv_tbl                     IN  avlv_tbl_type);
  PROCEDURE delete_template(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_avlv_rec                     IN  avlv_rec_type);
PROCEDURE create_tmpt_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_atlv_tbl                     IN  atlv_tbl_type,
     x_atlv_tbl                     OUT NOCOPY atlv_tbl_type);
  PROCEDURE create_tmpt_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_atlv_rec                     IN  atlv_rec_type,
     x_atlv_rec                     OUT NOCOPY atlv_rec_type);
  PROCEDURE update_tmpt_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_atlv_tbl                     IN  atlv_tbl_type,
     x_atlv_tbl                     OUT NOCOPY atlv_tbl_type);
  PROCEDURE update_tmpt_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_atlv_rec                     IN  atlv_rec_type,
     x_atlv_rec                     OUT NOCOPY atlv_rec_type);
  PROCEDURE delete_tmpt_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_atlv_tbl                     IN  atlv_tbl_type);
  PROCEDURE delete_tmpt_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_atlv_rec                     IN  atlv_rec_type);
-- mvasudev -- 02/13/2002
/* This API Takes 'From Template Set ID'  and 'To Template Set ID'
   as parameters and copies all the templates and Template Line
   from 'From Template Set ID' to 'To Template Set ID'. The Template
   names in the copied templates is suffixed with '-COPY' so as not
   to violate the unique constraint.                                  */
PROCEDURE COPY_TMPL_SET(p_api_version                IN         NUMBER,
                        p_init_msg_list              IN         VARCHAR2,
                        x_return_status              OUT        NOCOPY VARCHAR2,
                        x_msg_count                  OUT        NOCOPY NUMBER,
                        x_msg_data                   OUT        NOCOPY VARCHAR2,
		        p_aes_id_from                IN         NUMBER,
		        p_aes_id_to                  IN         NUMBER);
/* This API is used for Copying a Single Template Lines from one template
   to another. It first creates the template record for the given p_avlv_rec
   and then copies the template line records from source template lines to
   the target template lines.                                             */
PROCEDURE COPY_TEMPLATE(p_api_version                IN         NUMBER,
                        p_init_msg_list              IN         VARCHAR2,
                        x_return_status              OUT        NOCOPY VARCHAR2,
                        x_msg_count                  OUT        NOCOPY NUMBER,
                        x_msg_data                   OUT        NOCOPY VARCHAR2,
                        p_avlv_rec                   IN         avlv_rec_type,
                        p_source_tmpl_id             IN         NUMBER,
                        x_avlv_rec                   OUT        NOCOPY avlv_rec_type);
-- end,mvasudev -- 02/13/2002
G_PKG_NAME CONSTANT VARCHAR2(200)      := 'OKL_PROCESS_TMPT_SET_PUB';
G_APP_NAME CONSTANT VARCHAR2(3)        :=  OKC_API.G_APP_NAME;
END OKL_PROCESS_TMPT_SET_PUB;

 

/
