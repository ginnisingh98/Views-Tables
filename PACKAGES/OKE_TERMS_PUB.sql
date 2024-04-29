--------------------------------------------------------
--  DDL for Package OKE_TERMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_TERMS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKEPTRMS.pls 115.4 2002/08/14 01:42:39 alaw ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(200) := 'OKE_TERMS_PUB';
G_APP_NAME     CONSTANT VARCHAR2(200) := OKE_API.G_APP_NAME;

SUBTYPE term_rec_type IS oke_term_pvt.term_rec_type;


/* Creates a row in oke_k_terms. must provide all key values
   k_header_id,k_line_id,term_code,term_value_pk1,term_value_pk2
   except when creating for a line, where k_line_id is ommitted.
*/

  PROCEDURE create_term(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_term_rec			   IN  oke_term_pvt.term_rec_type,
    x_term_rec			   OUT NOCOPY  oke_term_pvt.term_rec_type);

  PROCEDURE create_term(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_term_tbl			   IN  oke_term_pvt.term_tbl_type,
    x_term_tbl			   OUT NOCOPY oke_term_pvt.term_tbl_type);


/* delete uses all of the 5 key attributes to delete a particular row
   use NULL for k_line_id if target belongs to a contract line.
*/

  PROCEDURE delete_term(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_rec			   IN oke_term_pvt.term_rec_type);


  PROCEDURE delete_term(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_tbl			   IN oke_term_pvt.term_tbl_type);


/* to delete a line's term specify cle and trm.
   to delete a header's term specify chr and trm.
   the other is left as NULL
*/

  PROCEDURE delete_term(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id			   IN NUMBER,
    p_cle_id			   IN NUMBER,
    p_trm_cd			   IN OKE_K_TERMS.TERM_CODE%TYPE,
    p_trm_val_pk1		   OKE_K_TERMS.TERM_VALUE_PK1%TYPE,
    p_trm_val_pk2		   OKE_K_TERMS.TERM_VALUE_PK2%TYPE
);

/*

  PROCEDURE validate_term(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_rec			   IN oke_term_pvt.term_rec_type);

  PROCEDURE validate_term(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_tbl			   IN oke_term_pvt.term_tbl_type);

*/


/* Specify level as being either 'H' for Header or 'L' for Lines
   To copy from a Header, provide p_from_chr_id
   To copy from a Line, provide p_from_cle_id
   To copy to another Line in same header, provide p_to_cle_id
   To copy to another Line in another header, provide both
 	p_to_cle_id and p_to_chr_id
   To copy to another Header, provide p_to_chr_id
   Unmentioned fields must be NULL

   Copies ALL terms belonging to that line or header
*/

  PROCEDURE copy_term(
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


/* lock uses all of the 5 key attributes to lock a particular row
   use NULL for k_line_id if target belongs to a contract line.
*/


  PROCEDURE lock_term(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_term_rec           IN OKE_TERM_PVT.term_rec_type);

  PROCEDURE lock_term(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_tbl                     IN oke_term_pvt.term_tbl_type);

END OKE_TERMS_PUB;


 

/
