--------------------------------------------------------
--  DDL for Package FA_MC_UPG1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MC_UPG1_PKG" AUTHID CURRENT_USER AS
/* $Header: faxmcu1s.pls 120.2.12010000.2 2009/07/19 10:06:12 glchen ship $   */

FUNCTION lock_book (
                p_book_type_code        IN      VARCHAR2,
                p_rsob_id               IN      NUMBER)
                                RETURN BOOLEAN;

PROCEDURE validate_setup(
                p_book_type_code        IN      VARCHAR2,
                p_reporting_book        IN      VARCHAR2,
                X_from_currency         OUT NOCOPY     VARCHAR2,
                X_to_currency           OUT NOCOPY     VARCHAR2,
                X_rsob_id               OUT NOCOPY     NUMBER,
                X_psob_id               OUT NOCOPY     NUMBER);

PROCEDURE validate_rate (
                p_book_type_code        IN      VARCHAR2,
                p_rsob_id               IN      NUMBER,
                p_fixed_rate            IN      VARCHAR2,
                X_fixed_conversion      OUT NOCOPY     VARCHAR2);

PROCEDURE set_conversion_status(
                p_book_type_code        IN      VARCHAR2,
                p_rsob_id               IN      NUMBER,
		p_start_pc		IN	NUMBER,
                p_end_pc                IN      NUMBER,
		p_fixed_conversion	IN	VARCHAR2,
                p_mode                  IN      VARCHAR2);

PROCEDURE get_conversion_info(
                p_book_type_code        IN      VARCHAR2,
                p_psob_id               IN      NUMBER,
                p_rsob_id               IN      NUMBER,
                X_start_pc              OUT NOCOPY     NUMBER,
                X_end_pc                OUT NOCOPY     NUMBER,
                X_conv_date             OUT NOCOPY     DATE,
                X_conv_type             OUT NOCOPY     VARCHAR2,
		X_accounting_date OUT NOCOPY DATE);

PROCEDURE get_candidate_assets(
                p_book_type_code        IN      VARCHAR2,
                p_rsob_id               IN      NUMBER,
                p_start_pc              IN      NUMBER,
                p_end_pc                IN      NUMBER,
		p_exchange_rate		IN	NUMBER,
		p_fixed_rate		IN	VARCHAR2,
		X_total_assets	 OUT NOCOPY NUMBER);

PROCEDURE check_preview_status(
                p_book_type_code        IN      VARCHAR2,
                p_rsob_id               IN      NUMBER,
                p_end_pc                IN      NUMBER);

PROCEDURE get_currency_precision(
		p_to_currency		IN 	VARCHAR2,
		X_precision	 OUT NOCOPY NUMBER,
		X_mau		 OUT NOCOPY NUMBER);

PROCEDURE get_rate_info(
                p_from_currency         IN      VARCHAR2,
                p_to_currency           IN      VARCHAR2,
                p_conv_date             IN      DATE,
                p_conv_type             IN      VARCHAR2,
                X_denominator_rate      OUT NOCOPY     NUMBER,
                X_numerator_rate        OUT NOCOPY     NUMBER,
                X_rate                  OUT NOCOPY     NUMBER,
                X_relation              OUT NOCOPY     VARCHAR2,
		X_fixed_rate	 OUT NOCOPY VARCHAR2);


PROCEDURE convert_reporting_book(
                p_book_type_code        IN      VARCHAR2,
                p_reporting_book        IN      VARCHAR2,
		p_fixed_rate		IN	VARCHAR2);


PROCEDURE convert_assets(
                p_rsob_id               IN      NUMBER,
                p_book_type_code        IN      VARCHAR2,
                p_start_pc              IN      NUMBER,
                p_end_pc                IN      NUMBER,
                p_numerator_rate        IN      NUMBER,
                p_denominator_rate      IN      NUMBER,
                p_mau                   IN      NUMBER,
                p_precision             IN      NUMBER,
		p_fixed_conversion	IN	VARCHAR2);

PROCEDURE create_drop_indexes(
                        p_mode          IN      VARCHAR2);


PROCEDURE  Write_ErrMsg_Log(
		msg_count      		IN	NUMBER);

PROCEDURE Write_DebugMsg_Log(
                p_msg_count             IN      NUMBER);


END FA_MC_UPG1_PKG;

/
