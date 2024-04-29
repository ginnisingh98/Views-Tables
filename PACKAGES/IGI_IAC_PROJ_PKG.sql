--------------------------------------------------------
--  DDL for Package IGI_IAC_PROJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_PROJ_PKG" AUTHID CURRENT_USER AS
--  $Header: igiiacps.pls 120.9 2007/08/01 10:47:26 npandya ship $

   FUNCTION Get_Price_Index_Val(p_book_code fa_books.book_type_code%TYPE,
                                p_category_id fa_category_books.category_id%TYPE,
                                p_period_ctr fa_deprn_periods.period_counter%TYPE,
                                p_price_index_val OUT NOCOPY igi_iac_cal_idx_values.current_price_index_value%TYPE)
   RETURN BOOLEAN;

   FUNCTION Get_Reval_Prd_Dpis_Ctr(p_book_code fa_books.book_type_code%TYPE,
                                      p_asset_id  fa_books.asset_id%TYPE,
                                      p_reval_prd_ctr OUT NOCOPY fa_deprn_summary.period_counter%TYPE
                                 )
   RETURN BOOLEAN;

--   PROCEDURE submit_report_request(p_projection_id  igi_iac_projections.projection_id%type);

   PROCEDURE Do_Proj_Calc(
                         errbuf     OUT NOCOPY VARCHAR2,
                         retcode    OUT NOCOPY VARCHAR2,
                         p_projection_id   IN   igi_iac_projections.projection_id%TYPE,
                         p_rx_attribute_set IN fa_rx_attrsets_b.attribute_set%TYPE,
                         p_rx_output_format IN fnd_lookups.lookup_code%TYPE
                        );

    -- 15-May-2003, add new procedure to delete projections for a range of projection ids
    PROCEDURE Delete_Projections(
                                p_from_projection IN igi_iac_projections.projection_id%TYPE,
                                p_to_projection   IN igi_iac_projections.projection_id%TYPE
                               );
END igi_iac_proj_pkg;


/
