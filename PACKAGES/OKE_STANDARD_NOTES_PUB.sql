--------------------------------------------------------
--  DDL for Package OKE_STANDARD_NOTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_STANDARD_NOTES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKEPNOTS.pls 115.6 2002/08/14 01:42:27 alaw ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(200) := 'OKE_STANDARD_NOTES_PUB';
G_APP_NAME     CONSTANT VARCHAR2(200) := OKE_API.G_APP_NAME;

SUBTYPE note_rec_type IS oke_note_pvt.note_rec_type;

  PROCEDURE create_standard_note(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_note_rec			   IN  oke_note_pvt.note_rec_type,
    x_note_rec			   OUT NOCOPY  oke_note_pvt.note_rec_type);

  PROCEDURE create_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_note_tbl			   IN  oke_note_pvt.note_tbl_type,
    x_note_tbl			   OUT NOCOPY oke_note_pvt.note_tbl_type);


  PROCEDURE update_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_rec			   IN oke_note_pvt.note_rec_type,
    x_note_rec			   OUT NOCOPY oke_note_pvt.note_rec_type);


  PROCEDURE update_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_tbl			   IN oke_note_pvt.note_tbl_type,
    x_note_tbl			   OUT NOCOPY oke_note_pvt.note_tbl_type);


  PROCEDURE delete_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_rec			   IN oke_note_pvt.note_rec_type);


  PROCEDURE delete_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_tbl			   IN oke_note_pvt.note_tbl_type);


 /* this one below takes in standard_note_id straight */

  PROCEDURE delete_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_id			   IN NUMBER);


/* this one takes one of these three, k_header_id,k_line_id,deliverable_id
   the other two Must be left NULL */

  PROCEDURE delete_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hdr_id		IN NUMBER,
    p_cle_id		IN NUMBER,
    p_del_id		IN NUMBER);


  PROCEDURE validate_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_rec			   IN oke_note_pvt.note_rec_type);

  PROCEDURE validate_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_tbl			   IN oke_note_pvt.note_tbl_type);


/*
    	10/11/2000
  I have modified this procedure to allow for more flexible copy.
  The old way of calling this procedure is still compatible.
  The new way of using this procedure is as follows:

    You still specify only one 'from' value.
    either p_from_hdr_id, p_from_cle_id or p_from_del_id.
    This is where the standard_note(s) will be sourced. For example,
    if you specify a p_from_hdr_id, the procedure will grab all
    the standard_notes belonging to that header
    (but NOT its children).

    However, now you can specify one or more 'to' values.
    If you do not specify a particular 'to' value ( p_to_hdr_id,
    p_to_cle_id or p_to_del_id ), then the k_header_id,k_line_id,
    deliverable_id will be copied along from the old standard_note
    record into the new standard_note record respectively.

    Note: if you do not specify any of the 3 'to' values, you would
    have basically copied the standard_notes from the origin back
    into the origin, creating a duplicate!

   ---!!ATTENTION!! below is the old comment ---------
   same for copy, only one pair may be not null. the other
   two pairs Must be NULL.
   No cross-copying allowed. eg. copying from header12's Line to
   header27's Line.
*/

  PROCEDURE copy_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_hdr_id		IN NUMBER,
    p_to_hdr_id			IN NUMBER,
    p_from_cle_id		IN NUMBER,
    p_to_cle_id			IN NUMBER,
    p_from_del_id		IN NUMBER,
    p_to_del_id			IN NUMBER,
    default_flag		IN VARCHAR2
);


  PROCEDURE lock_standard_note(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_note_rec           IN OKE_NOTE_PVT.note_rec_type);

  PROCEDURE lock_standard_note(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_tbl                     IN oke_note_pvt.note_tbl_type);

END OKE_STANDARD_NOTES_PUB;


 

/
