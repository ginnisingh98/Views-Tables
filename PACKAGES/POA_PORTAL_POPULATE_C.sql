--------------------------------------------------------
--  DDL for Package POA_PORTAL_POPULATE_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_PORTAL_POPULATE_C" AUTHID CURRENT_USER AS
/*$Header: poaporss.pls 120.0 2005/06/01 14:08:12 appldev noship $ */


PROCEDURE populate_poa(Errbuf	in out NOCOPY Varchar2,
		  	Retcode	in out NOCOPY Varchar2);

PROCEDURE populate_poa_fii(Errbuf	in out NOCOPY Varchar2,
		  	Retcode	in out NOCOPY Varchar2);

PROCEDURE insert_rows_pd(p_start in DATE,
			p_end in DATE,
			p_quarter in varchar2,
			p_count out NOCOPY NUMBER,
			success out NOCOPY varchar2);

PROCEDURE insert_rows_sr(p_start in DATE,
                        p_end in DATE,
                        p_count out NOCOPY NUMBER,
                        success out NOCOPY varchar2);

PROCEDURE insert_rows_cm(p_start in DATE,
                        p_end in DATE,
                        p_count out NOCOPY NUMBER,
                        success out NOCOPY varchar2);

PROCEDURE truncate_tables (p_type IN NUMBER,
				success  OUT NOCOPY varchar2);

PROCEDURE insert_rows_sp(p_start in DATE,
			p_end in DATE,
			p_count out NOCOPY NUMBER,
			success out NOCOPY varchar2);

PROCEDURE insert_rows_rcv(p_start in DATE,
                        p_end in DATE,
                        p_count out NOCOPY NUMBER,
                        success out NOCOPY varchar2);


PROCEDURE insert_rows_cross(p_start in DATE,
			p_end in DATE,
			p_count out NOCOPY NUMBER,
			success out NOCOPY varchar2);

END POA_PORTAL_POPULATE_C;

 

/
