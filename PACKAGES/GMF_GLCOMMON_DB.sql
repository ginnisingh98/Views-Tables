--------------------------------------------------------
--  DDL for Package GMF_GLCOMMON_DB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GLCOMMON_DB" AUTHID CURRENT_USER AS
/*       $Header: gmfglcos.pls 115.1 2002/11/11 00:38:06 rseshadr ship $ */
PROCEDURE proc_get_closest_rate(
		x_from_currency_code		VARCHAR2,
		x_to_currency_code		VARCHAR2,
		x_exchange_rate_date		DATE,
		x_rate_type_code		VARCHAR2 DEFAULT NULL,
		x_exchange_rate			OUT NOCOPY NUMBER,
		x_mul_div_sign                  OUT NOCOPY NUMBER,
		error_status			IN OUT NOCOPY NUMBER);

PROCEDURE proc_is_fixed_rate(
		x_from_currency			VARCHAR2,
		x_to_currency			VARCHAR2,
		x_effective_date		DATE    ,
		x_fixed_check			OUT NOCOPY VARCHAR2,
		error_status			IN OUT NOCOPY NUMBER);

FUNCTION get_closest_rate (
		x_from_currency_code		VARCHAR2,
		x_to_currency_code		VARCHAR2,
		x_exchange_rate_date		DATE,
		x_rate_type_code		VARCHAR2 DEFAULT NULL,
                x_mul_div_sign                  OUT NOCOPY NUMBER,
		error_status			IN OUT NOCOPY NUMBER) RETURN NUMBER;

PROCEDURE get_info(
		x_currency			VARCHAR2,
		x_eff_date			DATE,
		x_exchange_rate			IN OUT  NOCOPY NUMBER,
		x_mau				IN OUT  NOCOPY NUMBER,
		x_currency_type			IN OUT  NOCOPY VARCHAR2,
		error_status			IN OUT  NOCOPY NUMBER );

FUNCTION is_fixed_rate (
		x_from_currency			VARCHAR2,
		x_to_currency			VARCHAR2,
		x_effective_date		DATE      ,
		error_status			IN OUT NOCOPY NUMBER) RETURN VARCHAR2;

NO_RATE			EXCEPTION;
INVALID_CURRENCY	EXCEPTION;
END GMF_GLCOMMON_DB;

 

/
