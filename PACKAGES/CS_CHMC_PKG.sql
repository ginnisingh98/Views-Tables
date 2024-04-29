--------------------------------------------------------
--  DDL for Package CS_CHMC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CHMC_PKG" AUTHID CURRENT_USER as
/* $Header: csxchmcs.pls 115.2.1158.2 2003/03/13 02:55:07 aseethep ship $ */

PROCEDURE convert_amount(
			p_from_currency		IN	varchar2,
			p_amount		IN	number,
			p_conversion_date	IN	date,
			p_conversion_type	IN	varchar2,
			p_user_rate		IN	number,
			x_converted_amount	OUT	number);

--
END cs_chmc_pkg;

 

/
