--------------------------------------------------------
--  DDL for Package IGI_IAC_BOOK_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_BOOK_CONTROLS_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiabcs.pls 120.4.12000000.1 2007/08/01 16:12:56 npandya ship $


  PROCEDURE insert_row (

    x_rowid                             IN OUT NOCOPY VARCHAR2,

    x_book_type_code                    IN     VARCHAR2,

    x_gl_je_source                      IN     VARCHAR2,

    x_je_iac_deprn_category             IN     VARCHAR2,

    x_je_iac_reval_category             IN     VARCHAR2,

    x_je_iac_txn_category               IN     VARCHAR2,

    x_period_num_for_catchup            IN     NUMBER,

    x_mode                              IN     VARCHAR2    DEFAULT 'R'

  );



  PROCEDURE lock_row (

    x_rowid                             IN     VARCHAR2,

    x_book_type_code                    IN     VARCHAR2,

    x_gl_je_source                      IN     VARCHAR2,

    x_je_iac_deprn_category             IN     VARCHAR2,

    x_je_iac_reval_category             IN     VARCHAR2,

    x_je_iac_txn_category               IN     VARCHAR2,

    x_period_num_for_catchup            IN     NUMBER

  );



  PROCEDURE update_row (

    x_rowid                             IN     VARCHAR2,

    x_book_type_code                    IN     VARCHAR2,

    x_gl_je_source                      IN     VARCHAR2,

    x_je_iac_deprn_category             IN     VARCHAR2,

    x_je_iac_reval_category             IN     VARCHAR2,

    x_je_iac_txn_category               IN     VARCHAR2,

    x_period_num_for_catchup            IN     NUMBER,

    x_mode                              IN     VARCHAR2    DEFAULT 'R'

  );



  PROCEDURE delete_row (

    x_rowid                             IN     VARCHAR2

  );





  FUNCTION get_org_id RETURN NUMBER ;

END igi_iac_book_controls_pkg;


 

/
