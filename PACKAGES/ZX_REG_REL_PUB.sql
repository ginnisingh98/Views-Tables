--------------------------------------------------------
--  DDL for Package ZX_REG_REL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_REG_REL_PUB" AUTHID CURRENT_USER AS
/* $Header: zxcregrelpubs.pls 120.1 2004/01/02 15:43:49 vramamur ship $ */

TYPE regime_rec is RECORD(
                	  regime_code VARCHAR2(30),
                          regime_name VARCHAR2(80)
                         );
TYPE regime_rec_arr_type is table of regime_rec index by binary_integer;
TYPE regime_level_rec is RECORD(
                	  regime_code VARCHAR2(30),
                          parent_regime_code VARCHAR2(30),
                          level NUMBER
                         );
TYPE regime_rec_level_arr_type is table of regime_level_rec index by binary_integer;

PROCEDURE insert_rel(
			x_return_status OUT NOCOPY VARCHAR2,
			p_child  IN VARCHAR2,
			p_parent IN VARCHAR2,
			X_CREATED_BY in NUMBER,
			X_CREATION_DATE in DATE,
			X_LAST_UPDATED_BY in NUMBER,
			X_LAST_UPDATE_DATE in DATE,
			X_LAST_UPDATE_LOGIN in NUMBER,
			X_REQUEST_ID in NUMBER,
			X_PROGRAM_ID in NUMBER,
			X_PROGRAM_LOGIN_ID in NUMBER,
			X_PROGRAM_APPLICATION_ID in NUMBER
			);

PROCEDURE update_rel(
			x_return_status OUT NOCOPY VARCHAR2,
			p_child  IN  VARCHAR2 ,
			p_parent IN  VARCHAR2 default null,
			X_LAST_UPDATED_BY in NUMBER,
			X_LAST_UPDATE_DATE in DATE,
			X_LAST_UPDATE_LOGIN in NUMBER,
			X_REQUEST_ID in NUMBER,
			X_PROGRAM_ID in NUMBER,
			X_PROGRAM_LOGIN_ID in NUMBER,
			X_PROGRAM_APPLICATION_ID in NUMBER
			);

PROCEDURE update_taxes(
                      x_return_status OUT NOCOPY VARCHAR2,
                      p_regime_code  IN  VARCHAR2 ,
                      p_old_rep_tax_auth_id IN  NUMBER ,
		      p_old_coll_tax_auth_id IN  NUMBER,
		      p_new_rep_tax_auth_id IN  NUMBER ,
		      p_new_coll_tax_auth_id IN  NUMBER
                    );

PROCEDURE get_regime_details(
                            x_return_status  OUT NOCOPY VARCHAR2,
                            p_country_code   IN  VARCHAR2 default null,
                            p_tax_regime_code IN VARCHAR2 default null,
                            x_regime_rec  OUT NOCOPY regime_rec_arr_type                                                                                 );

PROCEDURE get_regime_hierarchy(
                              x_return_status  OUT NOCOPY VARCHAR2,
                              p_tax_regime_code IN VARCHAR2 default null,
                              x_regime_level_rec  OUT NOCOPY regime_rec_level_arr_type
                             );

END ZX_REG_REL_PUB;

 

/
