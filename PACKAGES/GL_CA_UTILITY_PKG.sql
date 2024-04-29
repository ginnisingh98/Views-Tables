--------------------------------------------------------
--  DDL for Package GL_CA_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CA_UTILITY_PKG" AUTHID CURRENT_USER AS
/* $Header: glcauts.pls 120.5 2003/03/11 04:41:21 lpoon noship $ */

-- R11i.X Changes: Delete these data types which are no longer used
/*
       TYPE id_arr IS TABLE OF NUMBER(15);
       TYPE var_arr1 IS TABLE OF VARCHAR2(1);
       TYPE var_arr15 IS TABLE OF VARCHAR2(15);
       TYPE var_arr20 IS TABLE OF VARCHAR2(20);
       TYPE var_arr30 IS TABLE OF VARCHAR2(30);
       TYPE date_arr IS TABLE OF  DATE;


       TYPE r_sob_rec_col IS RECORD (
				     r_sob_id           id_arr,
                     r_sob_name         var_arr30,
                     r_sob_curr         var_arr15
                     );

       TYPE r_trans_info IS RECORD (
				     r_exchange_rate   NUMBER,
				     r_exchange_date   DATE,
				     r_exchange_rate_type VARCHAR2(30),
                     r_trans_currency  VARCHAR2(15),
                     r_trans_date      DATE
                     );
*/
       TYPE r_sob_rec IS RECORD (
                 r_sob_id                    NUMBER(15),
                 r_sob_name                  VARCHAR2(30),
                 r_sob_curr                  VARCHAR2(15),
                 conversion_type             VARCHAR2(30),
                 conversion_date             DATE,
				 conversion_rate             NUMBER,
				 ap_second_type              VARCHAR2(30),
				 ap_second_date              DATE,
				 ap_second_rate              NUMBER,
				 cleared_exchange_date       DATE,
				 cleared_exchange_rate_type  VARCHAR2(30),
				 cleared_exchange_rate       NUMBER,
				 maturity_exchange_date      DATE,
				 maturity_exchange_rate_type VARCHAR2(30),
				 maturity_exchange_rate	     NUMBER,
				 denominator_rate            NUMBER,
				 numerator_rate              NUMBER,
				 result_code                 VARCHAR2(25),
                 misc_number1                NUMBER,
                 misc_number2                NUMBER,
                 misc_number3                NUMBER,
                 misc_number4                NUMBER,
				 misc_number5                NUMBER,
                 misc_date1                  DATE,
                 misc_date2                  DATE,
                 misc_varchar1               VARCHAR2(30),
                 misc_varchar2               VARCHAR2(30)
                 );

       TYPE r_sob_list IS TABLE OF r_sob_rec;

       TYPE r_key_value_arr IS VARRAY(1000) of NUMBER(15);

       PROCEDURE get_sob_type (p_sob_id   IN  NUMBER,
                               p_sob_type OUT NOCOPY VARCHAR2);

       FUNCTION  mrc_enabled (p_sob_id         IN  NUMBER,
                              p_appl_id        IN  NUMBER,
                              p_org_id         IN  NUMBER,
                              p_fa_book_code   IN  VARCHAR2 DEFAULT NULL
                             ) RETURN BOOLEAN;

       PROCEDURE get_associated_sobs (p_sob_id         IN     NUMBER,
                                      p_appl_id        IN     NUMBER,
                                      p_org_id         IN     NUMBER,
                                      p_fa_book_code   IN     VARCHAR2 DEFAULT NULL,
                                      p_sob_list       IN OUT NOCOPY r_sob_list);

       PROCEDURE get_rate(
                        p_primary_set_of_books_id IN NUMBER,
                        p_trans_date              IN DATE,
                        p_trans_currency_code     IN VARCHAR2,
                        p_application_id          IN NUMBER,
                        p_org_id                  IN NUMBER,
                        p_exchange_rate_date      IN DATE,
                        p_exchange_rate           IN NUMBER,
                        p_exchange_rate_type      IN VARCHAR2,
                        p_fa_book_type_code       IN VARCHAR2 DEFAULT NULL,
                        p_je_source_name          IN VARCHAR2 DEFAULT NULL,
                        p_je_category_name        IN VARCHAR2 DEFAULT NULL,
                        p_sob_list                IN OUT NOCOPY r_sob_list );

END gl_ca_utility_pkg;

 

/
