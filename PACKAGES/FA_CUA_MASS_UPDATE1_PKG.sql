--------------------------------------------------------
--  DDL for Package FA_CUA_MASS_UPDATE1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_MASS_UPDATE1_PKG" AUTHID CURRENT_USER as
/* $Header: FACMUP1MS.pls 120.1.12010000.3 2009/08/20 14:18:44 bridgway ship $*/

FUNCTION GET_END_DATE(X_book_type_code	         VARCHAR2,
		      x_prorate_date             DATE,
            x_life                     NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) return date;
pragma restrict_references (get_end_date,WNPS,WNDS);

PROCEDURE CALC_LIFE_ENDDATE( x_prorate_date     DATE,
		      x_end_date         in out nocopy DATE,
            x_prorate_convention_code     IN VARCHAR2,
		      x_life             IN number,
		      x_err_code in out nocopy varchar2 ,
		      x_err_stage in out nocopy varchar2 ,
		      x_err_stack in out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) ;

PROCEDURE CALC_LIFE(X_book_type_code	         VARCHAR2,
		      x_prorate_date     DATE,
		      x_end_date         DATE,
            x_deprn_method     IN VARCHAR2,
		      x_life             IN OUT NOCOPY number,
		      x_err_code in out nocopy varchar2 ,
		      x_err_stage in out nocopy varchar2 ,
		      x_err_stack in out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null) ;

Procedure update_category
(x_asset_id in number,
x_old_cat_id in number,
x_new_cat_id in number,
x_err_code in out nocopy varchar2 ,
x_err_stage in out nocopy varchar2 ,
x_err_stack in out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null);


PROCEDURE proc_conc( ERRBUF                  OUT NOCOPY  VARCHAR2,
                     RETCODE                 OUT NOCOPY  VARCHAR2,
                     X_from_Batch_number  IN      NUMBER   DEFAULT NULL,
                     X_to_batch_number    IN      NUMBER   DEFAULT NULL);

PROCEDURE process_batch( px_trans_rec        IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                         p_batch_id          IN     NUMBER ,
                         p_amortize_flag     IN     VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

PROCEDURE process_asset( px_trans_rec    IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                        p_batch_id       IN     NUMBER,
                        p_asset_id       IN     NUMBER,
                        p_book           IN     VARCHAR2,
                        p_amortize_flag  IN     VARCHAR2,
                        x_err_code          OUT NOCOPY VARCHAR2,
                        x_err_attr_name     OUT NOCOPY VARCHAR2  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) ;

PROCEDURE do_transfer( p_asset_id              IN     NUMBER,
                       p_book_type_code        IN     VARCHAR2,
                       p_new_hr_dist_set_id    IN     NUMBER,
                       p_transaction_date      IN     DATE,
                       x_err_code                 OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null) ;

PROCEDURE do_adjustment( px_trans_rec        IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                         px_asset_hdr_rec    IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
                         x_new_life          IN     NUMBER,
                         p_amortize_flag     IN     VARCHAR2,
                         x_err_code             OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null);

END FA_CUA_MASS_UPDATE1_PKG;

/
