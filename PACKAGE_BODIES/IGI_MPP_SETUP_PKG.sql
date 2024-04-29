--------------------------------------------------------
--  DDL for Package Body IGI_MPP_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_MPP_SETUP_PKG" AS
-- $Header: igipmsub.pls 115.6 2003/12/01 16:13:17 sdixit ship $
   --bug 3199481: following variables added for fnd logging changes:sdixit :start
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;

   PROCEDURE insert_row
       ( X_rowid                       in out NOCOPY VARCHAR2
       , X_set_of_books_id             in  NUMBER
       , X_future_posting_ccid         in  NUMBER
       , X_default_accounting_rule_id  in NUMBER
       , X_je_category_name            in VARCHAR2
       , X_je_source_name              in VARCHAR2
       , X_creation_date               in date
       , X_created_by                  in number
       , X_last_update_date            in date
       , X_last_updated_by             in number
       , X_last_update_login           in number
       )  IS

       CURSOR c_insert IS
          SELECT rowid row_id
          FROM   igi_mpp_setup
          WHERE  set_of_books_id = X_set_of_books_id ;
   BEGIN
     INSERT INTO IGI_MPP_SETUP
        ( set_of_books_id
       , future_posting_ccid
       , default_accounting_rule_id
       , je_category_name
       , je_source_name
       , creation_date
       , created_by
       , last_update_date
       , last_updated_by
       , last_update_login   )
       VALUES (
         X_set_of_books_id
       , X_future_posting_ccid
       , X_default_accounting_rule_id
       , X_je_category_name
       , X_je_source_name
       , X_creation_date
       , X_created_by
       , X_last_update_date
       , X_last_updated_by
       , X_last_update_login
       );


     OPEN c_insert;
     FETCH c_insert INTO X_rowid;
     IF c_insert%NOTFOUND THEN
        CLOSE c_insert;
        raise no_data_found;
   --bug 3199481: fnd logging changes:sdixit :start
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.pls.igipmsub.IGI_MPP_SETUP_PKG.Insert_Row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
     END IF;
     CLOSE c_insert;
   END;

   PROCEDURE update_row
       ( X_rowid                       in out NOCOPY VARCHAR2
       , X_future_posting_ccid         in  NUMBER
       , X_default_accounting_rule_id  in NUMBER
       , X_je_category_name            in VARCHAR2
       , X_je_source_name              in VARCHAR2
       , X_last_update_date            in date
       , X_last_updated_by             in number
       , X_last_update_login           in number
       )  IS
   BEGIN
      UPDATE igi_mpp_setup SET
          future_posting_ccid          = X_future_posting_ccid
          , default_accounting_rule_id = X_default_accounting_rule_id
          , je_category_name           = X_je_category_name
          , je_source_name             = X_je_source_name
          , last_update_date           = X_last_update_date
          , last_updated_by            = X_last_updated_by
          , last_update_login          = X_last_update_login
      WHERE  rowid                     = X_rowid
      ;
      IF SQL%NOTFOUND THEN
         raise no_data_found;
   --bug 3199481: fnd logging changes:sdixit :start
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.pls.igipmsub.IGI_MPP_SETUP_PKG.Update_Row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      END IF;

   END;

   PROCEDURE lock_row
       ( X_rowid                       in out NOCOPY VARCHAR2
       , X_set_of_books_id             in  NUMBER
       , X_future_posting_ccid         in  NUMBER
       , X_default_accounting_rule_id  in NUMBER
       , X_je_category_name            in VARCHAR2
       , X_je_source_name              in VARCHAR2
       )  IS

       CURSOR c_mpp_Setup IS
         SELECT *
         from   igi_mpp_setup
         where  rowid         = X_rowid
         for    update of set_of_books_id NOWAIT
         ;

       l_mpp_setup c_mpp_setup%ROWTYPE;

   BEGIN
       OPEN c_mpp_setup;
       FETCH c_mpp_setup INTO l_mpp_setup;
       IF c_mpp_setup%NOTFOUND THEN
           close c_mpp_setup;
           fnd_message.set_name( 'FND', 'FORM_RECORD_DELETED');
   --bug 3199481: fnd logging changes:sdixit :start
           IF (l_error_level >=  l_debug_level ) THEN
               FND_LOG.MESSAGE (l_error_level , 'igi.pls.igipmsub.IGI_MPP_SETUP_PKG.Lock_Row.FORM_RECORD_DELETED',FALSE);
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
           app_exception.raise_exception;
       END IF;
       CLOSE c_mpp_setup;
       IF  (
              (X_set_of_books_id    =   l_mpp_setup.set_of_books_id  )
              AND (
                    ( l_mpp_setup.future_posting_ccid    =    X_future_posting_ccid )  OR
                    ( l_mpp_setup.future_posting_ccid is null   AND
                      X_future_posting_ccid           is null )
                   )
              AND (
                    ( l_mpp_setup.default_accounting_rule_id   =    X_default_accounting_rule_id )  OR
                    ( l_mpp_setup.default_accounting_rule_id is null   AND
                      X_default_accounting_rule_id           is null )
                   )
               AND (
                    ( l_mpp_setup.je_category_name   =    X_je_category_name )  OR
                    ( l_mpp_setup.je_category_name is null   AND
                      X_je_category_name           is null )
                   )
              AND (
                    ( l_mpp_setup.je_source_name     =    X_je_source_name  )  OR
                    ( l_mpp_setup.je_source_name  is null   AND
                      X_je_source_name            is null )
                   )
            )
            THEN
               return;
            else
               fnd_message.set_name( 'FND', 'FORM_RECORD_CHANGED');
   --bug 3199481: fnd logging changes:sdixit :start
               IF (l_error_level >=  l_debug_level ) THEN
                   FND_LOG.MESSAGE (l_error_level , 'igi.pls.igipmsub.IGI_MPP_SETUP_PKG.Lock_Row.FORM_RECORD_CHANGED',FALSE);
               END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
               app_exception.raise_exception;
            END IF;
   END;

   -- Enter further code below as specified in the Package spec.
END IGI_MPP_SETUP_PKG ;

/
