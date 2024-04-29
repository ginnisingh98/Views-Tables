--------------------------------------------------------
--  DDL for Package ONT_OS_MV_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_OS_MV_REFRESH" AUTHID CURRENT_USER AS
/* $Header: ontmvres.pls 120.1 2006/03/29 16:55:16 spooruli noship $ */

--
-- PROCEDURE refresh
--

PROCEDURE refresh_shipped_orders(
errbuf OUT NOCOPY VARCHAR2,

retcode OUT NOCOPY VARCHAR2

);

PROCEDURE refresh_booked_orders(
errbuf OUT NOCOPY VARCHAR2,

retcode OUT NOCOPY VARCHAR2

);

PROCEDURE refresh_summary_mv(
errbuf OUT NOCOPY VARCHAR2,

retcode OUT NOCOPY VARCHAR2

);
END;

/
