--------------------------------------------------------
--  DDL for Package IGI_IMP_IAC_PREPARE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IMP_IAC_PREPARE_PKG" AUTHID CURRENT_USER AS
-- $Header: igiimpds.pls 120.4.12000000.1 2007/08/01 16:21:33 npandya ship $

/*=========================================================================+
 | Procedure Name:                                                         |
 |    Prepare_Data                                                         |
 |                                                                         |
 | Description:                                                            |
 |    This Procedure accepts the book and the book class as parameters.    |
 |    Depending on the book class it calls either the Prepare_Mhca_Data    |
 |    or the Prepare_Corp_Data function.                                   |
 |                                                                         |
 +=========================================================================*/
    Procedure Prepare_Data(
       errbuf              out NOCOPY varchar2,
       retcode             out NOCOPY number,
       p_book_class        in  varchar2 ,
       p_book_type_code    in  varchar2 );

/*=========================================================================+
 | Function Name:                                                          |
 |    Prepare_Mhca_Data                                                    |
 |                                                                         |
 | Description:                                                            |
 |    This Function prepares the IAC Implementation data for a MHCA Tax    |
 |    Book.                                                                |
 |                                                                         |
 +=========================================================================*/
    Function Prepare_Mhca_Data(
       p_book                   in  varchar2,
       p_book_last_per_counter  in  number,
       p_book_curr_fiscal_year  in  number,
       p_corp_book              in  varchar2,
       p_corp_last_per_counter  in  number,
       p_corp_curr_fiscal_year  in  number,
       p_corp_curr_period_num   in  number,
       p_out_message            out NOCOPY varchar2 ) Return Boolean;

/*=========================================================================+
 | Function Name:                                                          |
 |    Prepare_Corp_Data                                                    |
 |                                                                         |
 | Description:                                                            |
 |    This Function prepares the IAC Implementation data for a Corporate   |
 |    Book.                                                                |
 |                                                                         |
 +=========================================================================*/
    Function Prepare_Corp_Data(
       p_corp_book              in  varchar2,
       p_corp_last_per_counter  in  number,
       p_corp_curr_fiscal_year  in  number,
       p_corp_curr_period_num   in  number,
       p_out_message            out NOCOPY varchar2  ) Return Boolean;

END IGI_IMP_IAC_PREPARE_PKG; -- Package spec

 

/
