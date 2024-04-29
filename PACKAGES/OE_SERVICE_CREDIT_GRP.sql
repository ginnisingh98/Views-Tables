--------------------------------------------------------
--  DDL for Package OE_SERVICE_CREDIT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SERVICE_CREDIT_GRP" AUTHID CURRENT_USER as
/* $Header: OEXGSVCS.pls 120.0 2005/06/01 22:46:51 appldev noship $ */
G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OE_SERVICE_CREDIT_GRP';

PROCEDURE GET_SERVICE_CREDIT_ELIGIBLE(
	p_line_id  in number,
	p_service_credit_eligible out NOCOPY /* file.sql.39 change */ varchar2);

END OE_SERVICE_CREDIT_GRP;

 

/
