--------------------------------------------------------
--  DDL for Package OPI_DBI_OPM_COGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_OPM_COGS_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIDMPRS.pls 115.6 2003/01/27 19:29:05 cdaly noship $ */

FUNCTION check_ici(p_ship_ou_id NUMBER, p_sell_ou_id NUMBER ) RETURN NUMBER;

PROCEDURE refresh_opm_subl_org_cogs(
				     p_last_id         IN NUMBER,
				     p_newest_id       IN NUMBER,
				     x_status          OUT NOCOPY NUMBER,
				     x_msg             OUT NOCOPY VARCHAR2 );

PROCEDURE refresh_icap_cogs;

FUNCTION refresh_opm_cogs (errbuf     in out NOCOPY varchar2,
			   retcode    in out NOCOPY VARCHAR2) RETURN NUMBER ;

PROCEDURE complete_refresh_OPM_margin(Errbuf      in out NOCOPY  Varchar2,
				      Retcode     in out NOCOPY  Varchar2,
                                      p_degree    IN     NUMBER );

PROCEDURE refresh_OPM_margin(Errbuf      in out  NOCOPY Varchar2,
                             Retcode     in out  NOCOPY Varchar2);

END opi_dbi_opm_cogs_pkg;

 

/
