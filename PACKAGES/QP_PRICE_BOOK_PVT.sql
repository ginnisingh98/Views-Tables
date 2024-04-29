--------------------------------------------------------
--  DDL for Package QP_PRICE_BOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRICE_BOOK_PVT" AUTHID CURRENT_USER AS
/*$Header: QPXVGPBS.pls 120.2.12010000.2 2008/10/15 13:33:22 dnema ship $*/

TYPE NUMBER_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE PLS_INTEGER_TYPE IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;
TYPE VARCHAR3_TYPE IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
TYPE VARCHAR30_TYPE IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE VARCHAR_TYPE IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE VARCHAR2000_TYPE IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE DATE_TYPE IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE FLAG_TYPE IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

G_pb_Processor_Batchsize PLS_INTEGER; --bug 7453115

rows     NATURAL := 5000;

PROCEDURE Generate_Publish_Price_Book(p_pb_input_header_id IN  NUMBER,
                                      x_request_id         OUT NOCOPY NUMBER,
				      x_return_status      OUT NOCOPY VARCHAR2,
                                      x_retcode            OUT NOCOPY NUMBER,
                                      x_err_buf            OUT NOCOPY VARCHAR2);

PROCEDURE Price_Book_Conc_Pgm(retcode                 OUT NOCOPY NUMBER,
                              errbuf                  OUT NOCOPY VARCHAR2,
                              p_pb_input_header_id    IN  NUMBER,
                              p_customer_id           IN  NUMBER := NULL,
                              p_price_book_header_id  IN  NUMBER := NULL,
                              p_spawned_request       IN  VARCHAR2 := 'N');

END QP_PRICE_BOOK_PVT;

/
