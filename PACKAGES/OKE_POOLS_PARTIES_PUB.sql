--------------------------------------------------------
--  DDL for Package OKE_POOLS_PARTIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_POOLS_PARTIES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKEPPPPS.pls 115.5 2002/08/14 01:42:34 alaw ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(200) := 'OKE_POOLS_PARTIES_PUB';
G_APP_NAME     CONSTANT VARCHAR2(200) := OKE_API.G_APP_NAME;


SUBTYPE pool_rec_type IS oke_pool_pvt.pool_rec_type;
SUBTYPE party_rec_type IS OKE_party_pvt.party_rec_type;

/* create_pool - creates new funding pool.
		 returns new funding_pool_id in x_pool_rec
*/

  PROCEDURE create_pool(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_pool_rec			   IN  oke_pool_pvt.pool_rec_type,
    x_pool_rec			   OUT NOCOPY  oke_pool_pvt.pool_rec_type);

  PROCEDURE create_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_pool_tbl			   IN  oke_pool_pvt.pool_tbl_type,
    x_pool_tbl			   OUT NOCOPY oke_pool_pvt.pool_tbl_type);



/* updating currency code is not allowed */

  PROCEDURE update_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_rec			   IN oke_pool_pvt.pool_rec_type,
    x_pool_rec			   OUT NOCOPY oke_pool_pvt.pool_rec_type);


  PROCEDURE update_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_tbl			   IN oke_pool_pvt.pool_tbl_type,
    x_pool_tbl			   OUT NOCOPY oke_pool_pvt.pool_tbl_type);


     -- cascading deletes

  PROCEDURE delete_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_rec			   IN oke_pool_pvt.pool_rec_type);


  PROCEDURE delete_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_tbl			   IN oke_pool_pvt.pool_tbl_type);

  PROCEDURE delete_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_funding_pool_id		   IN NUMBER);


  PROCEDURE lock_pool(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_pool_rec           IN OKE_POOL_PVT.pool_rec_type);

  PROCEDURE lock_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_tbl                     IN oke_pool_pvt.pool_tbl_type);



  PROCEDURE create_party(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_party_rec			   IN  oke_party_pvt.party_rec_type,
    x_party_rec			   OUT NOCOPY  oke_party_pvt.party_rec_type);

  PROCEDURE create_party(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_party_tbl			   IN  oke_party_pvt.party_tbl_type,
    x_party_tbl			   OUT NOCOPY oke_party_pvt.party_tbl_type);


/*------------------------------------------------------------

	updates -
		funding_pool_id		- not updatable
		initial_amount		- not updatable

		currency_codes and conversions
			- updatable only if no funding
			  sources children exists

		conversion_date and _type must be specified
		if currency is different from funding_pool

		conversion_rate can never be specified

		available_amount cannot be specified

		if amount is specified
		then amount will be changed to as specified
		and available amount automatically changed
		based on the difference between the old amount
		and new amount


	pool_party_id is used as the key for updating rows,
	therefore must be specified.

-------------------------------------------------------------*/





  PROCEDURE update_party(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_rec			   IN oke_party_pvt.party_rec_type,
    x_party_rec			   OUT NOCOPY oke_party_pvt.party_rec_type);


  PROCEDURE update_party(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_tbl			   IN oke_party_pvt.party_tbl_type,
    x_party_tbl			   OUT NOCOPY oke_party_pvt.party_tbl_type);

-- cascading deletes

  PROCEDURE delete_party(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_rec			   IN oke_party_pvt.party_rec_type);


  PROCEDURE delete_party(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_tbl			   IN oke_party_pvt.party_tbl_type);

  PROCEDURE delete_party(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_party_id		   IN NUMBER);


  PROCEDURE lock_party(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_party_rec           IN OKE_PARTY_PVT.party_rec_type);

  PROCEDURE lock_party(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_tbl                     IN oke_party_pvt.party_tbl_type);

END OKE_POOLS_PARTIES_PUB;


 

/
