--------------------------------------------------------
--  DDL for Package FA_MASS_RET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASS_RET_PUB" AUTHID CURRENT_USER as
/* $Header: FAPMRLDS.pls 120.1.12010000.2 2009/07/19 12:16:52 glchen ship $   */



PROCEDURE CREATE_CRITERIA
   (p_api_version           	in     NUMBER
   ,p_init_msg_list        	in     VARCHAR2 := FND_API.G_FALSE
   ,p_commit                	in     VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level      	in     NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_calling_fn            	in     VARCHAR2
   ,x_return_status         	out    NOCOPY VARCHAR2
   ,x_msg_count             	out    NOCOPY NUMBER
   ,x_msg_data              	out    NOCOPY VARCHAR2
   ,px_mass_ret_rec             in out
			NOCOPY FA_CUSTOM_RET_VAL_PKG.mass_ret_rec_tbl_type);



END FA_MASS_RET_PUB;

/
