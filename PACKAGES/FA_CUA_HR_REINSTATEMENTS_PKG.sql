--------------------------------------------------------
--  DDL for Package FA_CUA_HR_REINSTATEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_HR_REINSTATEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: FACHRINMS.pls 120.1.12010000.2 2009/07/19 12:17:50 glchen ship $ */

PROCEDURE reinstate ( x_batch_num            IN NUMBER
                    , x_conc_request_id      IN NUMBER
                    , x_book_type_code       IN VARCHAR2
                    , x_retirement_date      IN DATE
                    , x_currency_code        IN VARCHAR2
                    , x_fy_start_date        IN DATE
                    , x_fy_end_date          IN DATE
                    , x_attribute_category   IN VARCHAR2
                    , x_attribute1           IN VARCHAR2
                    , x_attribute2           IN VARCHAR2
                    , x_attribute3           IN VARCHAR2
                    , x_attribute4           IN VARCHAR2
                    , x_attribute5           IN VARCHAR2
                    , x_attribute6           IN VARCHAR2
                    , x_attribute7           IN VARCHAR2
                    , x_attribute8           IN VARCHAR2
                    , x_attribute9           IN VARCHAR2
                    , x_attribute10          IN VARCHAR2
                    , x_attribute11          IN VARCHAR2
                    , x_attribute12          IN VARCHAR2
                    , x_attribute13          IN VARCHAR2
                    , x_attribute14          IN VARCHAR2
                    , x_attribute15          IN VARCHAR2
                    , TH_attribute_category  IN VARCHAR2
                    , TH_attribute1          IN VARCHAR2
                    , TH_attribute2          IN VARCHAR2
                    , TH_attribute3          IN VARCHAR2
                    , TH_attribute4          IN VARCHAR2
                    , TH_attribute5          IN VARCHAR2
                    , TH_attribute6          IN VARCHAR2
                    , TH_attribute7          IN VARCHAR2
                    , TH_attribute8          IN VARCHAR2
                    , TH_attribute9          IN VARCHAR2
                    , TH_attribute10         IN VARCHAR2
                    , TH_attribute11         IN VARCHAR2
                    , TH_attribute12         IN VARCHAR2
                    , TH_attribute13         IN VARCHAR2
                    , TH_attribute14         IN VARCHAR2
                    , TH_attribute15         IN VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) ;

PROCEDURE conc_request( ERRBUF OUT NOCOPY VARCHAR2,
                        RETCODE OUT NOCOPY VARCHAR2,
                        x_from_batch_num IN NUMBER,
                        x_to_batch_num IN NUMBER );


END FA_CUA_HR_REINSTATEMENTS_PKG;

/
