--------------------------------------------------------
--  DDL for Package JAI_CMN_GL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_GL_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_gl.pls 120.1 2005/07/20 12:57:06 avallabh ship $ */

PROCEDURE get_account_number(
p_chart_of_accounts_id IN NUMBER,
p_ccid IN NUMBER,
p_account_number OUT NOCOPY VARCHAR2
);

PROCEDURE create_gl_entry
          (p_organization_id number,
           p_currency_code varchar2,
           p_credit_amount number,
           p_debit_amount number,
           p_cc_id number,
           p_je_source_name varchar2,
           p_je_category_name varchar,
           p_created_by number,
           p_accounting_date date default null,
           p_currency_conversion_date date default null,
           p_currency_conversion_type varchar2 default null,
           p_currency_conversion_rate number default null,
           p_reference_10 varchar2 default null, --Added by Nagaraj.s for Bug2801751. Populated - Transaction Types || Document Number || Transaction Description
           p_reference_23 varchar2 default null, --Added by Nagaraj.s for Bug2801751. Populated - Object Name
           p_reference_24 varchar2 default null, --Added by Nagaraj.s for Bug2801751. Populated-  Unique Key Table Name
           p_reference_25 varchar2 default null, --Added by Nagaraj.s for Bug2801751. Populated-  Unique Key Column Name
           p_reference_26 varchar2 default null --Added by Nagaraj.s for Bug2801751.  Populated-  Unique Key
           );


Procedure create_gl_entry_for_opm(n_organization_id number,
                                    n_currency_code varchar2,
                                    n_credit_amount number,
                                    n_debit_amount number,
                                    n_cc_id number,
                                    n_je_source_name  in varchar2,
                                    n_je_category_name in varchar2,
                                    n_created_by  in number) ;

END jai_cmn_gl_pkg ;
 

/
