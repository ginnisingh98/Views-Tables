--------------------------------------------------------
--  DDL for Package INV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_UTIL" AUTHID CURRENT_USER AS
/* $Header: INVINUTS.pls 115.4 2002/12/31 20:48:43 lplam ship $ */

-- API Name	insert_mmtt
-- Type		Public
-- Description  This procedure inserts data in mtl_material_transactions_temp.
--
-- Input Parameters:
--   p_api_version	IN NUMBER (required)
--   p_init_msg_level	IN VARCHAR2 (optional)
--			DEFAULT = FND_API.G_FALSE
--   p_commit		IN VARCHAR2 (optional)
--			DEFAULT = FND_API.G_FALSE
--   p_validation_level NUMBER (optional)
--			DEFAULT = FND_API.G_VALID_LEVEL_FULL
--   p_mmtt_rec		IN mtl_material_transactions_temp%ROWTYPE (required)
--                      The mtl_material_transactions_temp record to be inserted.
--
-- Output Parameters:
--   x_trx_header_id 	Trasaction header id
--   x_trx_temp_id	Transaction temp id
--   x_return_status    fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_success,
--			fnd_api.g_ret_unexp_error
--   x_msg_count	number of error messages in the buffer
--   x_msg_data		error messages

PROCEDURE insert_mmtt(p_api_version      IN  NUMBER,
		      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
		      p_commit		 IN  VARCHAR2 := FND_API.G_FALSE,
		      p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                      p_mmtt_rec	 IN  mtl_material_transactions_temp%ROWTYPE,
                      x_trx_header_id	 OUT NOCOPY NUMBER,
		      x_trx_temp_id      OUT NOCOPY NUMBER,
		      x_return_status    OUT NOCOPY VARCHAR2,
		      x_msg_count	 OUT NOCOPY NUMBER,
		      x_msg_data         OUT NOCOPY VARCHAR2);


-- API Name     insert_mtlt
-- Type         Public
-- Description  This procedure inserts data in mtl_transaction_lots_temp.
--
-- Input Parameters:
--   p_api_version      IN NUMBER (required)
--   p_init_msg_level   IN VARCHAR2 (optional)
--                      DEFAULT = FND_API.G_FALSE
--   p_commit           IN VARCHAR2 (optional)
--                      DEFAULT = FND_API.G_FALSE
--   p_validation_level NUMBER (optional)
--                      DEFAULT = FND_API.G_VALID_LEVEL_FULL
--   p_mtlt_rec         IN mtl_transaction_lots_temp%ROWTYPE (required)
--                      The mtl_transaction_lots_temp record to be inserted.
--
-- Output Parameters:
--   x_return_status    fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_success,
--                      fnd_api.g_ret_unexp_error
--   x_msg_count        number of error messages in the buffer
--   x_msg_data         error messages

PROCEDURE insert_mtlt(p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                      p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                      p_mtlt_rec 	 IN  mtl_transaction_lots_temp%ROWTYPE,
		      x_return_status    OUT NOCOPY VARCHAR2,
		      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2);


-- API Name     insert_msnt
-- Type         Public
-- Description  This procedure inserts data in mtl_serial_numbers_temp.
--
-- Input Parameters:
--   p_api_version      IN NUMBER (required)
--   p_init_msg_level   IN VARCHAR2 (optional)
--                      DEFAULT = FND_API.G_FALSE
--   p_commit           IN VARCHAR2 (optional)
--                      DEFAULT = FND_API.G_FALSE
--   p_validation_level NUMBER (optional)
--                      DEFAULT = FND_API.G_VALID_LEVEL_FULL
--   p_msnt_rec         IN mtl_serial_numbers_temp%ROWTYPE (required)
--                      The mtl_serial_numbers_temp record to be inserted.
--
-- Output Parameters:
--   x_return_status    fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_success,
--                      fnd_api.g_ret_unexp_error
--   x_msg_count        number of error messages in the buffer
--   x_msg_data         error messages

PROCEDURE insert_msnt(p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                      p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		      p_msnt_rec	 IN  mtl_serial_numbers_temp%ROWTYPE,
		      x_return_status    OUT NOCOPY VARCHAR2,
		      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2);

END inv_util;

 

/
