--------------------------------------------------------
--  DDL for Package OKE_K_PRINT_FORMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_K_PRINT_FORMS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKEPKPFS.pls 115.3 2002/08/14 01:44:51 alaw ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(200) := 'OKE_K_PRINT_FORMS_PUB';
G_APP_NAME     CONSTANT VARCHAR2(200) := OKE_API.G_APP_NAME;


  PROCEDURE create_print_form(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_form_rec			   IN  oke_form_pvt.form_rec_type,
    x_form_rec			   OUT NOCOPY  oke_form_pvt.form_rec_type);

  PROCEDURE create_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_form_tbl			   IN  oke_form_pvt.form_tbl_type,
    x_form_tbl			   OUT NOCOPY oke_form_pvt.form_tbl_type);


  PROCEDURE update_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_rec			   IN oke_form_pvt.form_rec_type,
    x_form_rec			   OUT NOCOPY oke_form_pvt.form_rec_type);


  PROCEDURE update_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_tbl			   IN oke_form_pvt.form_tbl_type,
    x_form_tbl			   OUT NOCOPY oke_form_pvt.form_tbl_type);


  PROCEDURE delete_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_rec			   IN oke_form_pvt.form_rec_type);


  PROCEDURE delete_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_tbl			   IN oke_form_pvt.form_tbl_type);


/* to delete a line's print form specify cle and pfm.
   to delete a header's print form specify chr and pfm.
   the other is left as NULL
*/

  PROCEDURE delete_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id		IN NUMBER,
    p_cle_id		IN NUMBER,
    p_pfm_cd		IN OKE_K_PRINT_FORMS.PRINT_FORM_CODE%TYPE);


  PROCEDURE validate_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_rec			   IN oke_form_pvt.form_rec_type);

  PROCEDURE validate_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_tbl			   IN oke_form_pvt.form_tbl_type);


/* Specify level as being either 'H' for Header or 'L' for Lines
   To copy from a Header, provide p_from_chr_id
   To copy from a Line, provide p_from_cle_id
   To copy to another Line in same header, provide p_to_cle_id
   To copy to another Line in another header, provide both
 	p_to_cle_id and p_to_chr_id
   To copy to another Header, provide p_to_chr_id
   Unmentioned fields must be NULL

   Copies ALL print forms with different PRINT_FORM_CODE.
*/
  PROCEDURE copy_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_level		IN VARCHAR2,
    p_to_level			IN VARCHAR2,
    p_from_chr_id		IN NUMBER,
    p_to_chr_id			IN NUMBER,
    p_from_cle_id		IN NUMBER,
    p_to_cle_id			IN NUMBER
);


  PROCEDURE lock_print_form(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_form_rec           IN OKE_FORM_PVT.form_rec_type);

  PROCEDURE lock_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_tbl                     IN oke_form_pvt.form_tbl_type);

END OKE_K_PRINT_FORMS_PUB;


 

/
