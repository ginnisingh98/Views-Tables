--------------------------------------------------------
--  DDL for Package FA_CUA_MASS_EXT_RET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_MASS_EXT_RET_PKG" AUTHID CURRENT_USER AS
/* $Header: FACXTREMS.pls 120.5.12010000.3 2010/03/21 19:37:33 glchen ship $ */

PROCEDURE Mass_Ext_Retire (P_BOOK_TYPE_CODE 	IN             VARCHAR2,
			   PX_BATCH_NAME	IN OUT  NOCOPY VARCHAR2,
			   P_PARENT_REQUEST_ID	IN             NUMBER,
			   P_TOTAL_REQUESTS	IN             NUMBER,
			   P_REQUEST_NUMBER	IN             NUMBER,
                           PX_MAX_MASS_EXT_RETIRE_ID    IN OUT  NOCOPY NUMBER,
			   X_SUCCESS_COUNT         OUT  NOCOPY NUMBER,
			   X_FAILURE_COUNT         OUT  NOCOPY NUMBER,
			   X_RETURN_STATUS         OUT  NOCOPY NUMBER);

PROCEDURE Purge( ERRBUF   OUT NOCOPY  VARCHAR2 ,
                 RETCODE  OUT NOCOPY  VARCHAR2   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);


PROCEDURE write_message
              (p_asset_number  			in varchar2,
	       p_book_type_code 		in varchar2,
               p_mass_external_retire_id	in number,
               p_message         		in varchar2,
               p_token           		in varchar2,
               p_value           		in varchar2,
               p_app_short_name               	IN VARCHAR2,
               p_db_error                	IN NUMBER,
               p_mode            		in varchar2);



END FA_CUA_MASS_EXT_RET_PKG;

/
