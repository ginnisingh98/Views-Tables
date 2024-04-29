--------------------------------------------------------
--  DDL for Package FA_XML_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_XML_REPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXREXTS.pls 120.0.12010000.1 2009/07/21 12:38:01 glchen noship $ */


PROCEDURE clob_to_file
        (p_xml_clob           IN CLOB);

PROCEDURE put_encoding(code     IN VARCHAR2);

PROCEDURE put_starttag(tag_name IN VARCHAR2);

PROCEDURE put_endtag(tag_name   IN VARCHAR2);


PROCEDURE asset_impairment_report(
                        errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY NUMBER,
                        p_book_type_code   IN         VARCHAR2, -- req
                        p_set_of_books_id  IN         NUMBER,   -- req
                        p_period_counter   IN         NUMBER,   -- req
                        p_impairment_id    IN         NUMBER,   -- opt
                        p_cash_gen_unit_id IN         NUMBER,   -- opt
                        p_request_id       IN         NUMBER, -- opt, not displayed
                        p_status           IN         VARCHAR2 );  -- opt, not displayed

PROCEDURE list_assets_by_cash_gen(
                        errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY NUMBER,
                        p_book_type_code   IN         VARCHAR2,
                        p_set_of_books_id  IN         NUMBER,
                        p_cash_gen_unit_id IN         NUMBER,
                        p_asset_id         IN         NUMBER );

END FA_XML_REPORT_PKG;

/
